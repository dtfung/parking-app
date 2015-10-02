//
//  Directions.m
//  Parking
//
//  Created by Degerhan Deger on 3/8/15.
//  Copyright (c) 2015 DDCorp. All rights reserved.
//

#import "Directions.h"
#import <AVFoundation/AVSpeechSynthesis.h>
#import "ANLeg.h"
#import "NSMutableArray_RemoveFirstObject.h"
#import "ANDirectionPlayer.h"

NSString * const DirectionNotificationUserOnRoad = @"DirectionNotificationUserOnRoad";
NSString * const DirectionNotificationUserOutOfRoad = @"DirectionNotificationUserOutOfRoad";

@interface Directions ()

@property (atomic) NSMutableArray *legs;
@property (nonatomic, strong)ANDirectionPlayer * directionPlayer;
@property (nonatomic) dispatch_queue_t userTrackingQueue;

@end
@implementation Directions

+ (id)sharedManager {
    static Directions *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] initHidden];
    });
    
    return sharedMyManager;
}

- (id)init
{
    NSException *exception = [NSException exceptionWithName:@"Singleton" reason:@"Use +(id)sharedInstance instead" userInfo:nil];
    
    [exception raise];
    
    return nil;
}

- (id)initHidden
{
    if (self = [super init]) {
        _legs = [NSMutableArray new];
        _userTrackingQueue = dispatch_queue_create("userTracking", NULL);
        _directionPlayer = [ANDirectionPlayer new];
    }
    
    return self;
}

#pragma to do: - pass duration form google API to block for approximate time
- (void)requestRouteFrom:(CLLocationCoordinate2D)original to:(CLLocationCoordinate2D)destination completition:(void(^)(void))handler
{
    [_legs removeAllObjects];
    
    NSString *requestString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/directions/json?origin=%f,%f&destination=%f,%f&sensor=false", original.latitude, original.longitude, destination.latitude, destination.longitude];

    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:requestString]];

    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {

        if (!error && (response != nil)) {
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
            
            if ([NSJSONSerialization isValidJSONObject:json] && !error) {
                NSArray *routes = json[@"routes"];
                if ([routes count] == 0) {
                    return;
                }
                if (!(self.currentDay = [self adjustTimeWith:routes])) {
                    self.currentDay = [NSDate date];
                }
                NSArray *arr = routes[0][@"legs"][0][@"steps"];
                

                int index = 0;
                
                for (NSDictionary *polylineDict in arr) {
                    NSString *points = polylineDict[@"polyline"][@"points"];
                    NSArray *tmp = [self parsePolylaneFromString:points];

                    
                    ANLeg *leg = [[ANLeg alloc] initWithArray:tmp];
                    
                    if (index > 0) {
                        ((ANLeg *)_legs[index-1]).maneuver = [arr valueForKey:@"html_instructions"][index];
//                        NSLog(@"%@", ((ANLeg *)_legs[index-1]).maneuver);
                    }else {
                        leg.voiceDirection = [arr valueForKey:@"html_instructions"][index];
                    }

                    CLLocationCoordinate2D startLocation;
                    startLocation.latitude = [routes[0][@"legs"][0][@"steps"][index][@"start_location"][@"lat"] doubleValue];
                    startLocation.longitude = [routes[0][@"legs"][0][@"steps"][index][@"start_location"][@"lng"] doubleValue];

                    CLLocationCoordinate2D endLocation;
                    endLocation.latitude = [routes[0][@"legs"][0][@"steps"][index][@"end_location"][@"lat"] doubleValue];
                    endLocation.longitude = [routes[0][@"legs"][0][@"steps"][index][@"end_location"][@"lng"] doubleValue];

                    leg.startRegion = [[CLCircularRegion alloc] initWithCenter:startLocation radius:45 identifier:[NSString stringWithFormat:@"%d", index]];
                    leg.endRegion = [[CLCircularRegion alloc] initWithCenter:endLocation radius:75 identifier:[NSString stringWithFormat:@"%d", index+100]];
                    
                    [_legs addObject:leg];
                    
                    ++index;
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    handler();
                });
            }
        }
    }] resume];
}

