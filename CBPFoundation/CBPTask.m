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

#import "CBPTask.h"
#import "CBPTaskSubclass.h"

@interface CBPTask ()

@property BOOL isRunning;

@property NSUInteger numberOfTimesTaskWasStarted;

@end

@implementation CBPTask

- (BOOL)start
{
    @synchronized (self)
    {
        BOOL started = NO;
        
        if (![self.delegate conformsToProtocol:@protocol(CBPTaskDelegate)] &&
            !([self respondsToSelector:@selector(startTask)] && [self respondsToSelector:@selector(stopTask)]) &&
            !(self.startBlock && self.stopBlock))
        {
            [NSException raise:NSInternalInconsistencyException format:@"A delegate that conforms to the <CBPTaskDelegate> protocol must be set, or your class must override both the startTask and stopTask methods, or you must set both the start and stop blocks.\n%s", __PRETTY_FUNCTION__];
        }
        else if (!self.isRunning)
        {
            self.isRunning = YES;
            self.numberOfTimesTaskWasStarted++;
            started = YES;
            [self _startTask];
        }
        
        return started;
    }
}

- (BOOL)stop
{
    @synchronized (self)
    {
        BOOL stopped = NO;
        
        if (self.isRunning)
        {
            self.isRunning = NO;
            stopped = YES;
            [self _stopTask];
        }
        
        return stopped;
    }
}

- (void)_startTask
{
    [self _performStartTask];
}

- (void)_performStartTask
{
    if ([self respondsToSelector:@selector(startTask)])
    {
        [self startTask];
    }
    else if (self.delegate)
    {
        [self.delegate startTask:self];
    }
    else
    {
        self.startBlock();
    }
}

- (void)_stopTask
{
    [self _performStopTask];
}

- (void)_performStopTask
{
    if ([self respondsToSelector:@selector(stopTask)])
    {
        [self stopTask];
    }
    else if (self.delegate)
    {
        [self.delegate stopTask:self];
    }
    else
    {
        self.stopBlock();
    }
}

@end
