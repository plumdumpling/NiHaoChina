//
//  Dialogue.h
//  NiHaoChina
//
//  Created by Leslie on 12.06.14.
//  Copyright (c) 2014 Leslie Zimmermann. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

@interface Dialogue : UIViewController

@property (strong, nonatomic) AppDelegate *appDelegate;

@property (strong, nonatomic) AVAudioPlayer *audioPlayer;

@property (strong, nonatomic) UIImageView *speakBubble;
@property (strong, nonatomic) UIImage *bubbleDE;
@property (strong, nonatomic) UIImage *bubbleCN;

@property (strong, nonatomic) UIImageView *personDE;
@property (strong, nonatomic) UIImageView *personCN;

@property (strong, nonatomic) UITextView *textDE;
@property (strong, nonatomic) UITextView *textCN;
@property (strong, nonatomic) UITextView *textDescription;
@property (strong, nonatomic) UIButton *nextBtn;
@property (strong, nonatomic) UIButton *listenAgainBtn;

@property NSInteger part;

- (id)initWithKey:(NSString *)key;

@end
