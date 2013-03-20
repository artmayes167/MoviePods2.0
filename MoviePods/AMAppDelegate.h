//
//  AMAppDelegate.h
//  MoviePods
//
//  Created by Arthur Mayes on 2/26/13.
//  Copyright (c) 2013 Arthur Mayes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AMInitiateDownload.h"

@interface AMAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic) int podcastToShow, windowHeight;
@property (nonatomic) BOOL enteringForeground;
@property (nonatomic) BOOL wifi;
@end
