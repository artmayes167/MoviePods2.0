//
//  AEMParseNames.m
//  MoviePods
//
//  Created by Arthur Mayes on 2/20/13.
//  Copyright (c) 2013 Arthur Mayes. All rights reserved.
//

#import "AEMParseNames.h"
#import "GetAndSaveData.h"

@interface AEMParseNames () {
    NSMutableDictionary *item;
    NSString *currentElement;
    BOOL record;
    BOOL wrongTitle;
    NSUInteger index;
}
@property (nonatomic, strong) NSArray *arrayToParse;
@property (nonatomic, strong) NSMutableArray *items;

@property (strong, nonatomic) NSMutableString *currentDate;
@property (strong, nonatomic) NSMutableString *currentLink;
@property (strong, nonatomic) NSMutableString *currentPodcastLink;
@property (nonatomic, strong) NSMutableString *currentTitle;
@property (nonatomic, strong) NSMutableString *currentSummary;
@property (nonatomic, strong) NSMutableString *itunesSummary;
@end

@implementation AEMParseNames

@synthesize arrayToParse = _arrayToParse;
@synthesize items = _items;

@synthesize currentDate;
@synthesize currentLink;
@synthesize currentPodcastLink;
@synthesize currentTitle;
@synthesize currentSummary;
@synthesize itunesSummary;


- (void)parseName:(NSData *)name WithDelegate:(id)aDelegate {
    self.delegate = aDelegate;
    
    index = 0; //reset index
    [self parseFeed:name];
}

- (NSMutableArray *)items
{
    if (!_items) _items = [[NSMutableArray alloc] initWithCapacity:PODCAST_COUNT];
    return _items;
}

- (void)parseFeed:(NSData *)name
{
    NSXMLParser *rssParser = [[NSXMLParser alloc] initWithData:name];
    
    [rssParser setDelegate:self];
    
    [rssParser parse];
    rssParser = nil;
}

#pragma mark rssParser methods

- (void)parserDidStartDocument:(NSXMLParser *)parser
{
    wrongTitle = NO; // first title we come across in the document, we will use
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    currentElement = [elementName copy];
    
    if ([elementName isEqualToString:@"channel"]) {
        item = [[NSMutableDictionary alloc] init];
        self.currentTitle = [[NSMutableString alloc] init];
        self.currentSummary = [[NSMutableString alloc] init];
        self.itunesSummary = [[NSMutableString alloc] init];
        record = YES;
    } else if ([currentElement isEqualToString:@"item"]) record = NO;
     
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if (record) {
        if ([currentElement isEqualToString:@"title"]) {
            if (!wrongTitle) {
                [item setObject:self.currentTitle forKey:@"title"];
                wrongTitle = YES; // some of the feeds contain multiple title elements
            }
        } else if ([currentElement isEqualToString:@"description"]) {
            [item setObject:self.currentSummary forKey:@"description"];
        } else if ([currentElement isEqualToString:@"itunes:summary"]) {
            if (self.itunesSummary.length > 5) [item setObject:self.itunesSummary forKey:@"itunesSummary"];
        } 
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if (record) {
        if ([currentElement isEqualToString:@"title"]) {
            if (!wrongTitle) [self.currentTitle appendString:string];
        } else if ([currentElement isEqualToString:@"description"]) {
            [self.currentSummary appendString:string];
        } else if ([currentElement isEqualToString:@"itunes:summary"]){
            [self.itunesSummary appendString:string];
        }
        
    }
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
        if ([self.delegate respondsToSelector:@selector(nameReady:forTag:)]) [self.delegate nameReady:item forTag:self.tag];
}

@end
