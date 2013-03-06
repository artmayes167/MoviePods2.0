//
//  AMDownloadClient.m
//  MoviePods
//
//  Created by Arthur Mayes on 2/28/13.
//  Copyright (c) 2013 Arthur Mayes. All rights reserved.
//

#import "AMDownloadClient.h"
#import "AFHTTPRequestOperation.h"


@implementation AMDownloadClient
+(AMDownloadClient *)sharedDownloadClient
{
    static AMDownloadClient *_sharedDownloadClient = nil;
    static dispatch_once_t AMDownloadClientToken;
    dispatch_once(&AMDownloadClientToken, ^{
        _sharedDownloadClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:@"http://www.google.com"]];
        
    });
    return _sharedDownloadClient;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    BOOL success = [self registerHTTPOperationClass:[AFHTTPRequestOperation class]];
    if (success) {
        NSLog(@"Success");
    } else {
        NSLog(@"Success");
    }
    return self;
}
@end
