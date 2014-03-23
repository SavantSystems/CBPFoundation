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

#import "CBPDeref.h"
#import "CBPDerefSubclass.h"

typedef NS_ENUM(NSInteger, CBPPromiseLockState_t)
{
    CBPDerefLockStateWaiting,
    CBPDerefLockStateRealized,
};

@interface CBPDeref ()

@property (nonatomic) NSConditionLock *lock;

@property (nonatomic) id value;

@end

@implementation CBPDeref

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        self.lock = [[NSConditionLock alloc] initWithCondition:CBPDerefLockStateWaiting];
    }
    
    return self;
}

- (void)derefWithTimeout:(NSTimeInterval)timeInterval successBlock:(CBPDerefRealizationBlock)successBlock timeoutBlock:(dispatch_block_t)timeoutBlock
{
    static NSString *const DefaultTimeoutValue = @"DefaultTimeoutValue";
    
    id value = [self derefWithTimeoutInterval:timeInterval timeoutValue:DefaultTimeoutValue];
    
    if (value == DefaultTimeoutValue)
    {
        if (timeoutBlock)
        {
            timeoutBlock();
        }
    }
    else
    {
        if (successBlock)
        {
            successBlock(value);
        }
    }
}


#pragma mark - CBPDerefSubclass methods

- (BOOL)assignValue:(id)value notify:(BOOL)notify criticalBlock:(dispatch_block_t)criticalBlock
{
    BOOL success = NO;
    
    if ([self.lock tryLockWhenCondition:CBPDerefLockStateWaiting])
    {
        success = YES;
        
        if (criticalBlock)
        {
            criticalBlock();
        }
        
        self.value = value;
        [self.lock unlockWithCondition:CBPDerefLockStateRealized];
        
        if (notify)
        {
            @synchronized (self)
            {
                CBPDerefRealizationBlock realizationBlock = self.realizationBlock;

                if (realizationBlock)
                {
                    dispatch_queue_t dispatchQueue = self.realizationQueue ? self.realizationQueue : dispatch_get_main_queue();

                    dispatch_async(dispatchQueue, ^{
                        
                        realizationBlock(value);
                        
                    });
                    
                    self.realizationBlock = nil;
                    self.realizationQueue = nil;
                }
            }
        }
    }
    
    return success;
}

- (BOOL)valueHasBeenAssigned
{
    return [self.lock condition] == CBPDerefLockStateRealized;
}


#pragma mark - CBPDeref methods

- (id)deref
{
    if ([self.lock condition] != CBPDerefLockStateRealized)
    {
        [self.lock lockWhenCondition:CBPDerefLockStateRealized];
        [self.lock unlock];
    }
    
    return self.value;
}

- (id)derefWithTimeoutInterval:(NSTimeInterval)timeoutInterval timeoutValue:(id)timeoutValue
{
    BOOL timedout = NO;
    
    if ([self.lock condition] != CBPDerefLockStateRealized)
    {
        if ([self.lock lockWhenCondition:CBPDerefLockStateRealized beforeDate:[NSDate dateWithTimeIntervalSinceNow:timeoutInterval]])
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

@end
