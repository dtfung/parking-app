//
//  ParkingRuleComposer.h
//  Parking
//
//  Created by Aditya Narayan on 12/3/14.
//  Copyright (c) 2014 DDCorp. All rights reserved.
//

#import <Foundation/Foundation.h>


//@class Driver;
//@class GoogleMapsViewController;
@interface ParkingRuleComposer : NSObject

@property (nonatomic, strong) NSMutableArray *rulesArray;

- (BOOL) compareTime: (NSDateComponents *)currentTime startDate:(NSDateComponents *)dateB  endDate:(NSDateComponents *)dateC;

+ (NSArray *)parseTimeFrom:(NSString *)string withDate:(NSDateFormatter *)formatter;

@end