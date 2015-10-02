//
//  MapBoxViewController.m
//  Parking
//
//  Created by Andrei Nechaev on 4/9/15.
//  Copyright (c) 2015 ParkingApp. All rights reserved.
//

#import "MapBoxViewController.h"
#import "DatabaseDriver.h"
#import "Sign.h"
#import "ANMapMath.h"
#import "ANMapDrawer.h"



@interface MapBoxViewController (){
    BOOL isNavigationMode;
    CLLocationCoordinate2D finalDestination;
}

@property (nonatomic) IBOutlet RMMapView *mapView;
@property (nonatomic) RMMapboxSource *source;
@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) RMTileCache *tileCache;
@property (nonatomic) NSArray *signs;

//@property (weak, nonatomic) IBOutlet UITextField *searchAddressBarField;
@property (weak, nonatomic) IBOutlet UIButton *settingsOutlet;
@property (weak, nonatomic) IBOutlet UIButton *mySpotOutlet;
@property (weak, nonatomic) IBOutlet UIButton *parkingSignsAroundMeOutlet;
@property (weak, nonatomic) IBOutlet UIButton *myLocationOutlet;
@property (weak, nonatomic) IBOutlet UIButton *microphoneOutlet;


@property (nonatomic) RMPolylineAnnotation *polyline;

@end

@implementation MapBoxViewController

static BOOL isLocated = NO;

static const NSString *regEx = @"^[0-9].{3,20}(?:PARKING)(?!COMMERCIAL)\\s([0-9]{1,2}(?:AM|PM)?:?[0-9]{0,2}(?:AM|PM)?.(?:[0-9]{0,2}(?:AM|PM)?:?[0-9]{1,2}(?:AM|PM)?)?)\\s?(EXCEPT\\s\\w{3})";

-(void)loadView
{
    [super loadView];
    _source = [[RMMapboxSource alloc] initWithMapID:@"mapbox.pencil"];//andreittt.d6b9c478
    _mapView.tileSource = _source;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"iPark";
    _locationManager = [CLLocationManager new];
    self.locationManager.delegate = self;
    [self.locationManager requestAlwaysAuthorization];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = YES;
    
    _mapView.clusteringEnabled = YES;
    
    self.mapView.maxZoom = 18;
    self.mapView.minZoom = 7;
    
    isNavigationMode = NO;
    
    self.mapView.showLogoBug = NO;
    self.myLocationOutlet.layer.zPosition = 1000;
    
    
    
     _placesArray = [[NSMutableArray alloc]init];

}

- (void)viewDidAppear:(BOOL)animated
{
    
    
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserverForName:nil object:[Directions sharedManager] queue:nil usingBlock:^(NSNotification *note) {
        NSLog(@"%s", __FUNCTION__);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.mapView removeAllAnnotations];
            [[Directions sharedManager] requestRouteFrom:self.locationManager.location.coordinate to:finalDestination completition:^{
                [ANMapDrawer drawRouteOnMap:self.mapView];
            }];
        });
    }];
}




#pragma mark - RMMapViewDelegate
- (void)mapView:(RMMapView *)mapView didUpdateUserLocation:(RMUserLocation *)userLocation
{
    [[Directions sharedManager] checkRouteWith:userLocation.coordinate];
    [[Directions sharedManager] userEnterInto:userLocation.coordinate];
#warning = change for production
    [self.mapView setUserTrackingMode:RMUserTrackingModeFollowWithHeading animated:NO];
    if (!isLocated) {
        [self.mapView setCenterCoordinate:userLocation.coordinate];
        self.mapView.zoom = 12;
        isLocated = YES;
    }
}


