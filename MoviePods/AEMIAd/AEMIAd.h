//
//  AEMIAd.h
//  MoviePods
//
//  Created by Arthur Mayes on 11/8/12.
//  Copyright (c) 2012 Arthur Mayes. All rights reserved.
//

#import <iAd/iAd.h>

@interface AEMIAd : NSObject <ADBannerViewDelegate>

@property (nonatomic, strong) ADBannerView *adView;

+(AEMIAd *)sharedAd;

- (void) attachAdToView:(UIView *)view;

@end
