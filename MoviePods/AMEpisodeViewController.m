//
//  AMEpisodeViewController.m
//  MoviePods
//
//  Created by Arthur Mayes on 2/27/13.
//  Copyright (c) 2013 Arthur Mayes. All rights reserved.
//

#import "AMEpisodeViewController.h"
#import "GetAndSaveData.h"
#import "GetKeyStrings.h"
#import "AMInitiateDownload.h"
#import "AMAppDelegate.h"
#import "UIAlertView+MKBlockAdditions.h"
#import "AEMDownloads.h"
#import <AVFoundation/AVFoundation.h>

@interface AMEpisodeViewController () <AMIniateDownloadsDelegate, AVAudioPlayerDelegate>
@property (weak, nonatomic) IBOutlet UISlider *amSlider;
@property (weak, nonatomic) IBOutlet UILabel *endLabel;
@property (weak, nonatomic) IBOutlet UILabel *startLabel;

@property (weak, nonatomic) IBOutlet UIView *sliderView;
@property (weak, nonatomic) IBOutlet UILabel *episodeTitle;
@property (weak, nonatomic) IBOutlet UILabel *episodeDate;
@property (weak, nonatomic) IBOutlet UIWebView *episodeWebView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) UIBarButtonItem *downloadButton;
@property (weak, nonatomic) UIBarButtonItem *playButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *favoriteButton;
@property (strong, nonatomic) NSArray *downloadButtonsArray;
@property (strong, nonatomic) NSArray *playButtonsArray;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) AVAudioPlayer *player;
- (IBAction)play:(id)sender;
- (IBAction)download:(id)sender;
- (IBAction)favorite:(id)sender;
- (IBAction)moveToPointInPodcast:(UISlider *)sender;

@end

@implementation AMEpisodeViewController

-(NSArray *)downloadButtonsArray{
    if (!_downloadButtonsArray) {
        NSMutableArray *toolbarItems = [NSMutableArray arrayWithArray:self.toolbar.items];
        for (NSUInteger i = 0; i < [toolbarItems count]; i++) {
    		UIBarButtonItem *barButtonItem = [toolbarItems objectAtIndex:i];
    		if (barButtonItem.action == @selector(download:)) {
    			self.downloadButton = toolbarItems[i];
                self.toolbar.items = toolbarItems;
    			break;
    		}
    	}
        self.downloadButton.tag = 1;
        
        self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [self.activityIndicator setFrame:CGRectMake(0.0f, 0.0f, 30.0f, 30.0f)];
        UIBarButtonItem *activityButton = [[UIBarButtonItem alloc]initWithCustomView:self.activityIndicator];
        activityButton.style = UIBarButtonItemStyleBordered;
        activityButton.tag = 2;
    
        UIBarButtonItem *deleteButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(download:)];
        deleteButton.style = UIBarButtonItemStyleBordered;
        _downloadButtonsArray = @[self.downloadButton, activityButton, deleteButton];
    }
    return _downloadButtonsArray;
}

-(NSArray *)playButtonsArray
{
    if (!_playButtonsArray) {
        NSMutableArray *toolbarItems = [NSMutableArray arrayWithArray:self.toolbar.items];
        for (NSUInteger i = 0; i < [toolbarItems count]; i++) {
    		UIBarButtonItem *barButtonItem = [toolbarItems objectAtIndex:i];
    		if (barButtonItem.action == @selector(play:)) {
    			self.playButton = toolbarItems[i];
                self.toolbar.items = toolbarItems;
    			break;
    		}
    	}
        self.playButton.tag = 0;
        
        UIBarButtonItem *pauseButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemPause target:self action:@selector(play:)];
        pauseButton.style = UIBarButtonItemStyleBordered;
        pauseButton.tag = 1;
        _playButtonsArray = @[self.playButton, pauseButton];
    }
    return _playButtonsArray;
}

