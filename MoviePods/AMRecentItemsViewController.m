//
//  AMRecentItemsViewController.m
//  MoviePods
//
//  Created by Arthur Mayes on 2/26/13.
//  Copyright (c) 2013 Arthur Mayes. All rights reserved.
//

#import "AMAppDelegate.h"
#import "AMRecentItemsViewController.h"
#import "AMEpisodeViewController.h"
#import "GetKeyStrings.h"
#import "GetAndSaveData.h"
#import "AMCustomHeaderView.h"

@interface AMRecentItemsViewController (){
    AMCustomHeaderView *headerView;
}
@property (nonatomic, strong) NSArray *currentItemArray;
@property (nonatomic) int podcastToLoad;
@end

@implementation AMRecentItemsViewController

- (int)podcastToLoad
{
    AMAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    return appDelegate.podcastToShow;
}

- (NSArray *)currentItemArray{
    if(!_currentItemArray)
    {
        if (self.view.tag < PODCAST_COUNT && [[GetAndSaveData sharedGetAndSave]arrayForParsedFeed:[[GetKeyStrings sharedKeyStrings]nameAtIndex:self.podcastToLoad]]) {
            _currentItemArray = [[GetAndSaveData sharedGetAndSave]arrayForParsedFeed:[[GetKeyStrings sharedKeyStrings]nameAtIndex:self.podcastToLoad]];
        } else  _currentItemArray = nil;
    }
    return _currentItemArray;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.parentViewController.title = @"Episodes";
    
    AMAppDelegate *delegate = [[UIApplication sharedApplication]delegate];
    int height = delegate.windowHeight;
    CGFloat width = self.tableView.bounds.size.width;
    CGRect rectForHeaderView = CGRectMake(0.0f, 0.0f, width, height/6);
    headerView = [[AMCustomHeaderView alloc] initWithFrame:rectForHeaderView];
    self.tableView.tableHeaderView = headerView;
     
    
    [self.refreshControl addTarget:self
                            action:@selector(refresh)
                  forControlEvents:UIControlEventValueChanged];
}

- (void)refresh
{
    NSDictionary *__block podcastDictionary;
    [self.refreshControl beginRefreshing];
    dispatch_queue_t q = dispatch_queue_create("table view loading queue", NULL);
    dispatch_async(q, ^{
        if ([[GetAndSaveData sharedGetAndSave]arrayOfParsedNamesFeeds]) {
            podcastDictionary = [[GetAndSaveData sharedGetAndSave]arrayOfParsedNamesFeeds][self.podcastToLoad];
        } else {
            podcastDictionary = @{@"description" : @"Unavailable in offline mode", @"itunesSummary" : @"Unavailable in offline mode"};
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            
            headerView.myLabel.text = self.podcastToLoad == 5 ? [podcastDictionary objectForKey:@"description"] : [podcastDictionary objectForKey:@"itunesSummary"];
            [self.refreshControl endRefreshing];
        });
    });
}


#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return [[GetKeyStrings sharedKeyStrings]nameAtIndex:self.podcastToLoad];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.currentItemArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.textLabel.text = [self.currentItemArray[indexPath.row] objectForKey:@"title"];
    AMAppDelegate *delegate = [[UIApplication sharedApplication]delegate];
    int height = delegate.windowHeight;
    if (height == 568 || height == 480) cell.textLabel.font = [UIFont systemFontOfSize:12];
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    cell.tag = indexPath.row;
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(UITableViewCell *)sender
{
    AMEpisodeViewController *episodeVC = (AMEpisodeViewController *)segue.destinationViewController;
    episodeVC.currentPodcast = self.podcastToLoad;
    episodeVC.episode = self.currentItemArray[sender.tag];
    
}


@end
