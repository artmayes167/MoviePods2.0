//
//  AEMParser.h
//  MoviePods
//
//  Created by Arthur Mayes on 7/29/12.
//  Copyright (c) 2012 Arthur Mayes. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ParserDelegate <NSObject>
-(void)receivedItems:(NSArray *)theItems;
@end

@interface AEMParser : NSObject <NSXMLParserDelegate> {
    id delegate;
    NSMutableDictionary *item;
    NSString *currentElement;
}

-(void)parseFeed:(int)feedTitleIndex withDelegate:(id)aDelegate;

@end
