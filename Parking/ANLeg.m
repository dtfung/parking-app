//
//  ANLeg.m
//  Parking
//
//  Created by Aditya Narayan on 4/28/15.
//  Copyright (c) 2015 DDCorp. All rights reserved.
//

#import "ANLeg.h"
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>
#import "NSMutableArray_RemoveFirstObject.h"
#import <AVFoundation/AVSpeechSynthesis.h>
#import <CoreLocation/CoreLocation.h>

@interface ANLeg () <NSCopying> {
    BOOL isDirectionVoiced;
    BOOL isManeuverVoiced;
}

@property (nonatomic) NSMutableArray *steps;

@end
@implementation ANLeg

- (instancetype)init
{
    if (self = [super init]) {
        _steps = [NSMutableArray new];
        
        isDirectionVoiced = NO;
        isManeuverVoiced = NO;
    }
    
    return self;
}

- (id)initWithArray:(NSArray *)array
{
    if (self = [super init]) {
        _steps = [NSMutableArray arrayWithArray:array];
    }
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    ANLeg *leg = [[ANLeg alloc] initWithArray:self.steps];
    leg.voiceDirection = self.voiceDirection;
    leg.maneuver = self.maneuver;
    leg.startRegion = self.startRegion;
    leg.endRegion = self.endRegion;
    
    return leg;
}

//Override Setter
- (void)setVoiceDirection:(NSString *)voiceDirection
{
    _voiceDirection = [self stringByStrippingHTML:voiceDirection];
}

//Override Setter
- (void)setManeuver:(NSString *)maneuver
{
    _maneuver = [self stringByStrippingHTML:maneuver];
}


- (NSArray *)getSteps
{
    return _steps;
}

- (NSArray *)addStepWith:(double)latitude and:(double)longitude
{
    [self.steps addObject:[[CLLocation alloc] initWithLatitude:latitude longitude:longitude]];
    
    return self.steps;
}

- (void)removeLastStep
{
    [self.steps removeFirstObject];
}

- (void)removeStepsIn:(NSRange)range
{
    [self.steps removeObjectsInRange:range];
}


- (NSString *)stringByStrippingHTML:(NSString*)originalString {
    NSRange range;
    NSString *tempString = [originalString copy];
    while ((range = [tempString rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound) {
        tempString = [tempString stringByReplacingCharactersInRange:range withString:@""];
    }
    
    NSString *searchedString = tempString;
    NSRange  searchedRange = NSMakeRange(0, [searchedString length]);
    NSString *pattern = @".*(\\d{1,2}\\w{1,2}\\sAve/).*(StDestination)?";
    NSError  *error = nil;
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:&error];
    NSTextCheckingResult *match = [regex firstMatchInString:searchedString options:0 range:searchedRange];
    searchedString = [searchedString stringByReplacingCharactersInRange:[match rangeAtIndex:1] withString:@" "];
    
    
    searchedString = [searchedString stringByReplacingOccurrencesOfString:@" W " withString:@" West "];
    searchedString = [searchedString stringByReplacingOccurrencesOfString:@" E " withString:@" East "];
    
    searchedString = [searchedString stringByReplacingOccurrencesOfString:@" Ave" withString:@" Avenue "];
    
    searchedString = [searchedString stringByReplacingOccurrencesOfString:@"Destination " withString:@" Destination "];
    searchedString = [searchedString stringByReplacingOccurrencesOfString:@" St" withString:@" Street "];
    
    
    //    NSLog(@"%@", searchedString);
    
    return searchedString;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"Start Region: %@ - End Region: %@", _startRegion, _endRegion];
}


@end
