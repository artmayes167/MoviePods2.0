//
//  AEMParseNames.h
//  MoviePods
//
//  Created by Arthur Mayes on 2/20/13.
//  Copyright (c) 2013 Arthur Mayes. All rights reserved.
//

#import "AEMFeedManager.h"

@protocol AEMParseNamesDelegate <NSObject>

-(void)namesReady:(NSArray *)names;
-(void)feedsUnavailable;
@end

@interface AEMParseNames : NSObject<AEMFeedManagerDelegate, NSXMLParserDelegate>{
    NSMutableDictionary *item;
    NSString *currentElement;
    AEMFeedManager *feedManager;
    BOOL record;
    BOOL wrongTitle;
    NSUInteger index;
}

-(void)parseNamesWithDelegate:(id)aDelegate;
@property (weak, nonatomic) id<AEMParseNamesDelegate>delegate;
@end
