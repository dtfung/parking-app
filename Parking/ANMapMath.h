//
//  ANMapMath.h
//  Parking
//
//  Created by Andrei Nechaev on 3/24/15.
//  Copyright (c) 2015 ParkingApp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface ANMapMath : NSObject


/* Define if marker contains another marker in a radius
 * @param R is maximum distance between markers
 * 0.01 = 100m
 */
+ (BOOL)isMarker:(CLLocationCoordinate2D)firstPoint contains:(CLLocationCoordinate2D)secondPoint inRadius:(double)R;

/* @return double value which is define a factor.
 * if factor is equal to 0.0 all points are on the same line
 */
+ (double)isOnOneLine:(CLLocationCoordinate2D)firstPoint with:(CLLocationCoordinate2D)secondPoint and:(CLLocationCoordinate2D)thirdPoint;

/* @param signs is an array of @class Sign
 * @param regEx is a regular expresion used for a search
 * @return NSArray of signs
 */
+ (NSArray *)arrayWithAvaliableParkingSlots:(NSArray *)signs withRegEx:(const NSString *)regEx;

@end