- (RMMapLayer *)mapView:(RMMapView *)mapView layerForAnnotation:(RMAnnotation *)annotation
{
    if (annotation.isUserLocationAnnotation && ![annotation.userInfo isKindOfClass:[NSString class]]) {
        return nil;
    }
    
    if ([annotation.userInfo isKindOfClass:[NSString class]] && [annotation.userInfo isEqualToString:@"Border"]) {
        RMMapLayer *layer = [[RMMarker alloc] initWithMapboxMarkerImage:@"rocket"
                                                              tintColor:[UIColor magentaColor]];
        return layer;
    }
    
    if ([annotation.userInfo isEqualToString:@"saved spot"]) {
        RMMarker *marker = [[RMMarker alloc] initWithMapboxMarkerImage:@"rocket" tintColor:[UIColor grayColor]];
        return marker;
    }
    
    if ([annotation.userInfo isKindOfClass:[NSString class]]) {
        NSString *str = annotation.userInfo;
        
        RMMarker *marker;
        marker.canShowCallout = YES;
        
        if ([str isEqualToString:@"0"]) {
            marker = [[RMMarker alloc] initWithMapboxMarkerImage:@"rocket" tintColor:[UIColor blueColor]];
        }else if ([str isEqualToString:@"1"]) {
            marker = [[RMMarker alloc] initWithMapboxMarkerImage:@"rocket" tintColor:[UIColor greenColor]];
        }else{
            marker = [[RMMarker alloc] initWithMapboxMarkerImage:@"rocket" tintColor:[UIColor redColor]];
        }
        
        marker.canShowCallout = YES;
        return marker;
    }
    
    RMMapLayer *layer = [[RMMarker alloc] initWithMapboxMarkerImage:@"rocket"
                                                          tintColor:[UIColor colorWithRed:0.224
                                                                                    green:0.671
                                                                                     blue:0.780
                                                                                    alpha:1.0]];
    return layer;
}


- (void)longPressOnMap:(RMMapView *)map at:(CGPoint)point
{
    
    
    [self.mapView removeAllAnnotations];
    CLLocationDegrees latitude = [map pixelToCoordinate:point].latitude;
    CLLocationDegrees longitude = [map pixelToCoordinate:point].longitude;
    CLLocationCoordinate2D destination = CLLocationCoordinate2DMake(latitude, longitude);
    finalDestination = destination;
    
    [UIView animateWithDuration:0.4 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.mapView.zoom = 14;
        self.mapView.centerCoordinate = destination;
    } completion:^(BOOL finished) {
        [map addAnnotation:[RMAnnotation annotationWithMapView:self.mapView coordinate:destination andTitle:@"Destination"]];
        
        [self drawRadiusFor:[[CLLocation alloc] initWithLatitude:destination.latitude longitude:destination.longitude]];
    }];
}

- (void)drawRadiusFor:(CLLocation *)location
{
    NSLog(@"%s", __FUNCTION__);
    [ANMapDrawer objectsFor:self.mapView
                  withPoint:location.coordinate
                  competion:^(CLLocationDegrees minLatitude, CLLocationDegrees maxLatitude, CLLocationDegrees minLongitude, CLLocationDegrees maxLongitude) {
                      [DatabaseDriver sqlQueryWithMinLatitude:minLatitude
                                                  maxLatitude:maxLatitude
                                                 minLongitude:minLongitude
                                                 maxLongitude:maxLongitude
                                                enumerateWith:^(NSArray *signs) {
#ifndef DEBUG
                                                    if (!signs) {
                                                        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"No parking" message:@"There are no parking spots" preferredStyle:UIAlertControllerStyleAlert];
                                                        
                                                        UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                                                            [self.mapView removeAllAnnotations];
                                                            self.mapView.zoom = 12;
                                                            _mapView.centerCoordinate = self.locationManager.location.coordinate;
                                                            
                                                            return;
                                                        }];
                                                        
                                                        [alertController addAction:alertAction];
                                                        [self presentViewController:alertController animated:YES completion:nil]
                                                        
                                                    }
#endif
                                                    self.signs = [NSArray arrayWithArray:[ANMapMath arrayWithAvaliableParkingSlots:signs
                                                                                                                         withRegEx:regEx]];
                                                    
                                                    if ([self.signs count] > 0) [[Directions sharedManager] requestRouteFrom:self.locationManager.location.coordinate to:((Sign *)self.signs[0]).coordinate completition:^() {
                                                        [ANMapDrawer drawRouteOnMap:self.mapView];
                                                    }];
                                                    else
                                                        [[Directions sharedManager] requestRouteFrom:self.locationManager.location.coordinate to:location.coordinate completition:^() {
                                                            [ANMapDrawer drawRouteOnMap:self.mapView];
                                                        }];
                                                    
                                                    
                                                    
                                                } completion:^{
                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                        for (Sign *sign in self.signs) {
                                                            RMAnnotation *marker = [RMAnnotation annotationWithMapView:self.mapView
                                                                                                            coordinate:sign.coordinate
                                                                                                              andTitle:sign.signContent];
                                                            
                                                            marker.userInfo = [NSString stringWithFormat:@"%ld", (long)[sign isAvaliableForParking]];
                                                            [self.mapView addAnnotation:marker];
                                                        }
                                                    });
                                                }];
                      
                  }];
}


