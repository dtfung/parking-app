//
//  ParkingRuleComposer.m
//  Parking
//
//  Created by Aditya Narayan on 12/3/14.
//  Copyright (c) 2014 DDCorp. All rights reserved.
//

#import "ParkingRuleComposer.h"
#import "AppDelegate.h"

@interface ParkingRuleComposer ()

@end

@implementation ParkingRuleComposer
static NSString *AM = @"AM";
static NSString *PM = @"PM";


- (BOOL)compareTime:(NSDateComponents *)currentTime startDate:(NSDateComponents *)dateB endDate:(NSDateComponents *)dateC  {
    if(currentTime.weekday >= dateB.weekday && currentTime.weekday <= dateC.weekday){
        if(currentTime.hour * 60 + currentTime.minute >= dateB.hour * 60 + dateB.minute && currentTime.hour * 60 + currentTime.minute < dateC.hour * 60 + dateC.minute){
            return true;
        }else {
         return false;
        }
    }
    else {
        return false;
    }
}

+ (NSArray *)parseTimeFrom:(NSString *)string withDate:(NSDateFormatter *)formatter
{
    NSMutableArray *timeArray = [NSMutableArray arrayWithCapacity:2];
    
    formatter.dateFormat = @"hh:mma";
    
    if ([string containsString:@" TO "]) {
        string = [string stringByReplacingOccurrencesOfString:@" TO " withString:@"-"];
    }
    
    NSArray *arr = [string componentsSeparatedByString:@"-"];
    
    if ([arr count] < 2) return [self parseDaysFrom:string with:formatter];
    
    NSString *first = arr[0];
    NSString *second = arr[1];
    
    if ([first containsString:AM] || [first containsString:PM]) {
        if (![first containsString:@":"]) {
            first = [first stringByReplacingCharactersInRange:NSMakeRange([first length]-2, 2)
                                                   withString:[NSString stringWithFormat:@":00%@", [first substringWithRange:NSMakeRange([first length]-2, 2)]]];
        }
    }else {
        if ([first containsString:@":"]) {
            first = [NSString stringWithFormat:@"%@%@", first, [second substringWithRange:NSMakeRange([second length]-2, 2)]];
        }else {
            first = [NSString stringWithFormat:@"%@:00%@", first, [second substringWithRange:NSMakeRange([second length]-2, 2)]];
        }
    }
    
    if (![second containsString:@":"]) {
        second = [second stringByReplacingCharactersInRange:NSMakeRange([second length]-2, 2)
                                                 withString:[NSString stringWithFormat:@":00%@", [second substringWithRange:NSMakeRange([second length]-2, 2)]]];
    }
    
    if ([formatter dateFromString:first] && [formatter dateFromString:second]) {
        [timeArray addObject:[formatter dateFromString:first]];
        [timeArray addObject:[formatter dateFromString:second]];
    }

    return timeArray;
}

+ (NSArray *)parseDaysFrom:(NSString *)string with:(NSDateFormatter *)formatter
{
    NSMutableArray *timeArray = [NSMutableArray new];
    
    formatter.dateFormat = @"EEEE";
    
    NSArray *tmpArray = [string componentsSeparatedByString:@" "];

    for (NSString *str in tmpArray) {
        if ([str containsString:@"EXC"]) break;
        
        NSDate *date = [formatter dateFromString:str];
        if (date) [timeArray addObject:date];
    }
    
    return timeArray;
}

@end

