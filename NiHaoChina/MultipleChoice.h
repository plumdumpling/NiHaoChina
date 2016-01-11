//
//  MultipleChoice.h
//  NiHaoChina
//
//  Created by Leslie on 27.06.14.
//  Copyright (c) 2014 Leslie Zimmermann. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

@interface MultipleChoice : UIViewController

@property (strong, nonatomic) AppDelegate *appDelegate;

@property (strong, nonatomic) UILabel *questionLabel;
@property (strong, nonatomic) UIView *answersView;

@property (strong, nonatomic) UIImageView *correctOverlay;
@property (strong, nonatomic) UIImageView *wrongOverlay;

@property (strong, nonatomic) AVAudioPlayer *audioPlayerCorrect;
@property (strong, nonatomic) AVAudioPlayer *audioPlayerWrong;

@property NSInteger part;

- (id)initWithKey:(NSString *)key;

@end
