//
//  GetAndSaveData.m
//  charGen
//
//  Created by Arthur Mayes on 12/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "GetAndSaveData.h"


static GetAndSaveData *sharedGetAndSave;

@interface GetAndSaveData ()

@end

@implementation GetAndSaveData


- (id)init
{
    if (self = [super init])
    {
        NSError *error;
        NSFileManager *fileManager = [[NSFileManager alloc] init];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); //1
        NSString *documentsDirectory = [paths objectAtIndex:0]; //2
        path = [documentsDirectory stringByAppendingPathComponent:@"data.plist"]; //3
        
        
        if (![fileManager fileExistsAtPath: path]) //4
        {
            NSString *bundle = [[NSBundle mainBundle] pathForResource:@"data" ofType:@"plist"]; //5
            
            [fileManager copyItemAtPath:bundle toPath: path error:&error]; //6
        }
        
        allItems = [[NSMutableDictionary alloc] initWithContentsOfFile: path]; // Dictionary of all Groups
        
        self.doneProcessingFeed = NO;
    }
    
    return self;
}

#pragma mark - Getting and Saving Favorites

// These are stored in .plists, and are User-assigned
- (NSMutableDictionary *)favoritesDictionaryForName:(NSString *)podcastName
{
    NSLog(@"allItems for key = %@", [allItems objectForKey:podcastName]);
    return [allItems objectForKey:podcastName];
}

#define KEY_FOR_UNFINISHED_DOWNLOADS @"To Download"
- (void)setDownloadsDictionary:(NSMutableDictionary *)dictionaryOfDownloads
{
    [allItems setObject:dictionaryOfDownloads
                 forKey:KEY_FOR_UNFINISHED_DOWNLOADS];
    [allItems writeToFile:path
               atomically:YES];
}

- (NSMutableDictionary *)dictionaryOfDownloads
{
    return [allItems objectForKey:KEY_FOR_UNFINISHED_DOWNLOADS];
}

- (NSArray *)getAllKeys
{
    // returns all groups
    return [allItems allKeys];
}

- (NSArray *)getAllNames
{
    NSMutableArray *array = [[NSMutableArray alloc] initWithArray:[allItems allKeys]];
    for (NSString *string in array) {
        if ([string isEqualToString:KEY_FOR_UNFINISHED_DOWNLOADS]) {
            [array removeObjectAtIndex:[array indexOfObject:KEY_FOR_UNFINISHED_DOWNLOADS]];
            break;
        }
    }
    NSArray *fixedArray = [[NSArray alloc] initWithArray:(NSArray *)array];
    return fixedArray;
}

- (void)setFavorites:(NSMutableDictionary *)dictionaryOfFavoritedEpisodes ForName:(NSString *)podcastName
{
    [allItems setObject:dictionaryOfFavoritedEpisodes
                 forKey:podcastName];
    [allItems writeToFile:path
               atomically:YES];
    NSLog(@"Setting allItems: %@", dictionaryOfFavoritedEpisodes);
    if(![allItems writeToFile:path atomically:YES]){}
}

- (void)deleteFavoritesForName:(NSString *)podcastName
{
    [allItems removeObjectForKey:podcastName];
    [allItems writeToFile:path
               atomically:YES];
}

#pragma mark - Get/Store UnParsed Feeds
// These are never saved to a .plist
// We want the app to check for new feeds and podcasts every time it restarts
// But while operating, the app should freely move between Views, so the info is stored in active memory
- (void)setFeeds:(NSArray *)feeds
{
    allFeeds = [[NSArray alloc] initWithArray:feeds];
}

- (NSArray *)arrayOfFeeds
{
    return allFeeds;
}

- (NSData *)feedDataAtIndex:(int)index
{
    return allFeeds[index];
}

#pragma mark - Set Parsed Feeds
// These are never saved to a .plist
// We want the app to check for new feeds and podcasts every time it restarts
// But while operating, the app should freely move between Views, so the info is stored in active memory
- (void)setParsedFeed:(NSArray *)feed forKey:(NSString *)key
{
    if (!allParsedFeeds) allParsedFeeds = [[NSMutableDictionary alloc] init];
    [allParsedFeeds setObject:feed forKey:key];
}

- (NSArray *)arrayForParsedFeed:(NSString *)name
{
    return [allParsedFeeds objectForKey:name];
}

- (void)setParsedNamesFeeds:(NSArray *)feeds
{
    allParsedNamesFeeds = [[NSArray alloc] initWithArray:feeds];
}

- (NSArray *)arrayOfParsedNamesFeeds
{
    return allParsedNamesFeeds;
}

+(GetAndSaveData *)sharedGetAndSave
{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedGetAndSave = [[self alloc] init];
    });
	return sharedGetAndSave;
}

@end