-(AVAudioPlayer *)player
{
    if (!_player) {
        playerExists = YES;
        NSData *data = [[AEMDownloads sharedDownloads]getDownloadForKey:[self.episode objectForKey:@"title"]];
        
        _player = [[AVAudioPlayer alloc] initWithData:data
                                                    error:nil];
        _player.delegate = self;
        //self.amSlider.continuous = NO;
        self.amSlider.maximumValue = [_player duration]-1;
        self.amSlider.value = 0.0f;
        UIGraphicsBeginImageContext(CGSizeMake(25.0f, 25.0f));
        [[UIImage imageNamed:@"sliderThumb"] drawInRect:CGRectMake(0.0, 0.0, 25.0, 25.0)];
        [self.amSlider setThumbImage:UIGraphicsGetImageFromCurrentImageContext() forState:UIControlStateNormal];
        UIGraphicsEndImageContext();
        UIGraphicsBeginImageContext(CGSizeMake(25.0f, 25.0f));
        [[UIImage imageNamed:@"sliderButtonMoving"] drawInRect:CGRectMake(0.0, 0.0, 25.0, 25.0)];
        [self.amSlider setThumbImage:UIGraphicsGetImageFromCurrentImageContext() forState:UIControlStateHighlighted];
        UIGraphicsEndImageContext();
        
        [_player prepareToPlay];
        
        playTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTime:) userInfo:nil repeats:YES];
    }
    return _player;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)fixThePodcastLink
{
    NSString *link = [self.episode objectForKey:@"podcastLink"];
    //NSLog(@"%@", link);
    if (link.length < 5) {
        NSString *tempString = [self.episode objectForKey:@"itunesSummary"] ? [self.episode objectForKey:@"itunesSummary"] : [self.episode objectForKey:@"summary"];
        NSString *summary = [tempString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSRange range = [summary rangeOfString:@"URL: "];
        //NSLog(@"range = %i, object at range = %@", range.location, [summary substringFromIndex:range.location+5]);
        NSMutableDictionary *tempEpisode = [self.episode mutableCopy];
        [tempEpisode setObject:[summary substringFromIndex:range.location+5] forKey:@"podcastLink"];
        self.episode = tempEpisode;
    }
}

#pragma mark - View Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [AMInitiateDownload sharedInitiator].delegate = self;
    
	if ([[AEMDownloads sharedDownloads]episodeForPodcast:[[GetKeyStrings sharedKeyStrings]nameAtIndex:self.currentPodcast] titled:[self.episode objectForKey:@"title"]]) {
        self.episode = [[AEMDownloads sharedDownloads]episodeForPodcast:[[GetKeyStrings sharedKeyStrings]nameAtIndex:self.currentPodcast] titled:[self.episode objectForKey:@"title"]];
        NSMutableArray *toolbarItems = [NSMutableArray arrayWithArray:self.toolbar.items];
        for (NSUInteger i = 0; i < [toolbarItems count]; i++) {
            UIBarButtonItem *barButtonItem = [toolbarItems objectAtIndex:i];
            
            if (barButtonItem.action == @selector(download:)) {
                [toolbarItems replaceObjectAtIndex:i withObject:self.downloadButtonsArray[2]];
                self.toolbar.items = toolbarItems;
            }
        }
    } else if ([[[GetAndSaveData sharedGetAndSave]dictionaryOfDownloads] objectForKey:[self.episode objectForKey:@"title"]]){
        NSMutableArray *toolbarItems = [NSMutableArray arrayWithArray:self.toolbar.items];
        for (NSUInteger i = 0; i < [toolbarItems count]; i++) {
            UIBarButtonItem *barButtonItem = [toolbarItems objectAtIndex:i];
            
            if (barButtonItem.action == @selector(download:)) {
                [toolbarItems replaceObjectAtIndex:i withObject:self.downloadButtonsArray[1]];
                [self.activityIndicator startAnimating];
                self.toolbar.items = toolbarItems;
            }
        }
    }
    self.sliderView.hidden = YES;
    sliderViewIsVisible = NO;
}

