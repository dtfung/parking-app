//
//  ANMapMath.m
//  Parking
//
//  Created by Andrei Nechaev on 3/24/15.
//  Copyright (c) 2015 ParkingApp. All rights reserved.
//

#import "ANMapMath.h"
#import "Sign.h"
#import "ParkingRuleComposer.h"

@implementation ANMapMath

+ (BOOL)isMarker:(CLLocationCoordinate2D)firstPoint contains:(CLLocationCoordinate2D)secondPoint inRadius:(double)R
{
    double long_distance = firstPoint.longitude - secondPoint.longitude;
    double lat_distance = firstPoint.latitude - secondPoint.latitude;
    
    if ((long_distance > - R && long_distance < R) && (lat_distance > - R && lat_distance < R)) {
        return YES;
    }
    
    return NO;
}

+ (double)isOnOneLine:(CLLocationCoordinate2D)firstPoint with:(CLLocationCoordinate2D)secondPoint and:(CLLocationCoordinate2D)thirdPoint {
    double FACTOR = 10000;
    double firstOperand  = firstPoint.latitude * secondPoint.longitude * FACTOR;
    double secondOperand = firstPoint.longitude * thirdPoint.latitude * FACTOR;
    double thirdOperand  = secondPoint.latitude * thirdPoint.longitude * FACTOR;
    
    double forthOperand = secondPoint.longitude * thirdPoint.latitude * FACTOR;
    double fifthOperand = firstPoint.longitude * secondPoint.latitude * FACTOR;
    double sixthOperand = thirdPoint.longitude * firstPoint.latitude * FACTOR;
    
    double answ = firstOperand + secondOperand + thirdOperand - forthOperand - fifthOperand - sixthOperand;
    
    //    NSLog(@"MATRIX SAID - %f", answ);
    
    return answ;
}

+ (NSArray *)arrayWithAvaliableParkingSlots:(NSArray *)signs withRegEx:(const NSString *)regEx
{
    NSMutableArray *avaliableSlots = [NSMutableArray new];
    NSMutableArray *tmpArray = [NSMutableArray new];
    
    for (Sign *f_sign in signs) {
        if ([self regexFor:f_sign with:regEx] > 0) {
            for (Sign *s_sign in signs) {
                if ([ANMapMath isMarker:CLLocationCoordinate2DMake(f_sign.latitude, f_sign.longitude)
                                contains:CLLocationCoordinate2DMake(s_sign.latitude, s_sign.longitude)
                             inRadius:0.001] && [f_sign.signContent isEqualToString:s_sign.signContent])
                {
                    [tmpArray addObject:s_sign];
                }
            }
            if ([tmpArray count] > [avaliableSlots count]) {
                [avaliableSlots removeAllObjects];
                [avaliableSlots addObjectsFromArray:tmpArray];
            }
            [tmpArray removeAllObjects];
        }
    }
    
    return avaliableSlots;
}

+ (NSInteger)regexFor:(Sign*)sign with:(const NSString *)pattern
{
    NSString *signCtnt = sign.signContent;
    
    
    NSDateFormatter *formatter = [NSDateFormatter new];
    
    NSRange mainRange = NSMakeRange(0, [signCtnt length]);
    NSError *error;
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:[pattern copy] options:0 error:&error];
    
    NSArray *regArr = [regex matchesInString:signCtnt options:0 range:mainRange];
    
    for (NSTextCheckingResult *match in regArr) {
        for (int i = 1; i < match.numberOfRanges; i++) {
            NSRange currentRange = [match rangeAtIndex:i];
            if (currentRange.location != NSNotFound) {
                NSString *pop = [signCtnt substringWithRange:currentRange];
                
                NSArray *arr = [ParkingRuleComposer parseTimeFrom:pop withDate:formatter];
                if (arr) {
                    for (id time in arr) {
//                        NSLog(@"%@", [formatter stringFromDate:time]);
                        [sign addTime:time];
                    }
                }
            }
        }
    }
    
    return [regArr count];
}

@end
