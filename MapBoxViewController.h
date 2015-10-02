//
//  MapBoxViewController.h
//  Parking
//
//  Created by Aditya Narayan on 4/9/15.
//  Copyright (c) 2015 DDCorp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "MapSharedMethod.h"
#import "Mapbox.h"
#import "Directions.h"
#import <GoogleMaps/GoogleMaps.h>

@interface MapBoxViewController : UIViewController <RMMapViewDelegate, CLLocationManagerDelegate, RMTileCacheBackgroundDelegate, MapSharedMethod, UITextFieldDelegate>


@property (nonatomic)  NSMutableArray *contentArray;
@property (nonatomic, strong)  NSMutableArray *placesArray;
@property (nonatomic, retain) GMSPlacesClient *placesClient;
@property (weak, nonatomic) IBOutlet UITextField *searchBarAddressField;


- (IBAction)currentLocation:(UIButton *)sender;



@end
