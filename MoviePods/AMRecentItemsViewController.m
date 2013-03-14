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

@interface AMRecentItemsViewController ()
@property (nonatomic, strong) NSArray *currentItemArray;
@property (nonatomic) int podcastToLoad;
@end

@implementation AMRecentItemsViewController

-(int)podcastToLoad
{
    AMAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    return appDelegate.podcastToShow;
}

-(NSArray *)currentItemArray{
    if(!_currentItemArray)
    {
        if (self.view.tag < PODCAST_COUNT && [[GetAndSaveData sharedGetAndSave]arrayForParsedFeed:[[GetKeyStrings sharedKeyStrings]nameAtIndex:self.podcastToLoad]]) {
            _currentItemArray = [[GetAndSaveData sharedGetAndSave]arrayForParsedFeed:[[GetKeyStrings sharedKeyStrings]nameAtIndex:self.podcastToLoad]];
        } else  _currentItemArray = nil;
    }
    return _currentItemArray;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    if (self = [super initWithStyle:style]) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.parentViewController.title = @"Episodes";
    
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
