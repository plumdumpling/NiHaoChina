//
//  Cell.h
//  Memory2
//
//  Created by Leslie on 23.05.14.
//  Copyright (c) 2014 Leslie Zimmermann. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"
#import "Memory.h"

@interface Cell : UICollectionViewCell

@property Memory* parentViewController;
@property (strong, nonatomic) IBOutlet UILabel *cardLabel;
@property (strong, nonatomic) IBOutlet UIButton *cardBack;
@property BOOL flipped;
@property BOOL stopFlipping;
@property NSInteger pairNum;

- (void)flipBack;
- (void)allFlippedBack;
- (void)removeCards;

@end
