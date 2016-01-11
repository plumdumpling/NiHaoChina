//
//  InteractiveGraphics.h
//  NiHaoChina
//
//  Created by Leslie on 28.06.14.
//  Copyright (c) 2014 Leslie Zimmermann. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

@interface InteractiveGraphics : UIViewController

@property (strong, nonatomic) AppDelegate *appDelegate;

@property (strong, nonatomic) UIView *imagesView;
@property (strong, nonatomic) UIView *buttonsView;

@property (strong, nonatomic) AVAudioPlayer *audioPlayerCorrect;
@property (strong, nonatomic) AVAudioPlayer *audioPlayerWrong;

- (id)initWithKey:(NSString *)key;

@end
