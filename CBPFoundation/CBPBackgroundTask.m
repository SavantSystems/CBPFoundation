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

#import "CBPBackgroundTask.h"
#import "CBPTask.h"

@interface CBPBackgroundTask () <CBPTaskDelegate>

@property CBPTask *task;

@property (readwrite) NSThread *thread;

@property (readwrite) id object;

@end

@implementation CBPBackgroundTask

- (void)dealloc
{
    [self stop];
}

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        self.task = [[CBPTask alloc] init];
        self.task.delegate = self;
    }
    
    return self;
}

- (BOOL)isRunning
{
    return self.task.isRunning;
}

- (void)start
{
    if (([self.delegate conformsToProtocol:@protocol(CBPBackgroundTaskDelegate)]) && (self.startBlock || self.stopBlock))
    {
        [NSException raise:NSInternalInconsistencyException format:@"A CBPBackgroundTask may not be started with a mixed delegate and block based callback structure"];
        return;
    }
    
    if (![self.delegate conformsToProtocol:@protocol(CBPBackgroundTaskDelegate)] && !self.startBlock && !self.stopBlock)
    {
        [NSException raise:NSInternalInconsistencyException format:@"A CBPBackgroundTask requires a delegate conforming to the CBPBackgroundTaskDelegate protocol or both start and stop blocks to be set before it can begin"];
        return;
    }
    
    [self.task start];
}

- (void)stop
{
    [self.task stop];
}


#pragma mark - CBPTaskDelegate methods

- (void)startTask:(CBPTask *)task
{
    self.thread = [NSThread cbp_runningThread];
    
    [self.thread cbp_performBlockSync:^{
        
        if ([self.delegate respondsToSelector:@selector(startBackgroundTask:)])
        {
            self.object = [self.delegate startBackgroundTask:self];
        }
        else if (self.startBlock)
        {
            self.object = self.startBlock();
        }
        
    }];
}

- (void)stopTask:(CBPTask *)task
{
    [self.thread cbp_performBlockSync:^{
        
        if (self.delegate)
        {
            if ([self.delegate respondsToSelector:@selector(stopBackgroundTask:withObject:)])
            {
                [self.delegate stopBackgroundTask:self withObject:self.object];
            }
        }
        else if (self.startBlock)
        {
            self.stopBlock(self.object);
        }
        
    }];
    
    [self.thread cbp_stop];
    self.thread = nil;
    self.object = nil;
}

@end
