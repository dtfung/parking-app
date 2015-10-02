//
//  ANMapDrawer.m
//  Parking
//
//  Created by Aditya Narayan on 5/26/15.
//  Copyright (c) 2015 DDCorp. All rights reserved.
//

#import "ANMapDrawer.h"
#import "Mapbox.h"
#import "Directions.h"

@interface ANMapDrawer ()

@property (nonatomic, strong) RMPolylineAnnotation *polyline;

@end

@implementation ANMapDrawer

+ (void)drawRouteOnMap:(RMMapView *)mapView
{
    RMPolylineAnnotation *polyline;
    
    NSArray *legs = [[Directions sharedManager] getRouteFromLegs];
    
    if (!legs) return;
    NSMutableArray *arr = [NSMutableArray new];
    [arr addObjectsFromArray:[[Directions sharedManager] getRouteFromLegs]];
    
    if ([arr count] > 0) {
        polyline = [[RMPolylineAnnotation alloc] initWithMapView:mapView
                                                           points:arr];
        
        polyline.userInfo = @"polyline";
        polyline.lineColor = [UIColor redColor];
        polyline.lineWidth = 5.0;
        
        [mapView addAnnotation:polyline];
    }
}

+ (void)objectsFor:(RMMapView *)mapView
           withPoint:(CLLocationCoordinate2D)coordinate
              competion:(void(^)(CLLocationDegrees minLatitude,
                                 CLLocationDegrees maxLatitude,
                                 CLLocationDegrees minLongitude,
                                 CLLocationDegrees maxLongitude))handler
{
    CLLocationCoordinate2D coordinates[4];
    double radius = 0.004;
    for (int i = 0; i < 4; ++i) {
        CLLocationCoordinate2D tmpCoordinate = CLLocationCoordinate2DMake(coordinate.latitude + cos(M_PI_2 * i) * radius, coordinate.longitude + sin(M_PI_2 * i) * radius);
        
        coordinates[i] = tmpCoordinate;
        
        RMAnnotation *marker = [RMAnnotation annotationWithMapView:mapView coordinate:tmpCoordinate andTitle:@"Border"];
        
        marker.position = [mapView coordinateToPixel:tmpCoordinate];
        
        [mapView addAnnotation:marker];
    }
    
    
    double latitudes[] = {
        coordinates[0].latitude,
        coordinates[1].latitude,
        coordinates[2].latitude,
        coordinates[3].latitude};
    
    double longitudes[] = {
        coordinates[0].longitude,
        coordinates[1].longitude,
        coordinates[2].longitude,
        coordinates[3].longitude
    };
    
    CLLocationDegrees minLatitude = MIN(MIN(latitudes[0], latitudes[1]), MIN(latitudes[2], latitudes[3]));
    CLLocationDegrees maxLatitude = MAX(MAX(latitudes[0], latitudes[1]), MAX(latitudes[2], latitudes[3]));
    
    CLLocationDegrees minLongitude = MIN(MIN(longitudes[0], longitudes[1]), MIN(longitudes[2], longitudes[3]));
    CLLocationDegrees maxLongitude = MAX(MAX(longitudes[0], longitudes[1]), MAX(longitudes[2], longitudes[3]));
    
    handler(minLatitude, maxLatitude, minLongitude, maxLongitude);
}


@end
