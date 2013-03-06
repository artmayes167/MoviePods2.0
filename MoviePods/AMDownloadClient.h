//
//  AMDownloadClient.h
//  MoviePods
//
//  Created by Arthur Mayes on 2/28/13.
//  Copyright (c) 2013 Arthur Mayes. All rights reserved.
//

#import "AFHTTPClient.h"

@interface AMDownloadClient : AFHTTPClient
+(AMDownloadClient *)sharedDownloadClient;
@end
