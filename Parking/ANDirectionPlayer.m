//
//  ANDirectionPlayer.m
//  Parking
//
//  Created by Aditya Narayan on 5/22/15.
//  Copyright (c) 2015 DDCorp. All rights reserved.
//

#import "ANDirectionPlayer.h"
#import <AVFoundation/AVSpeechSynthesis.h>
#import "ANLeg.h"

NSString *const ANVoiceDirectionString = @"voiceDirection";
NSString *const ANVoiceManeuverString = @"maneuver";

@interface ANDirectionPlayer ()

@property (nonatomic, strong) NSMutableArray *playedDirections;
@property (nonatomic, strong) AVSpeechSynthesizer *speechSynthesizer;

@end

@implementation ANDirectionPlayer

- (instancetype)init
{
    if (self = [super init]) {
        _playedDirections = [NSMutableArray new];
        _speechSynthesizer = [AVSpeechSynthesizer new];
    }
    
    return self;
}

- (void)playDirectionsWith:(ANLeg *)leg keyPath:(NSString *)path
{
    NSString *value = [leg valueForKey:path];
    NSLog(@"%@", value);
    if (!value || [self isPlayed:value]) return;
    [self.playedDirections removeLastObject];
    [self.playedDirections addObject:value];
    AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:value];
    utterance.rate = AVSpeechUtteranceMinimumSpeechRate;
    
    [self.speechSynthesizer speakUtterance:utterance];
}

- (BOOL)isPlayed:(NSString *)track
{
    if ([self.playedDirections containsObject:track]) return YES;
    
    return NO;
}

- (void)clear
{
    [self.playedDirections removeAllObjects];
}

@end
