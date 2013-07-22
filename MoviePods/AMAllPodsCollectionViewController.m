//
//  AMAllPodsCollectionViewController.m
//  MoviePods
//
//  Created by Arthur Mayes on 2/26/13.
//  Copyright (c) 2013 Arthur Mayes. All rights reserved.
//

#import "AMAppDelegate.h"
#import "AMAllPodsCollectionViewController.h"
#import "AMCustomCollectionViewCell.h"
#import "GetKeyStrings.h"
#import "GetAndSaveData.h"
#import "AFNetworking.h"
#import "AMTabBarViewController.h"
#import "AEMParser.h"
#import "AEMParseNames.h"
#import "AMDownloadClient.h"
#import "UIAlertView+MKBlockAdditions.h"

@interface AMAllPodsCollectionViewController ()
- (IBAction)refresh:(id)sender;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *refreshButton;
@property (nonatomic, strong) NSMutableArray *namesParsedArray;
@property (nonatomic, strong) NSMutableArray *initialQueue;
@property (nonatomic, strong) NSMutableArray *failLog;
@property (nonatomic, strong) NSMutableArray *requeueArray;
@end

@implementation AMAllPodsCollectionViewController

- (IBAction)refresh:(id)sender {
    //NSLog(@"shouldBeQueueing = %i\ncurrentlyQueueing = %i\nalreadyDownloaded = %i", shouldBeQueueing, currentlyQueueing, alreadyDownloaded);
    shouldBeQueueing = YES;
    currentlyQueueing = NO;
    if (didEnterForeground == YES) {
        for (int i = 0; i < [self.initialQueue count]; ++i) {
            int cellIndex = [[self.initialQueue  objectAtIndex:i] intValue];
            [self setCellDisabledAtIndex:cellIndex];
        }
        alreadyDownloaded = NO;
        [self queueItUp:self.initialQueue];
        didEnterForeground = NO;
    } else {
        for (int i = 0; i < [self.requeueArray count]; ++i) {
            int cellIndex = [[self.requeueArray objectAtIndex:i] intValue];
            [self setCellDisabledAtIndex:cellIndex];
        }
        [self queueItUp:self.requeueArray];
    }
    
}

-(NSMutableArray *)initialQueue{
    if (!_initialQueue) {
        _initialQueue = [NSMutableArray new];
        for (int i = 0; i < PODCAST_COUNT; ++i) {
            [_initialQueue addObject:@(i)];
        }
    }
    return _initialQueue;
}

-(NSMutableArray *)failLog{
    if (!_failLog) _failLog = [NSMutableArray new];
    return _failLog;
}

-(NSMutableArray *)requeueArray
{
    if (!_requeueArray) _requeueArray = [NSMutableArray new];
    return _requeueArray;
}

-(NSMutableArray *)namesParsedArray{
    if (!_namesParsedArray) {
        _namesParsedArray = [[NSMutableArray alloc] init];
        for (int i = 0; i < PODCAST_COUNT; ++i) [_namesParsedArray addObject:@""];
    }
    return _namesParsedArray;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    AMAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate addObserver:self forKeyPath:@"enteringForeground" options:NSKeyValueObservingOptionNew context:nil];
    [self.refreshButton setEnabled:NO];
    alreadyDownloaded = NO;
    AMAllPodsCollectionViewController * __weak weakSelf = self; // prevents retain cycle in blocks
    [[AMDownloadClient sharedDownloadClient] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        BOOL offlineOnly = [defaults boolForKey:@"offlineOnly"];
        if (status == AFNetworkReachabilityStatusNotReachable) {
            //NSLog(@"Not Reachable");
            shouldBeQueueing = NO;
            if (offlineOnly) {
                [weakSelf makeThemAllVisible];
            }
        } else {
            BOOL wifiOnly = [defaults boolForKey:@"wifiOnly"];
            if (wifiOnly){
                if (status == AFNetworkReachabilityStatusReachableViaWiFi) {
                    appDelegate.wifi = YES;
                    [weakSelf queueItUp:weakSelf.initialQueue];
                } else {
                    shouldBeQueueing = NO;
                    appDelegate.wifi = NO;
                }
            } else {
                //NSLog(@"Reachable");
                if (!offlineOnly) [weakSelf queueItUp:weakSelf.initialQueue];
                else [weakSelf makeThemAllVisible];
            }
            
        }
        
    }];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([[change objectForKey:@"new"] isEqual: @(1)]){
        didEnterForeground = YES;
        [self.refreshButton setEnabled:YES];
    }
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL offlineOnly = [defaults boolForKey:@"offlineOnly"];
    if (offlineOnly) {
        shouldBeQueueing = NO;
        [self makeThemAllVisible];
    } else {
        if (!currentlyQueueing && !alreadyDownloaded) {
            shouldBeQueueing = YES;
            [self queueItUp:self.initialQueue];
            NSArray *cellArray = [self.collectionView indexPathsForVisibleItems];
            for (NSIndexPath *indexPath in cellArray) {
                
                AMCustomCollectionViewCell *cell = (AMCustomCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
                cell.imageView.alpha = 0.5;
                [cell.activityIndicator startAnimating];
                cell.userInteractionEnabled = NO;
                
            }
        }
        
    }
}

