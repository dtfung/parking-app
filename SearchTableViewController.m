//
//  NavigationDetailsViewController.m
//  Parking
//
//  Created by Degerhan Deger on 5/6/15.
//  Copyright (c) 2015 DDCorp. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "SearchTableViewController.h"
#import "Address.h"
#import "MapSharedMethod.h"


@interface SearchTableViewController ()  <UISearchResultsUpdating, UISearchDisplayDelegate, UISearchBarDelegate, UISearchControllerDelegate>

//@property (nonatomic, strong) CLGeocoder *geocoder;
@property (nonatomic, strong) CLCircularRegion *region;

//changed from NSArray
@property (nonatomic)  NSMutableArray *contentArray;

@property (nonatomic, strong) UISearchController *searchController;

@end

@implementation SearchTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Navigate";
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    _searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.delegate = self;
    self.searchController.searchBar.delegate = self;
    self.view.tintColor = [UIColor redColor];
    self.searchController.searchResultsUpdater = self;
    [self.searchController.searchBar sizeToFit];
    self.searchController.dimsBackgroundDuringPresentation = NO;
    
    self.tableView.tableHeaderView = self.searchController.searchBar;
    
    self.definesPresentationContext = YES;
    
    //_geocoder = [CLGeocoder new];
    _placesClient = [GMSPlacesClient sharedClient];
    _contentArray = [[NSMutableArray alloc]init];
    _coordinates = [[NSMutableArray alloc]init];
     
    
    _region = [[CLCircularRegion alloc] initWithCenter:CLLocationCoordinate2DMake(40.759211, -73.984638) radius:10000 identifier:@"New York"];
}

- (void)viewWillAppear:(BOOL)animated {
    
    
    [super viewWillAppear:animated];
    self.navigationItem.hidesBackButton = NO;
    self.navigationController.navigationBarHidden = NO;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.contentArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"navigationVCCell"];
    
    cell.textLabel.attributedText = [self.contentArray[indexPath.row]valueForKey:@"_attributedFullText"];
    cell.detailTextLabel.text = nil;
    cell.imageView.image = [UIImage imageNamed:@"mySpot"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Edited slightly to exclude a key path.  
//    [self.navigationController.viewControllers[0] performSelector:@selector(drawRadiusFor:)
//                                                       withObject:self.contentArray[indexPath.row]];
    
////    [self.navigationController.viewControllers[0] performSelector:@selector(drawRadiusFor:)
//                                                       withObject:[self.contentArray[indexPath.row] valueForKey:@"location"]];
    
    
    NSString *placeID = [_contentArray[indexPath.row]valueForKey:@"_placeID"];
    
    [_placesClient lookUpPlaceID:placeID callback:^(GMSPlace *place, NSError *error) {
        if (error != nil) {
            NSLog(@"Autocomplete error %@", [error localizedDescription]);
            return;
        }
        else {
            NSLog(@"%f", place.coordinate.latitude);
            NSLog(@"%f", place.coordinate.longitude);
            
            
            [self.coordinates addObject:place];
        }
    }];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
    
}

#pragma mark - UISearchControllerDelegate & UISearchResultsDelegate
// Called when the search bar becomes first responder
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    [self.contentArray removeAllObjects];
    [self.tableView reloadData];
    
    //a string to store the user input
    NSString *string = searchController.searchBar.text;
    
    if ([searchController.searchBar.text length] != 0)
    {
        
        
//        GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithCoordinate:visibleRegion.farLeft
//                                                                           coordinate:visibleRegion.nearRight];
        
        
        //A class representing a set of restrictions that could be placed on the search
        GMSAutocompleteFilter *filter = [[GMSAutocompleteFilter alloc] init];
        filter.type = kGMSPlacesAutocompleteTypeFilterNoFilter;
        
        
        [_placesClient autocompleteQuery:string
                                  bounds:nil
                                  filter:nil
                                callback:^(NSArray *results, NSError *error) {
                                    if (error != nil) {
                                        NSLog(@"Autocomplete error %@", [error localizedDescription]);
                                        return;
                                    }
                                    else {
                                        //added this dictionary to store the results of each search
                                        for (GMSAutocompletePrediction* result in results) {
                                            [_contentArray addObject: result];
                                            [self.tableView reloadData];
                                        
                                        }
                                    }
                                }];
        
    }
    
    
    //
    //    if ([searchController.searchBar.text length] != 0)
    //        [self.geocoder geocodeAddressString:searchController.searchBar.text completionHandler:^(NSArray *placemarks, NSError *error) {
    //            if (error.code == kCLErrorGeocodeFoundPartialResult) {
    //                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error" message:error.localizedDescription preferredStyle:UIAlertControllerStyleActionSheet];
    //                UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
    //                [alertController addAction:okAction];
    //                [self presentViewController:alertController animated:YES completion:nil];
    //            }else {
    //                self.contentArray = placemarks;
    //
    //                [self.tableView reloadData];
    //            }
    //        }];
    
}




//- (void)searchWith:(UISearchController *)searchController
//{
//    // update the filtered array based on the search text
//    NSString *searchText = searchController.searchBar.text;
//    NSMutableArray *searchResults = [self.contentArray mutableCopy];
//
//    // strip out all the leading and trailing spaces
//    NSString *strippedString = [searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
//
//    // break up the search terms (separated by spaces)
//    NSArray *searchItems = nil;
//    if (strippedString.length > 0) {
//        searchItems = [strippedString componentsSeparatedByString:@" "];
//    }
//
//    // build all the "AND" expressions for each value in the searchString
//    NSMutableArray *andMatchPredicates = [NSMutableArray array];
//
//    for (NSString *searchString in searchItems) {
//        // each searchString creates an OR predicate for: name, yearIntroduced, introPrice
//
//        NSMutableArray *searchItemsPredicate = [NSMutableArray array];
//
//        // Below we use NSExpression represent expressions in our predicates.
//        // NSPredicate is made up of smaller, atomic parts: two NSExpressions (a left-hand value and a right-hand value)
//
//        // name field matching
//        NSExpression *lhs = [NSExpression expressionForKeyPath:@"name"];
//        NSExpression *rhs = [NSExpression expressionForConstantValue:searchString];
//        NSPredicate *finalPredicate = [NSComparisonPredicate
//                                       predicateWithLeftExpression:lhs
//                                       rightExpression:rhs
//                                       modifier:NSDirectPredicateModifier
//                                       type:NSContainsPredicateOperatorType
//                                       options:NSCaseInsensitivePredicateOption];
//        [searchItemsPredicate addObject:finalPredicate];
//
//        // at this OR predicate to our master AND predicate
//        NSCompoundPredicate *orMatchPredicates = [NSCompoundPredicate orPredicateWithSubpredicates:searchItemsPredicate];
//        [andMatchPredicates addObject:orMatchPredicates];
//    }
//
//    // match up the fields of the Product object
//    NSCompoundPredicate *finalCompoundPredicate =
//    [NSCompoundPredicate andPredicateWithSubpredicates:andMatchPredicates];
//    searchResults = [[searchResults filteredArrayUsingPredicate:finalCompoundPredicate] mutableCopy];
//}

@end