- (NSDate *)adjustTimeWith:(NSArray *)array {
    if (!array) return nil;
    
    NSString *timeString = array[0][@"legs"][0][@"duration"][@"text"];
    
    if ([timeString containsString:@"hours"]) {
        timeString = [timeString stringByReplacingOccurrencesOfString:@" hours " withString:@":"];
    } else if ([timeString containsString:@"hour"]) {
        timeString = [timeString stringByReplacingOccurrencesOfString:@" hour " withString:@":"];
    }
    
    if ([timeString containsString:@"mins"]) {
        timeString = [timeString stringByReplacingOccurrencesOfString:@" mins" withString:@""];
    } else if ([timeString containsString:@"min"]) {
        timeString = [timeString stringByReplacingOccurrencesOfString:@" min" withString:@""];
    }
    
    NSArray *strings = [[NSArray alloc] initWithArray:[timeString componentsSeparatedByString:@":"]];
    
    NSDate *adjustedDate = [NSDate date];
    
    if (strings.count == 1) {
        adjustedDate = [adjustedDate dateByAddingTimeInterval:[strings[0] intValue] * 60];
    } else {
        adjustedDate = [adjustedDate dateByAddingTimeInterval:[strings[0] intValue] * 3600 + [strings[1] intValue] * 60];
    }
    
    return adjustedDate;
}

- (NSArray *)getRouteFromLegs
{
    NSMutableArray *arr = [NSMutableArray new];
    for (ANLeg *leg in [self.legs mutableCopy]) {
        [arr addObjectsFromArray:[leg getSteps]];
    }
    
    return arr;
}

- (BOOL)userEnterInto:(CLLocationCoordinate2D)coordinate
{
    ANLeg *leg = self.legs.firstObject;
    
    if ([leg.startRegion containsCoordinate:coordinate]) {
        [self.directionPlayer playDirectionsWith:leg keyPath:ANVoiceDirectionString];
    }

    if ([leg.endRegion containsCoordinate:coordinate]) {
        [self.directionPlayer playDirectionsWith:leg keyPath:ANVoiceManeuverString];
        [self.legs removeFirstObject];
    }
    
    if ([self.legs count] == 0) [self.directionPlayer clear];

    return NO;
}

- (BOOL)checkRouteWith:(CLLocationCoordinate2D)coordinate
{
    dispatch_async(self.userTrackingQueue, ^{
    
    CLCircularRegion *region = [[CLCircularRegion alloc] initWithCenter:coordinate
                                                                 radius:55
                                                             identifier:@"UserRegion"];

        ANLeg *leg = self.legs.firstObject;
        for (CLLocation *location in leg.getSteps) {
            if ([region containsCoordinate:location.coordinate]) {
                return;
            }
        }

        if ([[leg getSteps] count] > 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:DirectionNotificationUserOutOfRoad object:self];
            });
        }
        
    });
    return NO;
}


- (NSArray *)parsePolylaneFromString:(NSString *)points
{
    
    NSMutableArray *polylines = [NSMutableArray new];
    NSInteger index = 0;
    NSUInteger length = [points length]; //Length of string with waypoints
    
    NSInteger latitude = 0;
    NSInteger longitude = 0;
    
    while (index < length) {
        NSInteger b, shift = 0, result = 0;
        
        do {
            b = [points characterAtIndex:(index++)] - 63; //getting a number from a char
            result |= (b & 0x1f) << shift;
            shift += 5;
        } while(b >= 0x20); // looking for a blank symbol
        
        NSInteger dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
        latitude += dlat;
    
        shift = 0;
        result = 0;
        
        do {
            b = [points characterAtIndex:(index++)] - 63;
            result |= (b & 0x1f) << shift;
            shift += 5;
        } while(b >= 0x20); // looking for a blank symbol
        
        NSInteger dlong = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
        longitude += dlong;
        
        CLLocation *location = [[CLLocation alloc] initWithLatitude:((double)latitude / 1e5) longitude:((double)longitude /1e5)];
        
        [polylines addObject:location];
    }
    //    NSLog(@"%ld", (unsigned long)[polylines count]);
    return polylines;
}

@end
