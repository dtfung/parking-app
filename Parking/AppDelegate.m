//
//  AppDelegate.m
//  Parking
//
//  Created by Aditya Narayan on 12/3/14.
//  Copyright (c) 2014 DDCorp. All rights reserved.
//

#import "AppDelegate.h"
#import "RMConfiguration.h"
#import <GoogleMaps/GoogleMaps.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [GMSServices provideAPIKey:@"AIzaSyCBaEzpKSyc29cZSUZaEwYcNKUhtVofJEA"];
    
    [[RMConfiguration sharedInstance] setAccessToken:@"pk.eyJ1IjoiYW5kcmVpdHR0IiwiYSI6IlF1akE4X0EifQ.n9_SJAb69FVRQ4w01GLGdA"];
    
    NSURLResponse *response;
    NSError *error;

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
    UIViewController *mainViewController;
    
    [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://google.com"]] returningResponse:&response error:&error];
    
    if (!error) {
        mainViewController = [storyboard instantiateViewControllerWithIdentifier:@"MainNavigationVC"];
    }else {
        mainViewController = [storyboard instantiateViewControllerWithIdentifier:@"Error"];
        [mainViewController setValue:error.localizedDescription forKeyPath:@"error"];
    }
    
    NSLog(@"%@", error.localizedDescription);
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = mainViewController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