-(void)makeThemAllVisible
{
    for (int i = 0; i < PODCAST_COUNT; ++i) [self setCellEnabledAtIndex:i];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

-(void)queueItUp:(NSMutableArray *)arrayForQueue
{
    if (shouldBeQueueing) {
        if (!alreadyDownloaded && !currentlyQueueing) {
            //NSLog(@"Queueing items: %@", arrayForQueue);
            currentlyQueueing = YES;
            [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:YES];
            for (int i = 0; i < [arrayForQueue count]; ++i) {
                    int queueTag = [[arrayForQueue objectAtIndex:i] intValue];
                    [self setItemToDownload:[[GetKeyStrings sharedKeyStrings]nameAtIndex:queueTag] atAddress:[[GetKeyStrings sharedKeyStrings]addressAtIndex:queueTag] andIndex:queueTag];
            }
            
        }
    }
}



-(void)setItemToDownload:(NSString *)item atAddress:(NSString *)address andIndex:(int)index{
    NSString *pathStarter = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *path = [pathStarter stringByAppendingPathComponent:item];
    
    NSURL *url = [[NSURL alloc] initWithString:address];
    NSURLRequest *request = [NSURLRequest requestWithURL:url
                                             cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                         timeoutInterval:60.0];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    AMAllPodsCollectionViewController * __weak weakSelf = self;
    
    operation.outputStream = [NSOutputStream outputStreamToFileAtPath:path append:NO];
    operation.tag = index;
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSData *data = [[NSData alloc] initWithContentsOfFile:path];
         [weakSelf parseName:data withTag:operation.tag];
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [weakSelf.failLog addObject:@(operation.tag)];
         if ([weakSelf.failLog count] + namesParsed == PODCAST_COUNT) [weakSelf sendAlerts];
     }];
    
    [operation start];
}

-(void)sendAlerts{
    
    int keyVal = [[self.failLog lastObject] intValue];
    NSString *alertString = [NSString stringWithFormat:@"%@ failed.  Try again?", [[GetKeyStrings sharedKeyStrings]nameAtIndex:keyVal]];
    AMAllPodsCollectionViewController * __weak weakSelf = self;
    [UIAlertView alertViewWithTitle:@"Oops"
                            message:alertString
                  cancelButtonTitle:@"Yes"
                  otherButtonTitles:[NSArray arrayWithObjects:@"No", nil]
                          onDismiss:^(int buttonIndex){
                              int currentTag = [[self.failLog lastObject] intValue];
                              [weakSelf setCellEnabledAtIndex:currentTag];
                              [weakSelf.requeueArray addObject:@(currentTag)];
                              [weakSelf.failLog removeObjectIdenticalTo:@(currentTag)];
                              if ([weakSelf.failLog count]) {
                                  [weakSelf sendAlerts];
                              } else {
                                  [weakSelf.refreshButton setEnabled:YES];
                                  shouldBeQueueing = NO;
                                  currentlyQueueing = NO;
                              }
                          }
                           onCancel:^(){
                              // try again
                               int tag = [[weakSelf.failLog lastObject] intValue];
                               [weakSelf.failLog removeObjectIdenticalTo:@(tag)];
                               [weakSelf setItemToDownload:[[GetKeyStrings sharedKeyStrings]nameAtIndex:tag] atAddress:[[GetKeyStrings sharedKeyStrings]addressAtIndex:tag] andIndex:tag];
                               if ([weakSelf.failLog count]) {
                                   [weakSelf sendAlerts];
                               } else {
                                   [weakSelf.refreshButton setEnabled:YES];
                                   shouldBeQueueing = NO;
                                   currentlyQueueing = NO;
                               }
                               
                           }];
}