#pragma mark - handle memory warinngs
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (NSComparator)annotationSortingComparatorForMapView:(RMMapView *)RmapView
{
    NSComparator sort =^(RMAnnotation *annotation1, RMAnnotation *annotation2)
    {
        if (annotation1.isUserLocationAnnotation && !annotation2.isUserLocationAnnotation)
            return NSOrderedDescending;
        
        return NSOrderedSame;
    };
    return sort;
}

- (IBAction)startFollowHeading:(UIButton *)sender {
    if (isNavigationMode) {
        [self.mapView setUserTrackingMode:RMUserTrackingModeFollowWithHeading animated:YES];
        [sender setTitle:@"Stop" forState:UIControlStateNormal];
    }else {
        [self.mapView setUserTrackingMode:RMUserTrackingModeNone animated:YES];
        [sender setTitle:@"Start" forState:UIControlStateNormal];
    }
    isNavigationMode = !isNavigationMode;
}

- (IBAction)settingsAction:(id)sender {
    [self performSegueWithIdentifier:@"SettingsSegue" sender:self];
}

- (IBAction)mySpotAction:(id)sender {
    RMAnnotation *myParkingSpot = [RMAnnotation annotationWithMapView:self.mapView coordinate:self.locationManager.location.coordinate andTitle:@"My Spot"];
    
    myParkingSpot.userInfo = @"saved spot";
    
    [self.mapView addAnnotation:myParkingSpot];
}

- (IBAction)parkingSignsAroundMeAction:(id)sender {
    [self drawRadiusFor:self.locationManager.location];
}

- (IBAction)myLocation:(id)sender {
    [self.mapView setUserTrackingMode:RMUserTrackingModeNone animated:YES];
}

- (IBAction)customSearchButtonAction:(id)sender {
}

- (IBAction)microphoneAction:(id)sender {
}

- (void)viewWillDisappear:(BOOL)animated {
    
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self performSegueWithIdentifier:@"toNavigationDetailsSegue" sender:self];
    [self.searchBarAddressField endEditing:YES];
}



- (IBAction)currentLocation:(UIButton *)sender {
    NSLog(@"hey");
    
    [_placesClient currentPlaceWithCallback:^(GMSPlaceLikelihoodList *likelihoodList, NSError *error) {
        if (error != nil) {
            NSLog(@"Current Place error %@", [error localizedDescription]);
            return;
        }
        
        for (GMSPlaceLikelihood *likelihood in likelihoodList.likelihoods) {
            GMSPlace* place = likelihood.place;
            NSLog(@"Current Place name %@ at likelihood %g", place.name, likelihood.likelihood);
            NSLog(@"Current Place address %@", place.formattedAddress);
            NSLog(@"Current Place attributions %@", place.attributions);
            NSLog(@"Current PlaceID %@", place.placeID);
        }
        
    }];

}
@end
