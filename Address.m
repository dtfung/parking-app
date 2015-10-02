//
//  Address.m
//  Parking
//
//  Created by Aditya Narayan on 5/12/15.
//  Copyright (c) 2015 DDCorp. All rights reserved.
//

#import "Address.h"

@implementation Address

- (instancetype)init
{
    if (self = [super init]) {
        _name = @"unsef";
    }
    
    return self;
}

- (id)initWith:(NSString *)address
{
    if (self = [super init]) {
        _name = address;
    }
    
    return self;
}

+ (id)addressWith:(NSString *)string
{
    return [[Address alloc] initWith:string];
}

@end
