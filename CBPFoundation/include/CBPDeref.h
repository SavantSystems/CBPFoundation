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

#import "CBPThreadingPrimitives.h"

typedef void (^CBPDerefRealizationBlock)(id value);

@interface CBPDeref : NSObject <CBPDeref>

/**
 *  This block will be called when a value has been realized.
 */
@property (copy) CBPDerefRealizationBlock realizationBlock;

/**
 *  The queue on which to perform the realizationBlock. If no queue is specified, the main queue will be used.
 */
@property dispatch_queue_t realizationQueue;

/**
 *  If a value is successfully deref'd within the timeout, the success block will be performed with the value, otherwise the timeout block will be called.
 *
 *  @param timeInterval The amount of time to wait for a value to be made available (in seconds).
 *  @param successBlock Called with the deref'd or cached value.
 *  @param timeoutBlock Called when a value was not made available within the timeout.
 */
- (void)derefWithTimeout:(NSTimeInterval)timeInterval successBlock:(CBPDerefRealizationBlock)successBlock timeoutBlock:(dispatch_block_t)timeoutBlock;

@end
