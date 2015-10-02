//
//  NSMutableArray_RemoveFirstObject.m
//  Parking
//
//  Created by Andrei Nechaev on 4/29/15.
//  Copyright (c) 2015 ParkingApp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSMutableArray_RemoveFirstObject.h"

@implementation NSMutableArray (RemoveFirstObject)

- (void)removeFirstObject
{
    if ([self count] > 0) {
        [self removeObjectAtIndex:0];
    }
}


@end