-(void)viewWillAppear:(BOOL)animated
{
    if (self.currentPodcast == 4) [self fixThePodcastLink]; // mamo puts the link in their summary
    
    self.episodeTitle.text = [self.episode objectForKey:@"title"];
    if ([self.episode objectForKey:@"date"]) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
        
        self.episodeDate.text = [dateFormatter stringFromDate:[self.episode objectForKey:@"date"]];
    } else self.episodeDate.text = @"";
    
    if (![self.episode objectForKey:@"itunesSummary"]) [self.episodeWebView loadHTMLString:[self.episode objectForKey:@"summary"]
                                                                                   baseURL:nil];
    else [self.episodeWebView loadHTMLString:[self.episode objectForKey:@"itunesSummary"]
                                     baseURL:nil];
    
    if ([self isAFavorite]) self.favoriteButton.tintColor = [UIColor yellowColor];
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (playerExists) {
        [self.player stop];
        [playTimer invalidate];
    }
    if ([self.activityIndicator isAnimating]) [self.activityIndicator stopAnimating];
}

-(void)viewDidDisappear:(BOOL)animated
{
    
}


- (IBAction)play:(id)sender 
{
    if ([[AEMDownloads sharedDownloads]episodeForPodcast:[[GetKeyStrings sharedKeyStrings]nameAtIndex:self.currentPodcast] titled:[self.episode objectForKey:@"title"]]) {
        if (!sliderViewIsVisible) [self performSliderViewEnteringAnimation];
        else [self performSliderViewExitingAnimation];
        
        NSMutableArray *toolbarItems = [NSMutableArray arrayWithArray:self.toolbar.items];
        for (NSUInteger i = 0; i < [toolbarItems count]; i++) {
            UIBarButtonItem *barButtonItem = [toolbarItems objectAtIndex:i];
            
            if (barButtonItem.action == @selector(play:)) {
                if (barButtonItem.tag == 0) {
                    [toolbarItems replaceObjectAtIndex:i withObject:self.playButtonsArray[1]];
                    [self.player play];
                } else {
                    [toolbarItems replaceObjectAtIndex:i withObject:self.playButtonsArray[0]];
                    [self.player pause];
                }
                self.toolbar.items = toolbarItems;
            }
        }
        isPlaying = self.player.isPlaying;
        wait = !isPlaying;
        
    } else {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        BOOL offlineOnly = [defaults boolForKey:@"offlineOnly"];
        BOOL wifiOnly = [defaults boolForKey:@"wifiOnly"];
        AMAppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
        BOOL wifiAvailable = appDelegate.wifi;
        if (offlineOnly || (wifiOnly && !wifiAvailable)) {
            if (offlineOnly) {
                [UIAlertView alertViewWithTitle:@"Sorry"
                                        message:@"You are in Off-Line Only mode"
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:[NSArray arrayWithObjects:nil]
                                      onDismiss:^(int buttonIndex){}
                                       onCancel:^(){}];
                //[alert show];
            } else {
                [UIAlertView alertViewWithTitle:@"Sorry"
                                        message:@"Wi-Fi is Unavailable"
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:[NSArray arrayWithObjects:nil]
                                      onDismiss:^(int buttonIndex){}
                                       onCancel:^(){}];
                //[alert show];
            }
            
        } else {
            NSURLRequest *request;
            if ([[self.episode objectForKey:@"podcastLink"] length] > 5)
            {
                request = [[NSURLRequest alloc]
                           initWithURL: [NSURL URLWithString: [self.episode objectForKey:@"podcastLink"]]];
            } else
            {
                request = [[NSURLRequest alloc]
                           initWithURL: [NSURL URLWithString: [self.episode objectForKey:@"link"]]];
            }
            
            [self.episodeWebView loadRequest:request];
        }
        
    }
}

