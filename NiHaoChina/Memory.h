//
//  Memory.h
//  NiHaoChina
//
//  Created by Leslie on 18.06.14.
//  Copyright (c) 2014 Leslie Zimmermann. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

@interface Memory : UICollectionViewController

@property (strong, nonatomic) AppDelegate *appDelegate;

@property (strong, nonatomic) NSMutableArray *dataArray;
@property NSInteger flippedPair;
@property NSInteger flippedIndex;
@property BOOL cardFlipped;

@property (strong, nonatomic) AVAudioPlayer *audioPlayer;

- (id)initWithKey:(NSString *)key;
- (void)flippedCardOfPair:(NSInteger)pair andIndex:(NSInteger)index;

@end
