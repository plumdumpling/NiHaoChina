//
//  ChapterViewController.h
//  NiHaoChina
//
//  Created by Leslie on 02.06.14.
//  Copyright (c) 2014 Leslie Zimmermann. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface ChapterViewController : UIPageViewController <UIPageViewControllerDataSource>

@property (strong, nonatomic) AppDelegate *appDelegate;
@property (strong, nonatomic) UIPageControl *chaptersControl;
@property (strong, nonatomic) NSArray *rightItems;

- (id)initWithChaptersForPageNumber:(NSInteger)page;
- (void)changeVC:(id)sender toPart:(NSInteger)part;

@end
