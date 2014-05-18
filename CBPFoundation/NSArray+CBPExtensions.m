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

#import "NSArray+CBPExtensions.h"
#import "CBPRuntime.h"

@implementation NSArray (CBPExtensions)

#pragma mark - Mapping

- (NSArray *)arrayByMappingBlock:(CBPArrayMappingBlock)block
{
    NSMutableArray *array = [NSMutableArray array];
    
    for (id object in self)
    {
        [array addObject:block(object)];
    }
    
    return [array copy];
}

- (NSArray *)arrayByMappingSelector:(SEL)selector
{
    return [self arrayByMappingBlock:^id(id object) {
        
        CBPFunctionForSelector(f, id, object, selector,);
        return f();
        
    }];
}

#pragma mark - Filtering

- (NSArray *)filteredArrayUsingBlock:(CBPArrayFilteringBlock)block
{
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        if (!block(obj))
        {
            [indexSet addIndex:idx];
        }
        
    }];
    
    NSArray *filteredArray = nil;
    
    //-------------------------------------------------------------------
    // Only create a new array if there are items to remove. Otherwise,
    // return the receiver.
    //-------------------------------------------------------------------
    if ([indexSet count])
    {
        NSMutableArray *mCopy = [self mutableCopy];
        [mCopy removeObjectsAtIndexes:indexSet];
        filteredArray = [mCopy copy];
    }
    else
    {
        filteredArray = [self copy]; /* Copy doesn't do anything for immutable arrays and allows for more consistent behavior when using mutable arrays. */
    }
    
    return filteredArray;
}

@end
