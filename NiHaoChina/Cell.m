//
//  Cell.m
//  Memory2
//
//  Created by Leslie on 23.05.14.
//  Copyright (c) 2014 Leslie Zimmermann. All rights reserved.
//

#import "Cell.h"

@implementation Cell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (IBAction)flipCard:(id)sender {
    if (!self.stopFlipping && !self.flipped) {
        self.flipped = YES;
        UIImage *img = [UIImage imageNamed:@"cardback.png"];
        [sender addSubview:self.cardLabel];
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:1];
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self cache:NO];
        [sender setImage:img forState:UIControlStateNormal];
        [UIView commitAnimations];
        
        [self.parentViewController flippedCardOfPair:self.pairNum andIndex:self.tag];
    }
}

- (void)flipBack
{
    self.flipped = NO;
    UIImage *img = [UIImage imageNamed:@"cardpattern.png"];
    [self.cardLabel removeFromSuperview];

    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:1];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self cache:NO];
    [self.cardBack setImage:img forState:UIControlStateNormal];
    [UIView commitAnimations];
}

- (void)allFlippedBack
{
    self.stopFlipping = NO;
}

- (void)removeCards
{
    self.flipped = NO;
    [self.cardBack removeFromSuperview];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
