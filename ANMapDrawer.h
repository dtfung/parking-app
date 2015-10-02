//
//  ANMapDrawer.h
//  Parking
//
//  Created by Aditya Narayan on 5/26/15.
//  Copyright (c) 2015 DDCorp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@class RMMapView;

@interface ANMapDrawer : NSObject

+ (void)drawRouteOnMap:(RMMapView *)mapView;

+ (void)objectsFor:(RMMapView *)mapView
        withPoint:(CLLocationCoordinate2D)coordinate
        competion:(void(^)(CLLocationDegrees minLatitude,
                           CLLocationDegrees maxLatitude,
                           CLLocationDegrees minLongitude,
                           CLLocationDegrees maxLongitude))handler;
@end