- (void)updateTime:(NSTimer *)timer
{
    if (!wait) {
        if (!isPlaying) {
            //NSLog(@"NotPlaying");
            wait = YES;
            NSMutableArray *toolbarItems = [NSMutableArray arrayWithArray:self.toolbar.items];
            for (NSUInteger i = 0; i < [toolbarItems count]; i++) {
                UIBarButtonItem *barButtonItem = [toolbarItems objectAtIndex:i];
                
                if (barButtonItem.action == @selector(play:)) {
                    [toolbarItems replaceObjectAtIndex:i withObject:self.playButtonsArray[0]];
                    [self performSliderViewExitingAnimation];
                    self.toolbar.items = toolbarItems;
                }
            }
        }
        
        if (!sliderMoved) [self.amSlider setValue:self.player.currentTime animated:YES]; // This prevents the slider from bouncing back and forth
        else sliderMoved = NO;
        
        [self setTimeLabels];
    }

}
-(void)setTimeLabels
{
    int hours, minutes, seconds;
    hours = (int)self.player.currentTime / 3600;
    minutes = ((int)self.player.currentTime % 3600)/60;
    seconds = ((int)self.player.currentTime % 3600)%60;
    
    int total;
    int totalHours, totalMinutes, totalSeconds;
    total = (int)self.player.duration -(int)self.player.currentTime;
    totalHours = total/3600;
    totalMinutes = (total % 3600)/60;
    totalSeconds = (total % 3600)%60;
    
    self.startLabel.text = [NSString stringWithFormat:@"%02d:%02d:%02d", hours, minutes, seconds];
    self.endLabel.text = [NSString stringWithFormat:@"%02d:%02d:%02d", totalHours, totalMinutes, totalSeconds];
}

- (IBAction)moveToPointInPodcast:(UISlider *)sender
{
    wait = YES;
    self.player.currentTime = self.amSlider.value;
    isPlaying = self.player.isPlaying;
    sliderMoved = YES;
    wait = NO;
}

-(int)thereAreConnectivityIssues
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL offlineOnly = [defaults boolForKey:@"offlineOnly"];
    BOOL wifiOnly = [defaults boolForKey:@"wifiOnly"];
    AMAppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    BOOL wifiAvailable = appDelegate.wifi;
    
    int i = 0;
    if (offlineOnly || (wifiOnly && !wifiAvailable)){
        if (offlineOnly) i = 1;
        else i = 2;
    }
        
    return i;
}

- (IBAction)download:(UIBarButtonItem *)sender {
    NSMutableArray *toolbarItems = [NSMutableArray arrayWithArray:self.toolbar.items];
    for (NSUInteger i = 0; i < [toolbarItems count]; i++) {
        UIBarButtonItem *barButtonItem = [toolbarItems objectAtIndex:i];
        
        if (barButtonItem.action == @selector(download:)) {
            if (barButtonItem.tag == 1) {
                int problem = [self thereAreConnectivityIssues];
                if (problem) {
                    if (problem == 1) {
                        [UIAlertView alertViewWithTitle:@"Sorry"
                                                message:@"You are in Off-Line Only mode"
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:[NSArray arrayWithObjects:nil]
                                              onDismiss:^(int buttonIndex){}
                                               onCancel:^(){}];
                        //[alert show];
                    } else {
                        [UIAlertView alertViewWithTitle:@"Sorry"
                                                message:@"Wi-Fi is Unavailable"
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:[NSArray arrayWithObjects:nil]
                                              onDismiss:^(int buttonIndex){}
                                               onCancel:^(){}];
                        //[alert show];
                    }
                    
                } else {
                    AMEpisodeViewController * __weak weakSelf = self; // prevents retain cycle in blocks
                    [UIAlertView alertViewWithTitle:@"Wait"
                                            message:@"Are you sure you want to download this podcast?"
                                  cancelButtonTitle:@"YES"
                                  otherButtonTitles:[NSArray arrayWithObjects:@"No Thanks", nil]
                                          onDismiss:^(int buttonIndex){}
                                           onCancel:^(){
                                               // set new item for download
                                               NSMutableDictionary *dict = [self.episode mutableCopy];
                                               [dict setObject:[[GetKeyStrings sharedKeyStrings]nameAtIndex:self.currentPodcast] forKey:@"name"];
                                               weakSelf.episode = [dict copy];
                                               
                                               [[AMInitiateDownload sharedInitiator] downloadPodcast:self.episode];
                                               [toolbarItems replaceObjectAtIndex:i withObject:self.downloadButtonsArray[1]];
                                               [weakSelf.activityIndicator startAnimating];
                                               weakSelf.toolbar.items = toolbarItems;
                                           }];
                    //[alert show];
                }
            
            } else {
                AMEpisodeViewController * __weak weakSelf = self; // prevents retain cycle in blocks
                [UIAlertView alertViewWithTitle:@"Wait"
                                        message:@"Are you sure you want to delete this download?"
                              cancelButtonTitle:@"YES"
                              otherButtonTitles:[NSArray arrayWithObjects:@"No Thanks", nil]
                                      onDismiss:^(int buttonIndex){}
                                       onCancel:^(){
                                           // delete the download
                                           [[AEMDownloads sharedDownloads] deleteDownloadForKey:[self.episode objectForKey:@"title"]];
                                           [[AEMDownloads sharedDownloads] deleteEpisodeTitled:[self.episode objectForKey:@"title"] forPodcast:[weakSelf.episode objectForKey:@"name"]];
                                           [toolbarItems replaceObjectAtIndex:i withObject:self.downloadButtonsArray[0]];
                                           weakSelf.toolbar.items = toolbarItems;
                                           if (sliderViewIsVisible) {
                                               [weakSelf performSliderViewExitingAnimation];
                                           }
                                       }];
                //[alert show];
            }
            break;
        }
    }
    
    
    for (UIBarButtonItem *button in self.downloadButtonsArray) {
        if ([self.downloadButton isEqual:button]) {
            int index = [self.downloadButtonsArray indexOfObject:button];
            if (index > 1) index = 0;
            else index++;
            
            self.downloadButton = [self.downloadButtonsArray objectAtIndex:index];
        }
    }
     
}

