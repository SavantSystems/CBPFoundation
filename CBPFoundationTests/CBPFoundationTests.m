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
#import "CBPFoundation.h"

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

#pragma mark - String tests

- (void)testStringContains
{
    XCTAssert([@"hello" containsString:@"ll"], @"hello should contain ll");
    XCTAssert([@"hello" containsString:@"LL" options:NSCaseInsensitiveSearch], @"hello should contain LL case insensitively");
    XCTAssert([@"hello" containsString:@"LL" options:NSCaseInsensitiveSearch range:NSMakeRange(2, 2)], @"hello should contain LL case insensitively in the correct range");
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
    
    task.startBlock = ^{
        
        someVariable = YES;
        
    };
    
    task.stopBlock = ^{
        
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
    
    NSString *deliveryValue = @"hello";
    
    XCTAssert(![promise isRealized], @"Promise should not be considered resolved");
    
    XCTAssert([promise deliver:deliveryValue], @"Promise should have been able to be delivered");
    
    XCTAssert([promise isRealized], @"Promise should be considered resolved");

    XCTAssert([promise isValid], @"Promise should have been valid");
    
    XCTAssert(![promise deliver:@"hello 1"], @"Promise is already delivered and should not have been able to be delivered again");
    
    XCTAssert([[promise deref] isEqualToString:deliveryValue], @"Deref'd value was not equal to the delivered value!");

    XCTAssert(![promise invalidateWithError:nil], @"Shouldn't have been able to invalidate promise");
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
    
    promise.successBlock = ^(id value) {

        XCTAssert([value isEqualToString:promiseValue], @"Promise value should have been equal to: 'hello");
        XCTAssert(![value isEqualToString:@""], @"Promise value should not have been equal to: '");
        
    };

    sleep(1);
    
    [promise deliver:promiseValue];

    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
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

- (void)testPromiseTimeoutTimeout
{
    CBPPromise *promise = [[CBPPromise alloc] initWithTimeout:2.0];

    sleep(3);

    XCTAssert(![promise deliver:@""], @"Shouldn't have been able to deliver because of timeout");

    XCTAssert([promise deref] == CBPPromiseTimeoutValue, @"Promise should have equaled timeout value");
}

- (void)testPromiseTimeoutSucceed
{
    CBPPromise *promise = [[CBPPromise alloc] initWithTimeout:2.0];

    sleep(1);

    NSString *deliveryValue = @"";

    XCTAssert([promise deliver:deliveryValue], @"Should have been able to deliver");

    XCTAssert([promise deref] == deliveryValue, @"Promise should have equaled ''");
}

- (void)testPromiseInvalidateImmediate
{
    CBPPromise *promise = [[CBPPromise alloc] init];
    XCTAssert([promise invalidateWithError:nil], @"Should have been able to invalidate promise");
    XCTAssertEqualObjects(CBPDerefInvalidValue, [promise deref], @"Deref value should have been the invalid value");
    XCTAssert(![promise deliver:nil], @"Shouldn't have been able to deliver promise");
}

- (void)testPromiseInvalidateDelay
{
    CBPPromise *promise = [[CBPPromise alloc] init];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        sleep(2);
        [promise invalidateWithError:nil];

    });

    XCTAssertEqualObjects([promise deref], CBPDerefInvalidValue, @"Deref should have returned the invalid value");
}

#pragma mark - Future tests

- (void)testFutureDerefSameThread
{
    NSString *value = @"";
    
    CBPFuture *future = [[CBPFuture alloc] initWithQueue:nil workBlock:^id(CBPFutureCanceledBlock isValid) {
        
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
    
    CBPFuture *future = [[CBPFuture alloc] initWithQueue:nil workBlock:^id(CBPFutureCanceledBlock isValid) {
        
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
    
    CBPFuture *future = [[CBPFuture alloc] initWithQueue:nil workBlock:^id(CBPFutureCanceledBlock isValid) {
        
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
    
    CBPFuture *future = [[CBPFuture alloc] initWithQueue:nil workBlock:^id(CBPFutureCanceledBlock isValid) {
        
        sleep(5.0);
        
        return value;
        
    }];
    
    sleep(1);
    
    XCTAssert(![future isRealized], @"Should not have been realized");
    
    XCTAssert([future invalidateWithError:nil], @"Should have been able to cancel future");
    
    XCTAssert([future isRealized], @"Should have been realized");
    
    XCTAssert(![future invalidateWithError:nil], @"Should not have been able to cancel future");
    
    XCTAssert([[future derefWithTimeoutInterval:10.0 timeoutValue:@"hello"] isEqualToString:CBPDerefInvalidValue], @"Future deref did not work");
}

@end
