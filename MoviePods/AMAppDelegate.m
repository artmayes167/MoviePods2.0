//
//  AMAppDelegate.m
//  MoviePods
//
//  Created by Arthur Mayes on 2/26/13.
//  Copyright (c) 2013 Arthur Mayes. All rights reserved.
//

#import "AMAppDelegate.h"
#import "GetKeyStrings.h"
#import "AMDownloadClient.h"
#import "AMAllPodsCollectionViewController.h"

@interface AMAppDelegate ()<AMIniateDownloadsDelegate>

@end

@implementation AMAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSString *defaultPrefsFile = [[NSBundle mainBundle] pathForResource:@"defaultPreferences" ofType:@"plist"];
    NSDictionary *defaultPreferences = [NSDictionary dictionaryWithContentsOfFile:defaultPrefsFile];
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultPreferences];
    
    [AMInitiateDownload sharedInitiator].delegate = self;
    self.windowHeight = self.window.bounds.size.height;
    //NSLog(@"windowHeight = %i", self.windowHeight);
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    self.enteringForeground = YES;
    self.enteringForeground = NO;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    for (int i = 0; i < PODCAST_COUNT; ++i) {
        NSString *pathStarter = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        NSString *path = [pathStarter stringByAppendingPathComponent:[[GetKeyStrings sharedKeyStrings]addressAtIndex:i]];
        [fileManager removeItemAtPath:path error:&error];
    }
}


@end
