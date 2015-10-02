//
//  Driver.h
//  Parking
//
//  Created by Aditya Narayan on 12/3/14.
//  Copyright (c) 2014 DDCorp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "ParkingRuleComposer.h"
#import "sqlite3.h"

@interface DatabaseDriver : NSObject

@property (nonatomic, strong) NSMutableArray *block;

@property (nonatomic, strong) ParkingRuleComposer *parkingRuleComposerDriver;

+ (void)sqlQueryWithMinLatitude:(double)minLat
                    maxLatitude:(double)maxLat
                   minLongitude:(double)minLong
                   maxLongitude:(double)maxLong
                  enumerateWith:(void(^)(NSArray *signs))block
                     completion:(void(^)())handler;

@end