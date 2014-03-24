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
 *  The value returned by an invalid promise.
 */
extern id const CBPPromiseTimeoutValue;

@interface CBPPromise : CBPDeref <CBPPromise>

/**
 *  YES if a value was delivered within the timeout window, otherwise NO.
 */
@property (readonly, getter = isValid) BOOL valid;

/**
 *  Initializes a promise with a timeout value. If a value is not delivered within the timeout window, -deref will return CBPPromiseTimeoutValue and isValid will be NO.
 *
 *  @param timeout The length of time the promise is valid.
 *
 *  @return An initialized promise.
 */
- (instancetype)initWithTimeout:(NSTimeInterval)timeout;

@end
