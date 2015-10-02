//
//  Sign.h
//  Parking
//
//  Created by Aditya Narayan on 3/19/15.
//  Copyright (c) 2015 DDCorp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface Sign : NSObject

@property (nonatomic) NSString *signId;
@property (nonatomic) NSString *signContent;
@property (nonatomic, assign, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, assign) double latitude;
@property (nonatomic, assign) double longitude;
@property (nonatomic) NSRange timeRange;

- (id)initWithID:(NSString *)signId withSign:(NSString *)content withLocation:(CLLocationCoordinate2D)coordinate;
- (BOOL)isEqualSignIDWith:(Sign *)sign;

- (NSInteger)isAvaliableForParking;
- (void)addTime:(NSDate *)date;

@end
