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
#import "CBPDerefSubclass.h"

@interface CBPFuture ()

@property dispatch_queue_t workQueue;

@property (copy) CBPFutureWorkBlock workBlock;

@end

@implementation CBPFuture

+ (dispatch_queue_t)sharedDispatchQueue
{
    static dispatch_queue_t sharedDispatchQueue = NULL;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedDispatchQueue = dispatch_queue_create("CBPFutureSharedDispatchQueue", DISPATCH_QUEUE_CONCURRENT);
    });

    return sharedDispatchQueue;
}

- (instancetype)initWithQueue:(dispatch_queue_t)queue workBlock:(CBPFutureWorkBlock)workBlock
{
    if (!workBlock)
    {
        [NSException raise:NSInternalInconsistencyException format:@"workBlock must not be nil. %s", __PRETTY_FUNCTION__];
    }
    else if ([self respondsToSelector:@selector(main)])
    {
        [NSException raise:NSInternalInconsistencyException format:@"-main must not be implemented when using a work block. %s", __PRETTY_FUNCTION__];
    }
    else
    {
        self = [self _initWithQueue:queue workBlock:workBlock];
    }

    return self;
}

- (instancetype)initWithQueue:(dispatch_queue_t)queue
{
    if (![self respondsToSelector:@selector(main)])
    {
        [NSException raise:NSInternalInconsistencyException format:@"You must implement -main if you are not providing a workBlock. %s", __PRETTY_FUNCTION__];
    }
    else
    {
        self = [self _initWithQueue:queue workBlock:NULL];
    }

    return self;
}

- (instancetype)_initWithQueue:(dispatch_queue_t)queue workBlock:(CBPFutureWorkBlock)workBlock
{
    self = [super init];

    if (self)
    {
        self.workQueue = queue;
        self.workBlock = workBlock;
        [self start];
    }

    return self;
}

#pragma mark -

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

                    return self.state == CBPDerefStateInvalid;

                });
            }
            
            [self assignValue:value];
        }
    };
    
    dispatch_queue_t queue = self.workQueue ? self.workQueue : [[self class] sharedDispatchQueue];
    
    dispatch_async(queue, workBlock);
}

@end
