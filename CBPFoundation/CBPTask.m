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
#import "CBPFoundation.h"

@interface CBPTask ()

@property BOOL isRunning;

@property NSUInteger numberOfTimesTaskWasStarted;

@end

@implementation CBPTask

- (BOOL)start
{
    @synchronized (self)
    {
        if (!(self.target && self.startSelector && self.stopSelector) && !self.delegate)
        {
            [NSException raise:NSInternalInconsistencyException format:@"Either target, start selector and stop selector must be set, or a delegate must be set %s", __PRETTY_FUNCTION__];
        }
        
        BOOL started = NO;
        
        if (!self.isRunning)
        {
            self.isRunning = YES;
            self.numberOfTimesTaskWasStarted++;
            started = YES;
            
            if ([self.delegate respondsToSelector:@selector(startTask:)])
            {
                [self.delegate startTask:self];
            }
            else
            {
                CBPFunctionForSelector(function, void, self.target, self.startSelector,);
                function(self.target);
            }
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
            
            if ([self.delegate respondsToSelector:@selector(stopTask:)])
            {
                [self.delegate stopTask:self];
            }
            else
            {
                CBPFunctionForSelector(function, void, self.target, self.stopSelector,);
                function(self.target);
            }
        }
        
        return stopped;
    }
}

@end