-(void)parseName:(NSData *)nameData withTag:(int)tag // gets two subsets of information
{
    AEMParseNames *rssNameParser = [[AEMParseNames alloc] init];
    rssNameParser.tag = tag;
    [rssNameParser parseName:nameData WithDelegate:self];
    
    AEMParser *rssParser = [[AEMParser alloc] init];
    rssParser.tag = tag;
    [rssParser parseFeed:nameData withName:[[GetKeyStrings sharedKeyStrings]nameAtIndex:tag] andDelegate:self];
    
}

#pragma AEMNamesParser delegate method
-(void)nameReady:(NSMutableDictionary *)name forTag:(int)tag{
    namesParsed++;
    self.namesParsedArray[tag] = name;
    NSMutableArray *arrayToAlter = [self.requeueArray mutableCopy];
    for (id object in arrayToAlter) {
        if ([object intValue] == tag) [self.requeueArray removeObjectIdenticalTo:@(tag)];
    }
    if (namesParsed == PODCAST_COUNT){
        [[GetAndSaveData sharedGetAndSave]setParsedNamesFeeds:(NSArray *)self.namesParsedArray];
        alreadyDownloaded = YES;
        shouldBeQueueing = NO;
        currentlyQueueing = NO;
        [self.refreshButton setEnabled:NO];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }
}

#pragma AEMParser delegate method
-(void)receivedItems:(NSArray *)theItems forName:(NSString *)name WithTag:(int)tag
{
    filesParsed++; // legacy
    [[GetAndSaveData sharedGetAndSave]setParsedFeed:theItems forKey:name];
    [self setCellEnabledAtIndex:tag];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(AMCustomCollectionViewCell *)sender
{
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:sender];
    AMAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    appDelegate.podcastToShow = indexPath.item;
}

-(void)setCellDisabledAtIndex:(int)index
{
    NSArray *cellArray = [self.collectionView indexPathsForVisibleItems];
    for (NSIndexPath *indexPath in cellArray) {
        if (indexPath.item == index) {
            AMCustomCollectionViewCell *cell = (AMCustomCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
            cell.imageView.alpha = 0.5;
            [cell.activityIndicator startAnimating];
            cell.userInteractionEnabled = NO;
        }
    }
}

-(void)setCellEnabledAtIndex:(int)index
{
    NSArray *cellArray = [self.collectionView indexPathsForVisibleItems];
    for (NSIndexPath *indexPath in cellArray) {
        if (indexPath.item == index) {
            AMCustomCollectionViewCell *cell = (AMCustomCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
            cell.imageView.alpha = 1.0;
            [cell.activityIndicator stopAnimating];
            cell.userInteractionEnabled = YES;
        }
    }
}

#pragma mark - UICollectionViewDataSource

//@optional
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}


//@required
-(NSInteger)collectionView:(UICollectionView *)collectionView
    numberOfItemsInSection:(NSInteger)section
{
    return PODCAST_COUNT; // Controller interpreting the Model for the View
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    AMCustomCollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"Icon" forIndexPath:indexPath];
    cell.imageView.image = [UIImage imageNamed:[[GetKeyStrings sharedKeyStrings]imageNameAtIndex:indexPath.item]];
    BOOL downloaded = NO;
    if ([[GetAndSaveData sharedGetAndSave] arrayForParsedFeed:[[GetKeyStrings sharedKeyStrings] nameAtIndex:indexPath.item]]) downloaded = YES;
    if (!downloaded) {
        cell.imageView.alpha = 0.5;
        cell.userInteractionEnabled = NO;
    } else {
        cell.imageView.alpha = 1.0;
        cell.userInteractionEnabled = YES;
    }
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(cell.frame.size.width/2 - 15.0, cell.frame.size.height/2 - 15.0, 30.0, 30.0)];
    indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    indicator.hidesWhenStopped = YES;
    
    if (!cell.activityIndicator) {
        if (!downloaded) [indicator startAnimating];
        cell.activityIndicator = indicator;
        [cell.imageView addSubview:cell.activityIndicator];
    } else if (downloaded)[cell.activityIndicator stopAnimating];
    else [cell.activityIndicator startAnimating];
    
    if (indexPath.item == 1) {
        cell.label.text = @"Cinecast";
        //cell.label.textColor = [UIColor whiteColor];
    }
    if (indexPath.item == 2) {
        //cell.label.textColor = [UIColor blackColor];
        cell.label.text = @"The Matinee";
        [cell.label sizeToFit];
        
    }
    if (indexPath.item != 1 && indexPath.item != 2) {
        cell.label.text = @"";
    }
    // indexPath contains .item and .section
    return cell;
}




@end
