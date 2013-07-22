//
//  AMInitiateDownload.m
//  MoviePods
//
//  Created by Arthur Mayes on 2/28/13.
//  Copyright (c) 2013 Arthur Mayes. All rights reserved.
//

#import "AMInitiateDownload.h"
#import "AMDownloadClient.h"
#import "AEMDownloads.h"
#import "GetAndSaveData.h"
#import "UIAlertView+MKBlockAdditions.h"
#import "AFURLConnectionOperation.h"
#import "AFHTTPRequestOperation.h"

static AMInitiateDownload *sharedInitiator;

@implementation AMInitiateDownload

- (NSMutableDictionary *)downloadingDictionary
{
    if (!_downloadingDictionary) {
        if ([[GetAndSaveData sharedGetAndSave]dictionaryOfDownloads]) _downloadingDictionary = [[GetAndSaveData sharedGetAndSave]dictionaryOfDownloads];
        else _downloadingDictionary = [NSMutableDictionary new];
    }
    return _downloadingDictionary;
}

- (void)downloadPodcast:(NSDictionary *)dict //toPath:(NSString *)path
{
    // store the dictionary
    [self.downloadingDictionary setObject:dict forKey:[dict objectForKey:@"title"]];
    [[GetAndSaveData sharedGetAndSave]setDownloadsDictionary:self.downloadingDictionary];
    
    NSString *podCastLink;
    if ([[dict objectForKey:@"podcastLink"] length] > 5) podCastLink = [dict objectForKey:@"podcastLink"];
    else podCastLink = [dict objectForKey:@"link"];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:podCastLink]
                                             cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                         timeoutInterval:60.0];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    NSString *pathStarter = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];

    NSString *path = [pathStarter stringByAppendingPathComponent:[dict objectForKey:@"title"]];
    
    operation.outputStream = [NSOutputStream outputStreamToFileAtPath:path append:NO];
    
    AMInitiateDownload * __weak weakSelf = self;
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         [weakSelf.delegate downloadReady:[[operation request].URL absoluteString]];
        
         for (NSDictionary *dictionary in [weakSelf.downloadingDictionary objectEnumerator]) {
             
             if ([dictionary isKindOfClass:[NSDictionary class]]) {
                 NSString *podCastLink;
                 if ([[dictionary objectForKey:@"podcastLink"] length] > 5) podCastLink = [dictionary objectForKey:@"podcastLink"];
                 else podCastLink = [dictionary objectForKey:@"link"];
                 
                 if ([podCastLink isEqualToString:[[operation request].URL absoluteString]]) {
                     [[AEMDownloads sharedDownloads]setEpisode:dictionary
                                                        titled:[dictionary objectForKey:@"title"]
                                                    forPodcast:[dictionary objectForKey:@"name"]];
                     [weakSelf.downloadingDictionary removeObjectForKey:[dictionary objectForKey:@"title"]];
                     [[GetAndSaveData sharedGetAndSave]setDownloadsDictionary:self.downloadingDictionary];
                 }
             }
         }
     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [weakSelf.delegate downloadingFailed:[[operation request].URL absoluteString]];
     }];
    
    [[AMDownloadClient sharedDownloadClient] enqueueHTTPRequestOperation:operation];    
}

+ (AMInitiateDownload *)sharedInitiator
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInitiator = [[self alloc] init];

    });
    return sharedInitiator;
}

@end
