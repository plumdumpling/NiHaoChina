//
//  FillInText.h
//  NiHaoChina
//
//  Created by Leslie on 28.06.14.
//  Copyright (c) 2014 Leslie Zimmermann. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

@interface FillInText : UIViewController

@property (strong, nonatomic) AppDelegate *appDelegate;

@property (strong, nonatomic) UIImageView *correctOverlay;
@property (strong, nonatomic) UIImageView *wrongOverlay;

@property (strong, nonatomic) UIView *textViews;
@property (strong, nonatomic) UIView *buttonsViews;

@property (strong, nonatomic) AVAudioPlayer *audioPlayerCorrect;
@property (strong, nonatomic) AVAudioPlayer *audioPlayerWrong;

@property NSInteger part;
@property NSInteger gap;

- (id)initWithKey:(NSString *)key;

@end
