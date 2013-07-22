//
//  AMInitiateDownload.h
//  MoviePods
//
//  Created by Arthur Mayes on 2/28/13.
//  Copyright (c) 2013 Arthur Mayes. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AMIniateDownloadsDelegate <NSObject>

@optional
- (void)downloadingFailed:(NSString *)nameOfDownload;
- (void)downloadReady:(NSString *)nameOfDownload;

@end

@interface AMInitiateDownload : NSObject
@property (nonatomic, strong) NSMutableDictionary *downloadingDictionary;
@property (nonatomic, weak) id<AMIniateDownloadsDelegate> delegate;
@property (nonatomic, strong) NSMutableArray *includedNames;
- (void)downloadPodcast:(NSDictionary *)dict; // toPath:(NSString *)path;
+ (AMInitiateDownload *)sharedInitiator;
@end
