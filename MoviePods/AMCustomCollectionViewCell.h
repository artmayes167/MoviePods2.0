//
//  AMCustomCollectionViewCell.h
//  MoviePods
//
//  Created by Arthur Mayes on 2/26/13.
//  Copyright (c) 2013 Arthur Mayes. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AMCustomCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@end
