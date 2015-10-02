//
//  ANLeg.h
//  Parking
//
//  Created by Andrei Nechaev on 4/28/15.
//  Copyright (c) 2015 ParkingApp. All rights reserved.


#import <Foundation/Foundation.h>
@class CLCircularRegion;
@class AVSpeechSynthesizer;

@interface ANLeg : NSObject

@property (nonatomic) NSString *voiceDirection;
@property (nonatomic) NSString *maneuver;
//@property (nonatomic, assign, readonly) NSUInteger stepsAmount;
@property (nonatomic) CLCircularRegion *startRegion;
@property (nonatomic) CLCircularRegion *endRegion;

- (id)initWithArray:(NSArray *)array;
- (NSArray *)getSteps;
- (NSArray *)addStepWith:(double)latitude and:(double)longitude;
- (void)removeLastStep;

- (void)removeStepsIn:(NSRange)range;

@end
