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

@interface NSArray (CBPExtensions)

#pragma mark - Mapping

/**
 *  Returns a new array that is the result of performing the given block on each object in the receiving array.
 *
 *  @param block A block that will be performed with each object in the array.
 *
 *  @return A new array that is the result of performing the given block on each object in the receiving array.
 */
- (NSArray *)arrayByMappingBlock:(CBPArrayMappingBlock)block;

/**
 *  Returns a new array that is the result of sending the message identified by the given selector to each object in the receiving array.
 *
 *  @param selector A selector that identifies the message to send to the objects in the array.
 *
 *  @return A new array that is the result of sending the message identified by the given selector to each object in the receiving array.
 */
- (NSArray *)arrayByMappingSelector:(SEL)selector;

#pragma mark - Filtering

/**
 *  Evaluates a given block against each object in the receiving array and returns an array containing the objects for which the block returns true.
 *
 *  @param block The block against which to evaluate the receiving array’s elements.
 *
 *  @return An array containing the objects in the receiving array for which block returns true.
 */
- (NSArray *)filteredArrayUsingBlock:(CBPArrayFilteringBlock)block;

#pragma mark - Creating subarrays

/**
 *  Returns a new array containing at most the given number of objects starting from the beginning of the receiving array. If there are less objects in the receiving array than requested, the receiver will be returned.
 *
 *  @param numberOfObjects The number of desired objects from the receiving array to take.
 *
 *  @return A new array whose length is at most the given number of objects, or the receiver if there are not enough objects.
 */
- (NSArray *)arrayByTakingObjects:(NSUInteger)numberOfObjects;

/**
 *  Returns a new array that is the result of dropping the given number of objects from the beginning of the receiving array.
 *
 *  @param numberOfObjects The number of objects to drop from the beginning of the receiving array.
 *
 *  @return A new array that is the result of dropping the given number of objects from the beginning of the receiving array.
 */
- (NSArray *)arrayByDroppingObjects:(NSUInteger)numberOfObjects;

@end
