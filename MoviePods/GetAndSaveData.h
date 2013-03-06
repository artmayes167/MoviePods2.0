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
    NSArray *allParsedFeeds;
}

@property (nonatomic) BOOL doneProcessingFeed;

+(GetAndSaveData *)sharedGetAndSave;
-(NSMutableArray *)arrayForKey:(NSString *)itemsList;
-(NSArray *)getAllKeys;
-(void)setFavorites:(NSMutableArray *)array ForKey:(NSString *)itemsList;
-(void)deleteFavoritesForKey:(NSString *)key;

-(void)setFeeds:(NSArray *)feeds;
-(NSArray *)arrayOfFeeds;
-(NSData *)feedDataAtIndex:(int)index;

-(void)setParsedNamesFeeds:(NSArray *)feeds;
-(NSArray *)arrayOfParsedFeeds;
@end
