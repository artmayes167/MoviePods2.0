//
//  AEMDownloads.h
//  MoviePods
//
//  Created by Arthur Mayes on 8/31/12.
//  Copyright (c) 2012 Arthur Mayes. All rights reserved.
//

@interface AEMDownloads : NSObject

+(AEMDownloads *)sharedDownloads;

// Downloads information
- (NSDictionary *)episodeForPodcast:(NSString *)podcast titled:(NSString *)title;
- (void)setEpisode:(NSDictionary *)episode titled:(NSString *)title forPodcast:(NSString *)podcast;
- (void)deleteEpisodeTitled:(NSString *)title forPodcast:(NSString *)podcast;
- (NSArray *)getAllNames;
- (NSMutableDictionary *)allEpisodesForKey:(NSString *)podCast;

//Manage the downloads themselves
- (NSData *)getDownloadForKey:(NSString *)string;
- (void)deleteDownloadForKey:(NSString *)string;


@end
