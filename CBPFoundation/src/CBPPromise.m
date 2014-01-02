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

#import "CBPPromise.h"

typedef NS_ENUM(NSInteger, CBPPromiseLockState_t)
{
    CBPPromiseLockStateWaiting,
    CBPPromiseLockStateDelivered,
};

@interface CBPPromise ()
@property (nonatomic) NSConditionLock *lock;
@property (nonatomic) id value;
@end

@implementation CBPPromise

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        self.lock = [[NSConditionLock alloc] initWithCondition:CBPPromiseLockStateWaiting];
    }
    
    return self;
}

- (BOOL)isRealized
{
    return [self.lock condition] == CBPPromiseLockStateDelivered;
}

- (BOOL)deliver:(id)value
{
    BOOL success = NO;
    
    if ([self.lock tryLockWhenCondition:CBPPromiseLockStateWaiting])
    {
        success = YES;
        self.value = value;
        
        @synchronized (self)
        {
            if (self.deliveryBlock)
            {
                if (self.deliveryQueue)
                {
                    dispatch_async(self.deliveryQueue, ^{
                        
                        self.deliveryBlock(value);
                        
                    });
                }
                else
                {
                    self.deliveryBlock(value);
                }
                
                self.deliveryBlock = nil;
                self.deliveryQueue = nil;
            }
        }
        
        [self.lock unlockWithCondition:CBPPromiseLockStateDelivered];
    }
    
    return success;
}

- (id)deref
{
    if ([self.lock condition] != CBPPromiseLockStateDelivered)
    {
        [self.lock lockWhenCondition:CBPPromiseLockStateDelivered];
        [self.lock unlock];
    }
    
    return self.value;
}

- (id)derefWithTimeoutInterval:(NSTimeInterval)timeoutInterval timeoutValue:(id)timeoutValue
{
    BOOL timedout = NO;
    
    if ([self.lock condition] != CBPPromiseLockStateDelivered)
    {
        if ([self.lock lockWhenCondition:CBPPromiseLockStateDelivered beforeDate:[NSDate dateWithTimeIntervalSinceNow:timeoutInterval]])
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

- (void)derefWithTimeout:(NSTimeInterval)timeInterval successBlock:(void (^)(id value))successBlock timeoutBlock:(void (^)(void))timeoutBlock
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

@end
