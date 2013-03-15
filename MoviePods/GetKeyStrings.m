//
//  GetKeyStrings.m
//  MoviePods
//
//  Created by Arthur Mayes on 2/19/13.
//  Copyright (c) 2013 Arthur Mayes. All rights reserved.
//

#import "GetKeyStrings.h"

static GetKeyStrings *sharedKeyStrings;

@implementation GetKeyStrings

-(id)init
{
    if (self = [super init])
    {
        NSError *error;
        NSFileManager *fileManager = [[NSFileManager alloc] init];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); //1
        NSString *documentsDirectory = [paths objectAtIndex:0]; //2
        path = [documentsDirectory stringByAppendingPathComponent:@"Names.plist"]; //3
        
        
        if (![fileManager fileExistsAtPath: path]) //4
        {
            NSString *bundle = [[NSBundle mainBundle] pathForResource:@"Names" ofType:@"plist"]; //5
            
            [fileManager copyItemAtPath:bundle toPath: path error:&error]; //6
        }
        
        allKeyStringsDictionary = [[NSDictionary alloc] initWithContentsOfFile: path]; // Dictionary of all Groups
    }
    
    return self;
}

-(NSString *)nameAtIndex:(int)index
{
    return [[allKeyStringsDictionary objectForKey:@"Podcast"] objectAtIndex:index];
    
}
-(NSString *)favoriteNameAtIndex:(int)index
{
    return [[allKeyStringsDictionary objectForKey:@"Favorites"] objectAtIndex:index];
}
-(NSString *)addressAtIndex:(int)index
{
    return [[allKeyStringsDictionary objectForKey:@"Addresses"] objectAtIndex:index];
}
-(int)indexOfAddress:(NSString *)address
{
    return [[allKeyStringsDictionary objectForKey:@"Addresses"] indexOfObject:address];
}
-(NSString *)imageNameAtIndex:(int)index
{
    return [[allKeyStringsDictionary objectForKey:@"Images"] objectAtIndex:index];
}
-(NSString *)siteAtIndex:(int)index
{
    return [[allKeyStringsDictionary objectForKey:@"Sites"] objectAtIndex:index];
}

+(GetKeyStrings *)sharedKeyStrings
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedKeyStrings = [[self alloc] init];
    });        
	return sharedKeyStrings;
}

@end
