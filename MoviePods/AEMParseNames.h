//
//  AEMParseNames.h
//  MoviePods
//
//  Created by Arthur Mayes on 2/20/13.
//  Copyright (c) 2013 Arthur Mayes. All rights reserved.
//

@protocol AEMParseNamesDelegate <NSObject>

- (void)nameReady:(NSMutableDictionary *)name forTag:(int)tag;
@end

@interface AEMParseNames : NSObject<NSXMLParserDelegate>

@property (nonatomic) int tag;
@property (weak, nonatomic) id<AEMParseNamesDelegate>delegate;

- (void)parseName:(NSData *)name WithDelegate:(id)aDelegate;
@end
