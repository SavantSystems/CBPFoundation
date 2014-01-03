/*
 The MIT License (MIT)
 
 Copyright (c) 2014 Cameron Pulsford
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

#import "CBPFuture.h"

id const CBPFutureCancelledValue = @"CBPFutureCancelledValue";

typedef NS_ENUM(NSInteger, CBPFutureLockState_t)
{
    CBPFutureLockStateWaiting,
    CBPFutureLockStateRealized,
};

@interface CBPFuture ()
@property dispatch_queue_t workQueue;
@property (copy) CBPFutureWorkBlock workBlock;
@property (nonatomic) NSConditionLock *lock;
@property (nonatomic) id value;
@property BOOL isRealized;
@property BOOL isCancelled;
@end

@implementation CBPFuture

- (instancetype)initWithQueue:(dispatch_queue_t)queue workBlock:(CBPFutureWorkBlock)workBlock
{
    if (!(workBlock || [self respondsToSelector:@selector(main)]))
    {
        [NSException raise:NSInternalInconsistencyException format:@"A block must be set or the -main method must be overriden -- %s", __PRETTY_FUNCTION__];
    }
    else
    {
        self = [super init];
        
        if (self)
        {
            self.workQueue = queue ? queue : dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            self.workBlock = workBlock;
            self.lock = [[NSConditionLock alloc] initWithCondition:CBPFutureLockStateWaiting];
            
            [self start];
        }
    }
    
    return self;
}

#pragma mark - CBPDeref

- (id)deref
{
    if ([self.lock condition] != CBPFutureLockStateRealized)
    {
        [self.lock lockWhenCondition:CBPFutureLockStateRealized];
        [self.lock unlock];
    }
    
    return self.value;
}

#pragma mark - CBPBlockingDeref

- (id)derefWithTimeoutInterval:(NSTimeInterval)timeoutInterval timeoutValue:(id)timeoutValue
{
    BOOL timedout = NO;
    
    if ([self.lock condition] != CBPFutureLockStateRealized)
    {
        if ([self.lock lockWhenCondition:CBPFutureLockStateRealized beforeDate:[NSDate dateWithTimeIntervalSinceNow:timeoutInterval]])
        {
            [self.lock unlock];
        }
        else
        {
            timedout = YES;
        }
    }
    
    return timedout ? timeoutValue : self.value;
}

#pragma mark - CBPFuture methods

- (BOOL)cancel
{
    BOOL success = NO;
    
    if ([self.lock tryLockWhenCondition:CBPFutureLockStateWaiting])
    {
        success = YES;
        self.isCancelled = YES;
        self.isRealized = YES;
        self.value = CBPFutureCancelledValue;
        [self.lock unlockWithCondition:CBPFutureLockStateRealized];
    }
    
    return success;
}

#pragma mark - Internal

- (void)start
{
    dispatch_block_t workBlock = ^{
        
        @autoreleasepool
        {
            id value = nil;
            
            if ([self respondsToSelector:@selector(main)])
            {
                value = [self main];
            }
            else
            {
                value = self.workBlock(^BOOL {
                    
                    return self.isCancelled;
                    
                });
            }
            
            if ([self.lock tryLockWhenCondition:CBPFutureLockStateWaiting])
            {
                self.isRealized = YES;
                self.value = value;
                [self.lock unlockWithCondition:CBPFutureLockStateRealized];
            }
        }
    };
    
    dispatch_async(self.workQueue, workBlock);
}

@end
