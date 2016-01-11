//
//  PageContentViewController.h
//  NiHaoChina
//
//  Created by Leslie on 01.06.14.
//  Copyright (c) 2014 Leslie Zimmermann. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface PageContentViewController : UIViewController

@property (strong, nonatomic) AppDelegate *appDelegate;
@property (nonatomic, readonly) NSUInteger pageIndex;
@property (strong, nonatomic) UITapGestureRecognizer *singleTap;
@property (strong, nonatomic) UILabel *startLabel;

- (id)initWithPageTitle:(NSString *)pageTitle andDescription:(NSString *)pageDescription andImage:(NSString *)imageName atIndex:(NSUInteger)index;

@end
