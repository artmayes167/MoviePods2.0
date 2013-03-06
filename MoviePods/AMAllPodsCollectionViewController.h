//
//  AMAllPodsCollectionViewController.h
//  MoviePods
//
//  Created by Arthur Mayes on 2/26/13.
//  Copyright (c) 2013 Arthur Mayes. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AMAllPodsCollectionViewController : UICollectionViewController{
    int namesParsed;
    int filesParsed;
    BOOL shouldBeQueueing;
    BOOL alreadyDownloaded;
    BOOL currentlyQueueing;
    BOOL alertShowing;
    BOOL didEnterForeground;
}

@end
