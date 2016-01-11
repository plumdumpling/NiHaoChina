//
//  CustomButton.m
//  NiHaoChina
//
//  Created by Leslie on 02.06.14.
//  Copyright (c) 2014 Leslie Zimmermann. All rights reserved.
//

#import "CustomButton.h"

@implementation CustomButton

- (id)initWithFrame:(CGRect)frame andImage:(NSString *)imageName
{
    self = [super initWithFrame:frame];
    if (self) {
        UIImage *btnImage = [UIImage imageNamed:imageName];
        [self setImage:btnImage forState:UIControlStateNormal];
        [self setImage:btnImage forState:UIControlStateHighlighted];
    }
    return self;
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
