/*
 The MIT License (MIT)
 
 Copyright (c) 2013 Cameron Pulsford
 
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

#import <XCTest/XCTest.h>
#import <CBPFoundation/CBPFoundation.h>

@interface CBPFoundationTests : XCTestCase

@end

@implementation CBPFoundationTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testArraySelectorMapping
{
    NSArray *testArray = @[@"1", @"2",];
    
    NSArray *result = [testArray arrayByMappingSelector:@selector(mutableCopy)];
    
    for (NSString *string in result)
    {
        XCTAssert([string isKindOfClass:[NSMutableString class]], @"%@ is not a mutable string", string);
    }
}

- (void)testArrayBlockMapping
{
    NSArray *testArray = @[@"1", @"2",];
    
    NSArray *result = [testArray arrayByMappingBlock:^id(id object) {
        
        return [object mutableCopy];
        
    }];
    
    for (NSString *string in result)
    {
        XCTAssert([string isKindOfClass:[NSMutableString class]], @"%@ is not a mutable string", string);
    }
}

- (void)testImmutableArrayFiltering
{
    NSArray *testArray = @[@"1", @"2",];
    
    NSArray *result = [testArray filteredArrayUsingBlock:^BOOL(id object) {
        
        return [object isEqualToString:@"1"];
        
    }];
    
    XCTAssert([result isEqualToArray:@[@"1"]], @"Filtering did not work!");
}

- (void)testMutableArrayFiltering
{
    NSMutableArray *testArray = [@[@"1", @"2",] mutableCopy];
    
    [testArray filterArrayUsingBlock:^BOOL(id object) {
        
        return [object isEqualToString:@"1"];
        
    }];
    
    XCTAssert([testArray isEqualToArray:@[@"1"]], @"Filtering did not work!");
}

- (void)testTakeZero
{
    NSArray *testArray = @[@"1", @"2"];
    
    XCTAssert([@[] isEqualToArray:[testArray arrayByTakingObjects:0]], @"Taking zero objects failed");
}

- (void)testTakeSome
{
    NSArray *testArray = @[@"1", @"2"];
    
    XCTAssert([@[@"1"] isEqualToArray:[testArray arrayByTakingObjects:1]], @"Taking some objects failed");
}

- (void)testTakeAll
{
    NSArray *testArray = @[@"1", @"2"];
    
    XCTAssert([testArray isEqualToArray:[testArray arrayByTakingObjects:2]], @"Taking all objects failed");
}

- (void)testTakeMore
{
    NSArray *testArray = @[@"1", @"2"];
    
    XCTAssert([testArray isEqualToArray:[testArray arrayByTakingObjects:100]], @"Taking more objects failed");
}

- (void)testDropZero
{
    NSArray *testArray = @[@"1", @"2"];
    
    XCTAssert([testArray isEqualToArray:[testArray arrayByDroppingObjects:0]], @"Dropping zero objects failed");
}

- (void)testDropSome
{
    NSArray *testArray = @[@"1", @"2"];
    
    XCTAssert([@[@"2"] isEqualToArray:[testArray arrayByDroppingObjects:1]], @"Dropping some objects failed");
}

- (void)testDropAll
{
    NSArray *testArray = @[@"1", @"2"];
    
    XCTAssert([@[] isEqualToArray:[testArray arrayByDroppingObjects:2]], @"Dropping all objects failed");
}

- (void)testDropMore
{
    NSArray *testArray = @[@"1", @"2"];
    
    XCTAssert([@[] isEqualToArray:[testArray arrayByDroppingObjects:100]], @"Dropping more objects failed");
}

@end
