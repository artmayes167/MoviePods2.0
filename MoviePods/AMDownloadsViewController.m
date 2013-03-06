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

@interface AMDownloadsViewController ()
@property (nonatomic, strong) NSArray *currentItemArray;
@property (nonatomic) int podcastToLoad;
@end

@implementation AMDownloadsViewController

-(int)podcastToLoad
{
    AMAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    return appDelegate.podcastToShow;
}

-(NSArray *)currentItemArray{
    if(!_currentItemArray)
    {
        if (self.view.tag < PODCAST_COUNT) {
            NSMutableArray *allItemsArray = [NSMutableArray new];
            NSString *podcastName = [[GetKeyStrings sharedKeyStrings]nameAtIndex:self.podcastToLoad];
            if ([[AEMDownloads sharedDownloads]allEpisodesForKey:podcastName]) {
                NSMutableDictionary *dictionaryOfFavorites = [[AEMDownloads sharedDownloads]allEpisodesForKey:podcastName];
                for (NSMutableDictionary *dictionary in [dictionaryOfFavorites objectEnumerator]) {
                    [allItemsArray addObject:dictionary];
                }
                _currentItemArray = (NSArray *)allItemsArray;
            } else {
                _currentItemArray = nil;
            }
            
        } else {
            _currentItemArray = nil;
        }
        
    }
    return _currentItemArray;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.tableView.bounds.size.width, 90.0)];
    headerView.backgroundColor = [UIColor blackColor];
    
    UIImage *podcasterImage = [UIImage imageNamed:[[GetKeyStrings sharedKeyStrings]imageNameAtIndex:self.podcastToLoad]];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 115.0f, 90.0f)];
    imageView.image = podcasterImage;
    [headerView addSubview:imageView];
    
    CGRect contentRect = headerView.bounds;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(120.0f, 0.0f, contentRect.size.width - 120.0f, contentRect.size.height)];
    NSDictionary *podcastDictionary;
    if ([[GetAndSaveData sharedGetAndSave]arrayOfParsedNamesFeeds]) {
        podcastDictionary = [[GetAndSaveData sharedGetAndSave]arrayOfParsedNamesFeeds][self.podcastToLoad];
    } else {
        podcastDictionary = @{@"description" : @"Unavailable in offline mode", @"itunesSummary" : @"Unavailable in offline mode"};
    }
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.numberOfLines = 0;
    label.font = [UIFont fontWithName:@"Helvetica" size:9.0f];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.text = self.podcastToLoad == 5 ? [podcastDictionary objectForKey:@"description"] : [podcastDictionary objectForKey:@"itunesSummary"];
    [headerView addSubview:label];
    self.tableView.tableHeaderView = headerView;
}
-(void)viewWillAppear:(BOOL)animated
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
    cell.textLabel.font = [UIFont systemFontOfSize:12];
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    cell.tag = indexPath.row;
    return cell;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(UITableViewCell *)sender
{
    //NSLog(@"sender's class is %@", [sender class]);
    AMEpisodeViewController *episodeVC = (AMEpisodeViewController *)segue.destinationViewController;
    episodeVC.currentPodcast = self.podcastToLoad;
    episodeVC.episode = self.currentItemArray[sender.tag];
}

@end
