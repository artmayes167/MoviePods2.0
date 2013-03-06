//
//  AMEpisodeViewController.h
//  MoviePods
//
//  Created by Arthur Mayes on 2/27/13.
//  Copyright (c) 2013 Arthur Mayes. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AMEpisodeViewController : UIViewController{
    BOOL isPlaying;
    BOOL wait;
    BOOL sliderMoved;
    BOOL sliderViewIsVisible;
    BOOL playerExists;
    NSTimer *playTimer;
}
@property (nonatomic) int currentPodcast;
@property (nonatomic, strong) NSDictionary *episode;
@end
