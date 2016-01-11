//
//  Textadventure.h
//  NiHaoChina
//
//  Created by Leslie on 28.06.14.
//  Copyright (c) 2014 Leslie Zimmermann. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

@interface Textadventure : UIViewController

@property (strong, nonatomic) AppDelegate *appDelegate;

@property (strong, nonatomic) UIImageView *speakBubble;
@property (strong, nonatomic) UIImage *bubbleCN;
@property (strong, nonatomic) UIButton *nextBtn;

@property (strong, nonatomic) UIImageView *personDE;
@property (strong, nonatomic) UIImageView *personCN;

@property (strong, nonatomic) UITextView *textCN;

@property (strong, nonatomic) UIView *buttonsView;

@property (strong, nonatomic) AVAudioPlayer *audioPlayerCorrect;
@property (strong, nonatomic) AVAudioPlayer *audioPlayerWrong;

@property NSInteger part;

- (id)initWithKey:(NSString *)key;

@end
