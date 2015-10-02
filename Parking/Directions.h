//
//  Directions.h
//  Parking
//
//  Created by Degerhan Deger on 3/8/15.
//  Copyright (c) 2015 DDCorp. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

extern NSString * const DirectionNotificationUserOnRoad;
extern NSString * const DirectionNotificationUserOutOfRoad;

@interface Directions : NSObject


@property (nonatomic, strong) NSDate *currentDay;

+ (id)sharedManager;

- (void)requestRouteFrom:(CLLocationCoordinate2D)original to:(CLLocationCoordinate2D)destination completition:(void(^)(void))handler;
- (NSArray *)getRouteFromLegs;

- (BOOL)checkRouteWith:(CLLocationCoordinate2D)coordinate;
- (BOOL)userEnterInto:(CLLocationCoordinate2D)coordinate;

@end
