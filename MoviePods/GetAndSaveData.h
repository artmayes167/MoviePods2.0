//
//  GetAndSaveData.h
//  charGen
//
//  Created by Arthur Mayes on 12/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

@interface GetAndSaveData : NSObject{
    NSMutableDictionary *allItems;
    NSString *path;
    NSArray *allFeeds;
    NSArray *allParsedNamesFeeds;
    NSMutableDictionary *allParsedFeeds;
}

@property (nonatomic) BOOL doneProcessingFeed;

+(GetAndSaveData *)sharedGetAndSave;
- (NSMutableDictionary *)favoritesDictionaryForName:(NSString *)podcastName;

- (void)setDownloadsDictionary:(NSMutableDictionary *)dictionaryOfDownloads;
- (NSMutableDictionary *)dictionaryOfDownloads;

- (NSArray *)getAllKeys;
- (NSArray *)getAllNames;

- (void)setFavorites:(NSMutableDictionary *)dictionaryOfFavoritedEpisodes ForName:(NSString *)podcastName;
- (void)deleteFavoritesForName:(NSString *)podcastName;

- (void)setFeeds:(NSArray *)feeds;
- (NSArray *)arrayOfFeeds;
- (NSData *)feedDataAtIndex:(int)index;

- (void)setParsedNamesFeeds:(NSArray *)feeds;
- (NSArray *)arrayOfParsedNamesFeeds;
- (void)setParsedFeed:(NSArray *)feed forKey:(NSString *)key;
- (NSArray *)arrayForParsedFeed:(NSString *)name;
@end
