//
//  Popup.h
//  NiHaoChina
//
//  Created by Leslie on 14.06.14.
//  Copyright (c) 2014 Leslie Zimmermann. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

@interface Popup : UIView

@property (strong, nonatomic) AppDelegate *appDelegate;

@property (strong, nonatomic) UIButton *returnBtn;
@property (strong, nonatomic) UIButton *menuBtn;
@property (strong, nonatomic) UIButton *nextBtn;
@property (strong, nonatomic) UIButton *yesBtn;
@property (strong, nonatomic) UIButton *noBtn;
@property (strong, nonatomic) UITextField *nameField;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;

- (id)initFor:(NSString *)type withDescription:(NSString *)description returnBtn:(BOOL)returnBtn menuBtn:(BOOL)menuBtn nextBtn:(BOOL)nextBtn yesBtn:(BOOL)yesBtn noBtn:(BOOL)noBtn;

@end
