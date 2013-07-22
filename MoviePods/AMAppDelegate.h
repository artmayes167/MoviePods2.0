//
//  AMAppDelegate.h
//  MoviePods
//
//  Created by Arthur Mayes on 2/26/13.
//  Copyright (c) 2013 Arthur Mayes. All rights reserved.
//

#import "AMInitiateDownload.h"

@interface AMAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

// This is a goofy way to pass information, but I don't feel like changing it
@property (nonatomic) int podcastToShow, windowHeight;
@property (nonatomic) BOOL enteringForeground;
@property (nonatomic) BOOL wifi;

+ (AMAppDelegate *)sharedAppDelegate;
@end
