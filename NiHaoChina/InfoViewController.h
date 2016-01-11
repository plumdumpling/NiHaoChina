//
//  InfoViewController.h
//  NiHaoChina
//
//  Created by Leslie on 03.06.14.
//  Copyright (c) 2014 Leslie Zimmermann. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface InfoViewController : UIViewController

@property (strong, nonatomic) AppDelegate *appDelegate;

// glossar
@property (strong, nonatomic) NSArray *glossarTopics;
@property (strong, nonatomic) NSArray *glossarChapters;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIView *leftGlossarView;
@property (strong, nonatomic) UILabel *topicLabel;
@property (strong, nonatomic) UITextView *wordsDE;
@property (strong, nonatomic) UITextView *wordsCN;

// settings
@property (strong, nonatomic) UITextField *nameField;

// help
@property (strong, nonatomic) UIImageView *helpView;

- (id)initWithIndex:(NSInteger)index;

@end
