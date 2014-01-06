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


#pragma mark - Mapping tests

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


#pragma mark - Filtering tests

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


#pragma mark - Take tests

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


#pragma mark - Drop tests

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


#pragma mark - Thread tests

- (void)testBasicThreadExecution
{
    NSThread *thread = [NSThread cbp_runningThread];
    
    __block BOOL someVariable = NO;
    
    [thread cbp_performBlockSync:^{
        someVariable = YES;
    }];
    
    [thread cbp_stop];
    
    XCTAssert(someVariable, @"Thread synchronous execution did not work");
}


#pragma mark - CBPBackgroundTask tests

- (void)testBasicBackgroundTask
{
    CBPBackgroundTask *task = [[CBPBackgroundTask alloc] init];
    
    __block BOOL someVariable = NO;
    
    task.startBlock = ^id {
        
        someVariable = YES;
        return nil;
        
    };
    
    task.stopBlock = ^(id object) {
        
        someVariable = NO;
        
    };
    
    [task start];
    
    XCTAssert(someVariable, @"Task did not start");
    
    [task stop];
    
    XCTAssert(!someVariable, @"Task did not finish");
}


#pragma mark - Promise tests

- (void)testPromiseBasics
{
    CBPPromise *promise = [[CBPPromise alloc] init];
    
    XCTAssert(![promise isRealized], @"Promise should not be considered resolved");
    
    XCTAssert([promise deliver:@"hello"], @"Promise should have been able to be delivered");
    
    XCTAssert([promise isRealized], @"Promise should be considered resolved");
    
    XCTAssert(![promise deliver:@"hello 1"], @"Promise is already delivered and should not have been able to be delivered again");
    
    XCTAssert([[promise deref] isEqualToString:@"hello"], );
}

- (void)testPromiseBackgroundResolve
{
    NSString *promiseValue = @"hello";
    
    CBPPromise *promise = [[CBPPromise alloc] init];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        sleep(2);
        [promise deliver:promiseValue];
        
    });
    
    XCTAssert([[promise deref] isEqualToString:promiseValue], @"Promise value should have been equal to: 'hello");
}

- (void)testPromiseBlockResolve
{
    NSString *promiseValue = @"hello";
    
    CBPPromise *promise = [[CBPPromise alloc] init];
    
    promise.realizationBlock = ^(id value) {
        
        XCTAssert([value isEqualToString:promiseValue], @"Promise value should have been equal to: 'hello");
        
    };
    
    [promise deliver:promiseValue];
}

- (void)testPromiseBackgroundResolveTimeout
{
    NSString *promiseValue = @"hello";
    
    CBPPromise *promise = [[CBPPromise alloc] init];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        sleep(2);
        [promise deliver:promiseValue];
        
    });
    
    XCTAssert([[promise derefWithTimeoutInterval:0.2 timeoutValue:@""] isEqualToString:@""], @"Promise should have timedout and equaled been equal to the empty string");
    
    XCTAssert([[promise derefWithTimeoutInterval:5.0 timeoutValue:@""] isEqualToString:promiseValue], @"Promise shouldn't have timedout and show have been equal to: '%@'", promiseValue);
}

- (void)testFutureDerefSameThread
{
    NSString *value = @"";
    
    CBPFuture *future = [[CBPFuture alloc] initWithQueue:nil workBlock:^id(CBPFutureCancelledBlock isValid) {
        
        sleep(5.0);
        
        return value;
        
    }];
    
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        XCTAssert([[future deref] isEqualToString:value], @"Future deref did not work");
    });
    
    XCTAssert([[future deref] isEqualToString:value], @"Future deref did not work");
}

- (void)testFutureDerefDifferentThread
{
    NSString *value = @"";
    
    CBPFuture *future = [[CBPFuture alloc] initWithQueue:nil workBlock:^id(CBPFutureCancelledBlock isValid) {
        
        sleep(5.0);
        
        return value;
        
    }];
    
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        XCTAssert([[future deref] isEqualToString:value], @"Future deref did not work");
    });
}

- (void)testFutureDerefTimeout
{
    NSString *value = @"";
    
    CBPFuture *future = [[CBPFuture alloc] initWithQueue:nil workBlock:^id(CBPFutureCancelledBlock isValid) {
        
        sleep(5.0);
        
        return value;
        
    }];
    
    XCTAssert([[future derefWithTimeoutInterval:1.0 timeoutValue:@"hello"] isEqualToString:@"hello"], @"Future deref did not work");
    
    XCTAssert(![future isRealized], @"Future shouldn't be realized");
    
    XCTAssert([[future derefWithTimeoutInterval:10.0 timeoutValue:@"hello"] isEqualToString:value], @"Future deref did not work");
    
    XCTAssert([future isRealized], @"Future should be realized");
}

- (void)testFutureDerefCancel
{
    NSString *value = @"";
    
    CBPFuture *future = [[CBPFuture alloc] initWithQueue:nil workBlock:^id(CBPFutureCancelledBlock isValid) {
        
        sleep(5.0);
        
        return value;
        
    }];
    
    sleep(1);
    
    XCTAssert(![future isRealized], @"Should not have been realized");
    
    XCTAssert([future cancel], @"Should have been able to cancel future");
    
    XCTAssert([future isRealized], @"Should have been realized");
    
    XCTAssert(![future cancel], @"Should not have been able to cancel future");
    
    XCTAssert([[future derefWithTimeoutInterval:10.0 timeoutValue:@"hello"] isEqualToString:CBPFutureCancelledValue], @"Future deref did not work");
}

@end
