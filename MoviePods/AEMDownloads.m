//
//  AEMDownloads.m
//  MoviePods
//
//  Created by Arthur Mayes on 8/31/12.
//  Copyright (c) 2012 Arthur Mayes. All rights reserved.
//
// This class saves the downloads in a plist

#import "AEMDownloads.h"


static AEMDownloads *sharedDownloads;

@interface AEMDownloads ()
@property (nonatomic, strong) NSString *pathStarter;
@property (nonatomic, strong) NSMutableArray *allNames;
@end

@implementation AEMDownloads

-(id)init{
    
    self = [super init];

    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); //1
    NSString *documentsDirectory = [paths objectAtIndex:0]; //2
    path = [documentsDirectory stringByAppendingPathComponent:@"downloads.plist"]; //3
    
    // downloads.plist holds dictionaries with the information of individual podcasts downloaded, stored by podcast name
    if (![fileManager fileExistsAtPath: path]) //4
    {
        NSString *bundle = [[NSBundle mainBundle] pathForResource:@"downloads" ofType:@"plist"]; //5
        
        [fileManager copyItemAtPath:bundle toPath: path error:&error]; //6
    }
    // keys are podcast names
    allDownloads = [[NSMutableDictionary alloc] initWithContentsOfFile: path]; // Dictionary of all Downloads
    
    return self;
}

#pragma mark - Get/Delete Download Information

//Each item is a dictionary with the podcast title as the key
//Each item is stored in allDownloads with the podcast name as the key
//So we need two NSStrings as points of reference to pull out information
//And we need to check to see if that information exists before returning it

-(NSDictionary *)episodeForPodcast:(NSString *)podcast titled:(NSString *)title
{
    if ([allDownloads objectForKey:podcast]) {
        if ([[allDownloads objectForKey:podcast] objectForKey:title]) { // redundancy for safety
            return [[allDownloads objectForKey:podcast] objectForKey:title];
        }
    }
    return nil;
}
-(void)setEpisode:(NSDictionary *)episode titled:(NSString *)title forPodcast:(NSString *)podcast
{
    if ([allDownloads objectForKey:podcast]) {
        [[allDownloads objectForKey:podcast] setObject:episode forKey:title];
    } else {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithObjects:@[episode] forKeys:@[title]];
        [allDownloads setObject:dict forKey:podcast];
    }
    [allDownloads writeToFile:path atomically:YES];
    
    if(![allDownloads writeToFile:path atomically:YES])
    {
        //NSLog(@".plist writing was unsuccessful");
        
    }

}
-(void)deleteEpisodeTitled:(NSString *)title forPodcast:(NSString *)podcast
{
    if ([allDownloads objectForKey:podcast]) {
        if ([[allDownloads objectForKey:podcast] objectForKey:title]) {
            [[allDownloads objectForKey:podcast] removeObjectForKey:title];
            if ([[allDownloads objectForKey:podcast] count] < 1) [allDownloads removeObjectForKey:podcast];
            [allDownloads writeToFile:path atomically:YES];
        }
    }
}
-(NSArray *)getAllNames{
    
    return [allDownloads allKeys];
}


-(NSMutableDictionary *)allEpisodesForKey:(NSString *)podCast
{
    NSMutableDictionary *dict = [allDownloads objectForKey:podCast];
    return dict;
}

#pragma mark - Get/Delete Download

-(NSString *)pathStarter
{
    if (!_pathStarter) _pathStarter = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    return _pathStarter;
}

-(NSData *)getDownloadForKey:(NSString *)string{
    NSString *pathForDownload = [self.pathStarter stringByAppendingPathComponent:string];
    
    NSData *download = [NSData dataWithContentsOfFile:pathForDownload];
    return download;
}

-(void)deleteDownloadForKey:(NSString *)string{
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *dataPath = [self.pathStarter stringByAppendingPathComponent:string];
    
    [fileManager removeItemAtPath:dataPath error:&error];
}

+(AEMDownloads *)sharedDownloads{
	if (!sharedDownloads) sharedDownloads = [[self alloc] init];
	
	return sharedDownloads;
}

@end
