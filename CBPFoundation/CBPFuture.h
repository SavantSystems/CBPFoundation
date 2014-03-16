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

@import Foundation;
#import "CBPDeref.h"

/**
 *  The value returned by a canceled future.
 */
extern id const CBPFutureCanceledValue;

/**
 *  Use this block to determine if the future is canceled or not. Similar to an NSOperation, the value of this block should be checked occasionally in longer running work blocks.
 *  This block is a convenience to avoid capturing the future in the block and causing a retain cycle.
 *
 *  @return YES if the future has been canceled, otherwise NO.
 */
typedef BOOL (^CBPFutureCanceledBlock)(void);

/**
 *  Compute the value to cache. This block will be ignored if -main is overriden.
 *
 *  @param isCanceled A convenience block to determine if the future is canclled or not. Its value should be checked occasionally in longer running work blocks.
 *
 *  @return The result of the work block which will be cached.
 */
typedef id (^CBPFutureWorkBlock)(CBPFutureCanceledBlock isCanceled);


#pragma mark -

@interface CBPFuture : CBPDeref <CBPFuture>

/**
 *  Initializes and starts a new future.
 *
 *  @param queue     The queue on which to perform the work. If nil, a global concurrent background queue will be used.
 *  @param workBlock The work block whose value will be computed in the background and cached.
 *
 *  @return An initialized future.
 */
- (instancetype)initWithQueue:(dispatch_queue_t)queue workBlock:(CBPFutureWorkBlock)workBlock;

/**
 *  Initializes and starts a new future.
 *
 *  @param queue The queue on which to perform the work. If nil, a global concurrent background queue will be used.
 *
 *  @return An initialized future.
 */
- (instancetype)initWithQueue:(dispatch_queue_t)queue;

@end


#pragma mark - CBPFuture subclass methods

@interface CBPFuture (ForSubclassEyesOnly)

/**
 *  Compute the value to cache. This method takes precedence over the workBlock.
 *
 *  @return The result of the method which will be cached.
 */
- (id)main;

@end
