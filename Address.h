//
//  Address.h
//  Parking
//
//  Created by Aditya Narayan on 5/12/15.
//  Copyright (c) 2015 DDCorp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Address : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *administrativeArea;

- (id)initWith:(NSString *)address;
+ (id)addressWith:(NSString *)string;

@end
