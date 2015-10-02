//
//  ANDirectionPlayer.h
//  Parking
//
//  Created by Aditya Narayan on 5/22/15.
//  Copyright (c) 2015 DDCorp. All rights reserved.
//

#import <Foundation/Foundation.h>
@class AVSpeechSynthesizer;
@class ANLeg;

extern NSString *const ANVoiceDirectionString;
extern NSString *const ANVoiceManeuverString;

@interface ANDirectionPlayer : NSObject

@property (nonatomic, strong) NSDictionary *directionTracks;

- (void)playDirectionsWith:(ANLeg *)leg keyPath:(NSString *)path;
- (BOOL)isPlayed:(NSString *)track;
- (void)clear;

@end
