//
//  ChapterContentViewController.h
//  NiHaoChina
//
//  Created by Leslie on 02.06.14.
//  Copyright (c) 2014 Leslie Zimmermann. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface ChapterContentViewController : UIViewController

@property (strong, nonatomic) AppDelegate *appDelegate;
@property (nonatomic, readonly) NSUInteger chapterIndex;
@property (strong, nonatomic) UITapGestureRecognizer *singleTap;
@property (strong, nonatomic) UITapGestureRecognizer *buttonTap;

@property (strong, nonatomic) UIImageView *starsImageView;
@property (strong, nonatomic) UIImageView *starsBackView;
@property (strong, nonatomic) UIButton *learnBtn;
@property (strong, nonatomic) UIButton *practiceBtn;
@property (strong, nonatomic) UIButton *testBtn;
@property (strong, nonatomic) UILabel *descriptionLabel;

- (id)initWithChapterTitle:(NSString *)chapterTitle atIndex:(NSUInteger)index forPage:(NSInteger)pageIndex;

@end
