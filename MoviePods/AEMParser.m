//
//  AEMParser.m
//  MoviePods
//
//  Created by Arthur Mayes on 7/29/12.
//  Copyright (c) 2012 Arthur Mayes. All rights reserved.
//

#import "AEMParser.h"
#import "AEMParseNames.h"
#import "GetAndSaveData.h"

@interface AEMParser ()
@property (strong, nonatomic) NSData *responseData;
@property (strong, nonatomic) NSMutableArray *items;
@property (strong, nonatomic) NSMutableString *currentTitle;
@property (strong, nonatomic) NSMutableString *currentDate;
@property (strong, nonatomic) NSMutableString *currentSummary;
@property (strong, nonatomic) NSMutableString *currentLink;
@property (strong, nonatomic) NSMutableString *currentPodcastLink;
@property (strong, nonatomic) NSMutableString *itunesSummary;
@property (strong, nonatomic) NSMutableString *linkForLongTail;
@end

@implementation AEMParser

@synthesize items;
@synthesize responseData;
@synthesize currentTitle;
@synthesize currentDate;
@synthesize currentSummary;
@synthesize currentLink;
@synthesize currentPodcastLink;
@synthesize itunesSummary;
@synthesize linkForLongTail;

//parse feeds that have already been saved in temporary data
-(void)parseFeed:(NSData *)feed withName:(NSString *)name andDelegate:(id)aDelegate{
    delegate = aDelegate;
    nameOfPodcast = name;
    self.items = [[NSMutableArray alloc] init];
    
    NSXMLParser *rssParser = [[NSXMLParser alloc] initWithData:feed];
    
    [rssParser setDelegate:self];
    
    [rssParser parse];
    rssParser = nil;
}

#pragma mark rssParser methods

-(void)parserDidStartDocument:(NSXMLParser *)parser {
    
}

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
    currentElement = [elementName copy];
    
    if ([elementName isEqualToString:@"item"]) {
        item = [[NSMutableDictionary alloc] init];
        [item setObject:nameOfPodcast forKey:@"name"];
        self.currentTitle = [[NSMutableString alloc] init];
        self.currentDate = [[NSMutableString alloc] init];
        self.currentSummary = [[NSMutableString alloc] init];
        self.currentLink = [[NSMutableString alloc] init];
        self.currentPodcastLink = [[NSMutableString alloc] init];
        self.itunesSummary = [[NSMutableString alloc] init];
        self.linkForLongTail = [[NSMutableString alloc] init];
    }
    
    // podcast url is an attribute of the element enclosure
    if ([currentElement isEqualToString:@"enclosure"]) [currentPodcastLink appendString:[attributeDict objectForKey:@"url"]];
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
    
    if ([elementName isEqualToString:@"item"]) {
        [item setObject:[self.currentTitle stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"title"];
        [item setObject:[self.currentLink stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"link"];
        [item setObject:self.currentSummary forKey:@"summary"];
        [item setObject:self.currentPodcastLink forKey:@"podcastLink"];
        if (self.linkForLongTail) {
            [item setObject:self.linkForLongTail forKey:@"linkForLongTail"];
        }
        
        
        if (self.itunesSummary.length > 5) [item setObject:self.itunesSummary forKey:@"itunesSummary"];
        
        // Parse date here
        if (self.currentDate) {
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"E, d LLL yyyy HH:mm:ss Z"]; // Thu, 18 Jun 2010 04:48:09 -0700
            NSDate *date = [dateFormatter dateFromString:self.currentDate];
            
            if (date) [item setObject:date forKey:@"date"];
        }
        
        [items addObject:[item copy]];

        item = nil;
        currentTitle = nil;
        currentDate = nil;
        currentLink = nil;
        currentSummary = nil;
        currentPodcastLink = nil;
        currentElement = nil;
    }
}

-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    if ([currentElement isEqualToString:@"title"]) {
        [self.currentTitle appendString:string];
    } else if ([currentElement isEqualToString:@"link"]) {
        [self.currentLink appendString:string];
    } else if ([currentElement isEqualToString:@"description"]) {
        [self.currentSummary appendString:string];
    } else if ([currentElement isEqualToString:@"pubDate"]) {
        [self.currentDate appendString:string];
        NSString *trimmedString = [self.currentDate stringByTrimmingCharactersInSet:
                                   [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        [self.currentDate setString:trimmedString];
        trimmedString = nil;
        
    } else if ([currentElement isEqualToString:@"itunes:summary"]){
        [self.itunesSummary appendString:string];
    } else if ([currentElement isEqualToString:@"podcastLink"]) {
        [self.currentPodcastLink appendString:string];
    } else if ([currentElement isEqualToString:@"feedburner:origEnclosureLink"]){
        [self.linkForLongTail appendString:string];
    }
}

-(void)parserDidEndDocument:(NSXMLParser *)parser {
    if ([delegate respondsToSelector:@selector(receivedItems:forName:WithTag:)]){
        [delegate receivedItems:items forName:nameOfPodcast WithTag:self.tag];
        //if (self.tag == 4) NSLog(@"%@", items);
    }
    else
    {
        [NSException raise:NSInternalInconsistencyException
                    format:@"Delegate doesn't respond to receivedItems:"];
    }
    responseData = nil;
}
-(void)dealloc
{
#ifdef DEBUG
	//NSLog(@"dealloc %@", self);
#endif
}

@end
