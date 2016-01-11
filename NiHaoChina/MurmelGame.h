//
//  MurmelGame.h
//  NiHaoChina
//
//  Created by Leslie on 23.06.14.
//  Copyright (c) 2014 Leslie Zimmermann. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>
#import "AppDelegate.h"

@interface MurmelGame : UIViewController

@property (strong, nonatomic) AppDelegate *appDelegate;

@property (strong, nonatomic) UIButton *startBtn;

- (id)initWithKey:(NSString *)key;
- (void)endOfGame;

@end
