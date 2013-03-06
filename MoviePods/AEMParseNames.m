//
//  AEMParseNames.m
//  MoviePods
//
//  Created by Arthur Mayes on 2/20/13.
//  Copyright (c) 2013 Arthur Mayes. All rights reserved.
//

#import "AEMParseNames.h"
#import "GetAndSaveData.h"

@interface AEMParseNames ()
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

-(NSArray *)arrayToParse{
    if (!_arrayToParse) _arrayToParse = [[GetAndSaveData sharedGetAndSave] arrayOfFeeds];
    return _arrayToParse;
}

-(void)parseNamesWithDelegate:(id)aDelegate {
    self.delegate = aDelegate;
    
    if ([[GetAndSaveData sharedGetAndSave] arrayOfFeeds]) {
        [self podcastNamesAreReady];
    } else {
        feedManager = [[AEMFeedManager alloc] init];
        feedManager.delegate = self;
        [feedManager downloadPodcastNames];
    }
}

-(NSMutableArray *)items
{
    if (!_items) _items = [[NSMutableArray alloc] initWithCapacity:PODCAST_COUNT];
    return _items;
}

-(void)podcastNamesAreReady
{
    index = 0; //reset index
    [self parseFeedAtIndex];
}
-(void)failedToDownload
{
    [self.delegate feedsUnavailable];
}
-(void)parseFeedAtIndex
{
    NSData *podcastItem = self.arrayToParse[index];
    
    NSXMLParser *rssParser = [[NSXMLParser alloc] initWithData:podcastItem];
    
    [rssParser setDelegate:self];
    
    [rssParser parse];
    rssParser = nil;
}

#pragma mark rssParser methods

-(void)parserDidStartDocument:(NSXMLParser *)parser {
    wrongTitle = NO; // first title we come across in the document, we will use
}

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
    currentElement = [elementName copy];
    
    if ([elementName isEqualToString:@"channel"]) {
        item = [[NSMutableDictionary alloc] init];
        self.currentTitle = [[NSMutableString alloc] init];
        self.currentSummary = [[NSMutableString alloc] init];
        self.itunesSummary = [[NSMutableString alloc] init];
        record = YES;
    } else if ([currentElement isEqualToString:@"item"]) record = NO;
     
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
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

-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
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

-(void)parserDidEndDocument:(NSXMLParser *)parser {
    [self.items addObject:[item copy]];
    index++;
    if (index < PODCAST_COUNT) {
        item = nil;
        currentTitle = nil;
        currentSummary = nil;
        currentElement = nil;
        [self parseFeedAtIndex];
    } else {
        [[GetAndSaveData sharedGetAndSave] setParsedNamesFeeds:self.items];
        if ([self.delegate respondsToSelector:@selector(namesReady:)]) [self.delegate namesReady:self.items];
    }
}
-(void)dealloc
{
#ifdef DEBUG
	NSLog(@"dealloc %@", self);
#endif
}

@end
