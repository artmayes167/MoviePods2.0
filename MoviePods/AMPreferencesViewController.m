//
//  AMPreferencesViewController.m
//  MoviePods
//
//  Created by Arthur Mayes on 3/2/13.
//  Copyright (c) 2013 Arthur Mayes. All rights reserved.
//

#import "AMPreferencesViewController.h"

@interface AMPreferencesViewController ()
- (IBAction)wiFiOnly:(UISwitch *)sender;
- (IBAction)offLineMode:(UISwitch *)sender;
@property (nonatomic, strong) NSArray *cellIdentifiers;
@property (nonatomic, strong) UISwitch *wifiSwitch;
@property (nonatomic, strong) UISwitch *offlineSwitch;
@end

@implementation AMPreferencesViewController

#define WIFI_DEFAULTS_KEY @"wifiOnly"
#define OFFLINE_DEFAULTS_KEY @"offlineOnly"
-(NSArray *)cellIdentifiers
{
    if (!_cellIdentifiers) _cellIdentifiers = @[@"WiFi", @"OffLine"];
    return _cellIdentifiers;
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
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //NSLog(@"default wifi = %u", [defaults boolForKey:WIFI_DEFAULTS_KEY]);
    [self.wifiSwitch setOn:[defaults boolForKey:WIFI_DEFAULTS_KEY] animated:NO];
    [self.offlineSwitch setOn:[defaults boolForKey:OFFLINE_DEFAULTS_KEY] animated:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.cellIdentifiers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifiers[indexPath.row] forIndexPath:indexPath];
    
    for (UIView *view in [cell.contentView subviews]) {
        if ([view isKindOfClass:[UISwitch class]]) {
            switch (indexPath.row) {
                case 0:
                    self.wifiSwitch = (UISwitch *)view;
                    break;
                case 1:
                    self.offlineSwitch = (UISwitch *)view;
                    break;
                default:
                    break;
            }
        }
    }
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

-(void)updatePreferences
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:self.wifiSwitch.on forKey:WIFI_DEFAULTS_KEY];
    [defaults setBool:self.offlineSwitch.on forKey:OFFLINE_DEFAULTS_KEY];
    [defaults synchronize];
}

- (IBAction)wiFiOnly:(UISwitch *)sender {
    if (sender.on) if (self.offlineSwitch.on) [self.offlineSwitch setOn:NO animated:YES];
    [self updatePreferences];
}

- (IBAction)offLineMode:(UISwitch *)sender {
    //NSLog(@"Switched offline, value = %u", sender.on);
    if (sender.on && self.wifiSwitch.on) [self.wifiSwitch setOn:NO animated:YES];
    [self updatePreferences];
}

-(void)dealloc
{
#ifdef DEBUG
	//NSLog(@"dealloc %@", self);
#endif
}
@end
