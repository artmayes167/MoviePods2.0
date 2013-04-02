//
//  AMCustomHeaderView.m
//  MoviePods
//
//  Created by Arthur Mayes on 3/15/13.
//  Copyright (c) 2013 Arthur Mayes. All rights reserved.
//
#import "AMAppDelegate.h"
#import "AMCustomHeaderView.h"
#import "GetAndSaveData.h"
#import "GetKeyStrings.h"

@implementation AMCustomHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.height = frame.size.height;
        self.width = frame.size.width;
        
        AMAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        self.podcastToLoad = appDelegate.podcastToShow;
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
 UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.width, self.height)];//90.0)];
 headerView.backgroundColor = [UIColor blackColor];
 
 UIImage *podcasterImage = [UIImage imageNamed:[[GetKeyStrings sharedKeyStrings]imageNameAtIndex:self.podcastToLoad]];
 
 UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.width/3, self.height)];//90.0f)];
 imageView.image = podcasterImage;
 [headerView addSubview:imageView];
 
 CGRect contentRect = headerView.bounds;
 UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(self.width/3+5, 0.0f, contentRect.size.width - self.width/3-5, contentRect.size.height)];
 
 NSDictionary *podcastDictionary;
 if ([[GetAndSaveData sharedGetAndSave]arrayOfParsedNamesFeeds]) {
 podcastDictionary = [[GetAndSaveData sharedGetAndSave]arrayOfParsedNamesFeeds][self.podcastToLoad];
 } else {
 podcastDictionary = @{@"description" : @"Unavailable in offline mode", @"itunesSummary" : @"Unavailable in offline mode"};
 }
 
 label.lineBreakMode = NSLineBreakByWordWrapping;
 label.numberOfLines = 0;
 label.font = self.height == 1024/6 ? [UIFont fontWithName:@"Helvetica" size:17.0f] : [UIFont fontWithName:@"Helvetica" size:9.0f];
 label.backgroundColor = [UIColor clearColor];
 label.textColor = [UIColor whiteColor];
 label.text = self.podcastToLoad == 5 || self.podcastToLoad == 6 ? [podcastDictionary objectForKey:@"description"] : [podcastDictionary objectForKey:@"itunesSummary"];
    self.myLabel = label;
 [headerView addSubview:label];
    [self addSubview:headerView];
}


@end
