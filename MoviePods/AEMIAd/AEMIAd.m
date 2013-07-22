//
//  AEMIAd.m
//  MoviePods
//
//  Created by Arthur Mayes on 11/8/12.
//  Copyright (c) 2012 Arthur Mayes. All rights reserved.
//

#import "AEMIAd.h"

static AEMIAd *sharedAd = nil;

@interface AEMIAd () {
    ADBannerView *adView;
    BOOL bannerIsVisible;
}

@end

@implementation AEMIAd

@synthesize adView;

- (id)init
{
    if (self = [super init])
    {
        
        // On iOS 6 ADBannerView introduces a new initializer, use it when available.
        
        if ([ADBannerView instancesRespondToSelector:@selector(initWithAdType:)]) adView = [[ADBannerView alloc] initWithAdType:ADAdTypeBanner];
        else adView = [[ADBannerView alloc] init];
        
        CGRect screenBounds = [[UIScreen mainScreen] bounds];
        adView.frame = CGRectOffset(adView.frame, 0, screenBounds.size.height-50);
        adView.delegate = self;
        
    }
    
    return self;
}

- (BOOL)allowActionToRun
{
    return TRUE;
}



- (void) attachAdToView:(UIView *)view
{
    if (bannerIsVisible) [view addSubview:self.adView];
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    [self.adView setHidden:NO];
    bannerIsVisible = YES;
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    [self.adView setHidden:YES];
    bannerIsVisible = NO;
}


+(AEMIAd *)sharedAd
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedAd = [[self alloc] init];
    });
	return sharedAd;
}

@end
