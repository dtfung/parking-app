//
//  NavigationDetailsViewController.h
//  Parking
//
//  Created by Degerhan Deger on 5/6/15.
//  Copyright (c) 2015 DDCorp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>
#import "MapBoxViewController.h"

@interface SearchTableViewController : UITableViewController

@property (nonatomic, retain) GMSPlacesClient *placesClient;
@property (nonatomic, strong) MapBoxViewController *mapboxController;
@property (nonatomic, strong) NSMutableArray *coordinates;
@end
