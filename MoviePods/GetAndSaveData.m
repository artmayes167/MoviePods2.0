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


-(id)init
{
    if (self = [super init])
    {
        NSError *error;
        NSFileManager *fileManager = [NSFileManager defaultManager];
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
-(NSMutableArray *)arrayForKey:(NSString *)itemsList
{
    return [allItems objectForKey:itemsList];
}

-(NSArray *)getAllKeys
{
    // returns all groups
    return [allItems allKeys];
}
-(NSArray *)getAllNames{
    NSMutableDictionary *dict = [allItems objectForKey:@"Names"];
    
    return [dict allKeys];
}

-(void)setFavorites:(NSMutableArray *)array ForKey:(NSString *)itemsList
{
    [allItems setObject:array
                 forKey:itemsList];
    [allItems writeToFile:path
               atomically:YES];
    
    if(![allItems writeToFile:path atomically:YES]){}
}
-(void)deleteFavoritesForKey:(NSString *)key{
    [allItems removeObjectForKey:key];
    [allItems writeToFile:path
               atomically:YES];
}

#pragma mark - Get/Store UnParsed Feeds
// These are never saved to a .plist
// We want the app to check for new feeds and podcasts every time it restarts
// But while operating, the app should freely move between Views, so the info is stored in active memory
-(void)setFeeds:(NSArray *)feeds
{
    allFeeds = [[NSArray alloc] initWithArray:feeds];
}
-(NSArray *)arrayOfFeeds
{
    return allFeeds;
}
-(NSData *)feedDataAtIndex:(int)index
{
    return allFeeds[index];
}

#pragma mark - Set Parsed Feeds
// These are never saved to a .plist
// We want the app to check for new feeds and podcasts every time it restarts
// But while operating, the app should freely move between Views, so the info is stored in active memory
-(void)setParsedNamesFeeds:(NSArray *)feeds
{
    allParsedFeeds = [[NSArray alloc] initWithArray:feeds];
    self.doneProcessingFeed = YES;
}
-(NSArray *)arrayOfParsedFeeds
{
    return allParsedFeeds;
}

+(GetAndSaveData *)sharedGetAndSave
{
	if (!sharedGetAndSave) sharedGetAndSave = [[self alloc] init];
	return sharedGetAndSave;
}

@end
