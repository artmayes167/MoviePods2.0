//
//  GetKeyStrings.h
//  MoviePods
//
//  Created by Arthur Mayes on 2/19/13.
//  Copyright (c) 2013 Arthur Mayes. All rights reserved.
//

@interface GetKeyStrings : NSObject

+(GetKeyStrings *) sharedKeyStrings;

- (NSString *)nameAtIndex:(int)index;
- (NSString *)favoriteNameAtIndex:(int)index;
- (NSString *)addressAtIndex:(int)index;
- (int)indexOfAddress:(NSString *)address;
- (NSString *)imageNameAtIndex:(int)index;
- (NSString *)siteAtIndex:(int)index;

@end
