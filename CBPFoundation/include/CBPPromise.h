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

#import "CBPFoundation.h"

typedef void (^CBPPromiseDeliveryBlock)(id value);

@interface CBPPromise : NSObject <CBPPromise>

/**
 *  This block will be called when a value is delivered to the promise.
 */
@property (copy) CBPPromiseDeliveryBlock deliveryBlock;

/**
 *  The queue on which to perform the deliveryBlock. If no queue is specified, the main queue will be used.
 */
@property dispatch_queue_t deliveryQueue;

- (void)derefWithTimeout:(NSTimeInterval)timeInterval successBlock:(void (^)(id value))successBlock timeoutBlock:(void (^)(void))timeoutBlock;

@end
