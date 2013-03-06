//
//  AEMParser.h
//  MoviePods
//
//  Created by Arthur Mayes on 7/29/12.
//  Copyright (c) 2012 Arthur Mayes. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ParserDelegate <NSObject>
-(void)receivedItems:(NSMutableArray *)theItems forName:(NSString *)name WithTag:(int)tag;
@end

@interface AEMParser : NSObject <NSXMLParserDelegate> {
    id delegate;
    NSMutableDictionary *item;
    NSString *currentElement;
    NSString *nameOfPodcast;
}

@property (nonatomic) int tag;

-(void)parseFeed:(NSData *)feed withName:(NSString *)name andDelegate:(id)aDelegate;

@end