-(BOOL)isAFavorite
{
    NSString *podcastName = [[GetKeyStrings sharedKeyStrings]nameAtIndex:self.currentPodcast];
    NSArray *arrayOfSavedNames = [[GetAndSaveData sharedGetAndSave]getAllNames];
    BOOL alreadyPresentInDictionary = NO;
    if ([arrayOfSavedNames count] > 0) {
        for (NSString *name in arrayOfSavedNames) {
            if ([name isEqualToString:podcastName]) {
                if ([[[GetAndSaveData sharedGetAndSave]favoritesDictionaryForName:podcastName] objectForKey:self.episodeTitle.text]) alreadyPresentInDictionary = YES;
            }
        }
    }
    return alreadyPresentInDictionary;
}

- (IBAction)favorite:(UIBarButtonItem *)sender
{
    NSString *podcastName = [[GetKeyStrings sharedKeyStrings]nameAtIndex:self.currentPodcast];
    NSArray *arrayOfSavedNames = [[GetAndSaveData sharedGetAndSave]getAllNames];
    BOOL alreadyPresentInDictionary = NO;
    if ([arrayOfSavedNames count] > 0) {
        for (NSString *name in arrayOfSavedNames) if ([name isEqualToString:podcastName]) alreadyPresentInDictionary = YES;
    }
    NSMutableDictionary *dictionaryForTheCurrentPodcast;
    if (alreadyPresentInDictionary) dictionaryForTheCurrentPodcast = [[GetAndSaveData sharedGetAndSave]favoritesDictionaryForName:podcastName];
    else dictionaryForTheCurrentPodcast = [[NSMutableDictionary alloc] init];
    
    
    if (sender.tintColor == [UIColor yellowColor]) {
        sender.tintColor = [UIColor clearColor];
        [dictionaryForTheCurrentPodcast removeObjectForKey:self.episodeTitle.text];
    } else {
        sender.tintColor = [UIColor yellowColor];
        [dictionaryForTheCurrentPodcast setObject:self.episode forKey:self.episodeTitle.text];
    }
    
    if ([dictionaryForTheCurrentPodcast count] > 0) [[GetAndSaveData sharedGetAndSave]setFavorites:dictionaryForTheCurrentPodcast ForName:podcastName];
    else [[GetAndSaveData sharedGetAndSave]deleteFavoritesForName:podcastName];
    
}

