//
//  AppDelegate.m
//  OSUMobileCloudAssignment4
//
//  Created by Colin Smith on 7/18/15.
//  Copyright (c) 2015 Colin Smith. All rights reserved.
//

#import "AppDelegate.h"
#import "OSUMainScreenViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import <BZFoursquare.h>

@interface AppDelegate ()

@property (strong, nonatomic) OSUMainScreenViewController *rootViewController;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [GMSServices provideAPIKey:@"AIzaSyAix-aX1qwizR0IZGKKM2y1-do-tHQTBtg"];
    self.rootViewController = [[OSUMainScreenViewController alloc] initWithNibName:nil bundle:nil];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = self.rootViewController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    BZFoursquare *foursquare = self.rootViewController.myFourSquare;
    return [foursquare handleOpenURL:url];
}

@end
