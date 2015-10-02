
//
//  Sign.m
//  Parking
//
//  Created by Aditya Narayan on 3/19/15.
//  Copyright (c) 2015 DDCorp. All rights reserved.
//

#import "Sign.h"
#import "ParkingRuleComposer.h"
#import "Directions.h"

@interface Sign ()

@property (nonatomic) NSMutableArray *timeArray;

@end
@implementation Sign

+(instancetype)new
{
    return [[self class] new];
}

- (id)init
{
    if(self = [super init]) {
        _signId = @"ID_UNDEF";
        _signContent = @"CT_UNDEF";
        _latitude = 0.f;
        _longitude = 0.f;
        
        _timeArray = [NSMutableArray new];
    }
    
    return self;
}

- (id)initWithID:(NSString *)signId withSign:(NSString *)content withLocation:(CLLocationCoordinate2D)coordinate
{
    if (self = [self init]) { //???
        _signId = signId;
        _signContent = content;
        _latitude = coordinate.latitude;
        _longitude = coordinate.longitude;
    }
    
    return self;
}

- (void)addTime:(NSDate *)date
{
    [self.timeArray addObject:date];
}

- (NSInteger)isAvaliableForParking
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSInteger flag = -1;

    for (NSDate *date in _timeArray) {
        NSDateComponents *time = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitDay) fromDate:date];
        
        if ([self compareTimeToDate:time] == 1) return 1; //eligable for parking
        else if ([self compareTimeToDate:time] == 0) flag = 0; //will be close in a next hour
    }

    return flag;
}

- (NSInteger) compareTimeToDate:(NSDateComponents *)dateB {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *tmp_date = [[Directions sharedManager] currentDay];
    NSDate *today;
    if (tmp_date) { 
        today = tmp_date;
    }else {
        today = [NSDate new];
    }

    NSDateComponents *currentTime = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitDay) fromDate:today];
    double diference = (dateB.hour + dateB.minute / 100.f) - (currentTime.hour + currentTime.minute / 100.f);
    
    if (diference >= 1.f) {
        return 1;
    }else if (diference > 0.1f &&diference < 1.f) {
        return 0;
    }
    
    return -1;
}

- (BOOL)isEqualSignIDWith:(Sign *)sign
{
    return [self.signContent isEqualToString:sign.signContent] ? YES : NO;
}

- (CLLocationCoordinate2D)coordinate
{
    return CLLocationCoordinate2DMake(_latitude, _longitude);
}

@end
