//
//  Driver.m
//  Parking
//
//  Created by Aditya Narayan on 12/3/14.
//  Copyright (c) 2014 DDCorp. All rights reserved.
//

#import "DatabaseDriver.h"
#import "Sign.h"

@interface DatabaseDriver () {
    NSString *dbPathString;
}

@end

@implementation DatabaseDriver
static NSString *dbName = @"testParking.db";

#pragma mark - DB Access

+ (void)sqlQueryWithMinLatitude:(double)minLat
                    maxLatitude:(double)maxLat
                   minLongitude:(double)minLong
                   maxLongitude:(double)maxLong
                          enumerateWith:(void(^)(NSArray *signs))block
                     completion:(void(^)())handler
{
//    NSLog(@"%.8f, %.8f, %.8f, %.8f", minLat, maxLat, minLong, maxLong);
    
    sqlite3 *navControlDB;
    NSString *dbPathString;
    
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [path objectAtIndex:0];
    
    dbPathString = [docPath stringByAppendingPathComponent:dbName];
    
    NSURL *sourcePath = [[[NSBundle mainBundle] resourceURL] URLByAppendingPathComponent:dbName];
    NSError *error;
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:dbPathString])
    {
        [[NSFileManager defaultManager] copyItemAtURL:sourcePath toURL:[NSURL fileURLWithPath:dbPathString] error:&error];
    }else {
        [sourcePath setResourceValue:@YES forKey:NSURLIsExcludedFromBackupKey error:&error];
        if (!error) {
            NSLog(@"str - %@", sourcePath);
        }else {
            NSLog(@"%@", error.localizedDescription);
        }

    }
    
    sqlite3_stmt *statement;
    
    if (sqlite3_open([dbPathString UTF8String], &navControlDB) == SQLITE_OK)
    {
        //Run query for visible signIDs
        NSString *queryDistinctVisibleSignIDs = [NSString stringWithFormat:@"select signID, latitude, longitude, signContent from parkingRegulations where latitude > %f AND latitude < %f AND longitude > %f AND longitude < %f", minLat, maxLat, minLong, maxLong];
        
        const char *query_company_sql = [queryDistinctVisibleSignIDs UTF8String];

        if (sqlite3_prepare(navControlDB, query_company_sql, -1, &statement, NULL) == SQLITE_OK)
        {
            
            NSMutableArray *signs = [NSMutableArray new];
            
            while (sqlite3_step(statement)== SQLITE_ROW)
            {
                NSString *distinctVisibleSignID = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 0)];
                NSString *latitude = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 1)];
                NSString *longitude = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 2)];
                NSString *signContent = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 3)];
                
                signContent = [signContent stringByReplacingOccurrencesOfString:@"MIDNIGHT" withString:@"12AM"];
                
                [signs addObject:[[Sign alloc] initWithID:distinctVisibleSignID
                                                 withSign:signContent
                                             withLocation:CLLocationCoordinate2DMake([latitude doubleValue], [longitude doubleValue])]];
            }
            
            block(signs);
        }else {
            block(nil);
        }
    }
    handler();
    sqlite3_close(navControlDB);
}

@end