-(BOOL)isPodcastLink:(NSString *)nameOfDownload
{
    NSString *podCastLink;
    if ([[self.episode objectForKey:@"podcastLink"] length] > 5) podCastLink = [self.episode objectForKey:@"podcastLink"];
    else podCastLink = [self.episode objectForKey:@"link"];
    
    return [nameOfDownload isEqualToString:podCastLink];
}

#pragma mark - AMInitiateDownload delegate methods

-(void)downloadingFailed:(NSString *)nameOfDownload
{
    if ([self isPodcastLink:nameOfDownload]) {
        NSMutableArray *toolbarItems = [NSMutableArray arrayWithArray:self.toolbar.items];
        for (NSUInteger i = 0; i < [toolbarItems count]; i++) {
            UIBarButtonItem *barButtonItem = [toolbarItems objectAtIndex:i];
            
            if (barButtonItem.tag == 2) {
                [toolbarItems replaceObjectAtIndex:i withObject:self.downloadButtonsArray[0]];
                self.toolbar.items = toolbarItems;
                [self.activityIndicator stopAnimating];
            }
        }
        [UIAlertView alertViewWithTitle:@"OOPS"
                                message:@"This download failed."
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:[NSArray arrayWithObjects:nil]
                              onDismiss:^(int buttonIndex){}
                               onCancel:^(){}];
    }
}
-(void)downloadReady:(NSString *)nameOfDownload
{
    if ([self isPodcastLink:nameOfDownload]) {
        NSMutableArray *toolbarItems = [NSMutableArray arrayWithArray:self.toolbar.items];
        for (NSUInteger i = 0; i < [toolbarItems count]; i++) {
            UIBarButtonItem *barButtonItem = [toolbarItems objectAtIndex:i];
            
            if (barButtonItem.tag == 2) {
                [toolbarItems replaceObjectAtIndex:i withObject:self.downloadButtonsArray[2]];
                self.toolbar.items = toolbarItems;
                [self.activityIndicator stopAnimating];
            }
        }

    }
}

#pragma mark - Animations

-(void)performSliderViewEnteringAnimation
{
    CGFloat screenScale = [[UIScreen mainScreen] scale];
    CGSize size;
    if (screenScale == 2.0f) size = self.view.bounds.size;
    else size = CGSizeMake(320.0, 372.0);
    
    CGPoint startPoint = CGPointMake(size.width / 2.0f, size.height + (self.sliderView.bounds.size.height/2) - self.toolbar.bounds.size.height);
    self.sliderView.center = startPoint;
    
    CGPoint endPoint = CGPointMake(size.width / 2.0f, size.height - (self.sliderView.bounds.size.height/2) - self.toolbar.bounds.size.height);
    
    [self.episodeWebView setNeedsUpdateConstraints];
    self.sliderView.hidden = NO;
    AMEpisodeViewController * __weak weakSelf = self; // prevents retain cycle in blocks
    [UIView animateWithDuration:0.65f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^
     {
         
         weakSelf.sliderView.center = endPoint;
         
     }
                     completion:nil];
    
    sliderViewIsVisible = YES;
}

-(void)performSliderViewExitingAnimation
{
    CGFloat screenScale = [[UIScreen mainScreen] scale];
    CGSize size;
    if (screenScale == 2.0f) size = self.view.bounds.size;
    else size = CGSizeMake(320.0, 372.0);
    
    CGPoint endPoint = CGPointMake(size.width / 2.0f, size.height + (self.sliderView.bounds.size.height/2) - self.toolbar.bounds.size.height);
    [self.episodeWebView setNeedsUpdateConstraints];
    AMEpisodeViewController * __weak weakSelf = self; // prevents retain cycle in blocks
    [UIView animateWithDuration:0.65f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^
     {
         
         weakSelf.sliderView.center = endPoint;
         
     }
                     completion:^(BOOL finished){
                         weakSelf.sliderView.hidden = YES;
                     }];
    sliderViewIsVisible = NO;
}

-(void)dealloc
{
#ifdef DEBUG
	//NSLog(@"dealloc %@", self);
#endif
}

@end
