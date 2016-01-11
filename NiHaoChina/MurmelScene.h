//
//  MurmelScene.h
//  NiHaoChina
//
//  Created by Leslie on 23.06.14.
//  Copyright (c) 2014 Leslie Zimmermann. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import <CoreMotion/CoreMotion.h>
#import "MurmelGame.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

@interface MurmelScene : SKScene <SKPhysicsContactDelegate>

@property (strong, nonatomic) MurmelGame *parentViewController;
@property (strong, nonatomic) CMMotionManager *motionManager;
@property NSInteger part;

@property (strong, nonatomic) SKSpriteNode *myMurmel;
@property (strong, nonatomic) SKSpriteNode *gradient;

@property (strong, nonatomic) SKLabelNode *centerLabel;

@property (strong, nonatomic) AVAudioPlayer *audioPlayer;

- (id)initWithSize:(CGSize)size andKey:(NSString *)key;

@end
