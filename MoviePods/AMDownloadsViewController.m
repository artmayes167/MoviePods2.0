//
//  AMDownloadsViewController.m
//  MoviePods
//
//  Created by Arthur Mayes on 3/2/13.
//  Copyright (c) 2013 Arthur Mayes. All rights reserved.
//

#import "AMDownloadsViewController.h"
#import "AMAppDelegate.h"
#import "AMEpisodeViewController.h"
#import "GetKeyStrings.h"
#import "GetAndSaveData.h"
#import "AEMDownloads.h"
#import "AMCustomHeaderView.h"

@interface AMDownloadsViewController (){
    AMCustomHeaderView *headerView;
}
@property (nonatomic, strong) NSArray *currentItemArray;
@property (nonatomic) int podcastToLoad;
@end

@implementation AMDownloadsViewController

- (int)podcastToLoad
{
    AMAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    return appDelegate.podcastToShow;
}

- (NSArray *)currentItemArray
{
    if(!_currentItemArray)
    {
        if (self.view.tag < PODCAST_COUNT) {
            NSMutableArray *allItemsArray = [NSMutableArray new];
            NSString *podcastName = [[GetKeyStrings sharedKeyStrings]nameAtIndex:self.podcastToLoad];
            if ([[AEMDownloads sharedDownloads]allEpisodesForKey:podcastName]) {
                NSMutableDictionary *dictionaryOfFavorites = [[AEMDownloads sharedDownloads]allEpisodesForKey:podcastName];
                for (NSMutableDictionary *dictionary in [dictionaryOfFavorites objectEnumerator]) [allItemsArray addObject:dictionary];
                _currentItemArray = (NSArray *)allItemsArray;
            } else _currentItemArray = nil;
        } else _currentItemArray = nil;
    }
    return _currentItemArray;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    AMAppDelegate *delegate = [[UIApplication sharedApplication]delegate];
    int height = delegate.windowHeight;
    CGFloat width = self.tableView.bounds.size.width;
    CGRect rectForHeaderView = CGRectMake(0.0f, 0.0f, width, height/6);
    headerView = [[AMCustomHeaderView alloc] initWithFrame:rectForHeaderView];
    self.tableView.tableHeaderView = headerView;
}
- (void)viewWillAppear:(BOOL)animated
{
    self.currentItemArray = nil;
    [super viewWillAppear:animated];
    [self.tableView reloadData];
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
    if (height == 568 || height == 480) cell.textLabel.font = [UIFont systemFontOfSize:12.0f];
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
