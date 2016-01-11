//
//  ViewController.h
//  NiHaoChina
//
//  Created by Leslie on 01.06.14.
//  Copyright (c) 2014 Leslie Zimmermann. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "Popup.h"
#import "Infokomponente.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

@interface ViewController : UIPageViewController <UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@property (strong, nonatomic) AppDelegate *appDelegate;

@property (strong, nonatomic) MPMoviePlayerViewController *playerController;
@property (strong, nonatomic) UIButton *skipBtn;

@property (strong, nonatomic) UIPageControl *pageControl;
@property (strong, nonatomic) NSArray *rightItems;
@property (strong, nonatomic) Popup *launchPopup;
@property (strong, nonatomic) Infokomponente *infokomp;

@property BOOL nameSaved;

- (void)changeVC:(id)sender;

@end
