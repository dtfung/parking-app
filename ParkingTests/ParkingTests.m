//
//  ParkingTests.m
//  ParkingTests
//
//  Created by Aditya Narayan on 12/3/14.
//  Copyright (c) 2014 DDCorp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "ParkingRuleComposer.h"
#import "DatabaseDriver.h"

@interface ParkingTests : XCTestCase

@end

@implementation ParkingTests
NSDateFormatter *dateFormatter;

- (void)setUp {
    [super setUp];
    dateFormatter = [NSDateFormatter new];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
        [self testDB];
    }];
}

- (void)testParkingComposer
{
    //given
    NSString *timeString = @"MON SUN";
    
    //when
    NSArray *timeArray = [ParkingRuleComposer parseTimeFrom:timeString withDate:dateFormatter];
    
    //then
    for (NSDate *date in timeArray) {
        XCTAssertTrue([@"Monday" isEqualToString:[dateFormatter stringFromDate:date]] || [@"Sunday" isEqualToString:[dateFormatter stringFromDate:date]]);
    }
}

- (void)testParkingComposerWithExceptKeyword
{
    NSString *timeString = @"MON EXC SUN";
    NSArray *timeArray = [ParkingRuleComposer parseTimeFrom:timeString withDate:dateFormatter];
    for (NSDate *date in timeArray) {
//        NSLog(@"%@", [dateFormatter stringFromDate:date]);
        XCTAssertTrue([@"Monday" isEqualToString:[dateFormatter stringFromDate:date]] || ![@"Sunday" isEqualToString:[dateFormatter stringFromDate:date]]);
    }
}

- (void)testDB
{
    double minLatitude = 40.77098434;
    double maxLatitude = 40.77898434;
    double minLongitude = -73.96168641;
    double maxLongitude = -73.95368641;
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"SQL is ready"];
    
    [DatabaseDriver sqlQueryWithMinLatitude:minLatitude maxLatitude:maxLatitude minLongitude:minLongitude maxLongitude:maxLongitude enumerateWith:^(NSArray *signs) {
        
        XCTAssert([signs count] > 1);
    } completion:^{
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:0.1 handler:^(NSError *error) {
        XCTAssert(YES);
    }];
}

@end
