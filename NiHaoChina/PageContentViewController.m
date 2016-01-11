//
//  PageContentViewController.m
//  NiHaoChina
//
//  Created by Leslie on 01.06.14.
//  Copyright (c) 2014 Leslie Zimmermann. All rights reserved.
//

#import "PageContentViewController.h"
#import "ChapterViewController.h"
#import "ViewController.h"

@interface PageContentViewController () {
    NSString *_pageTitle;
    NSString *_pageDescription;
    UIImage *_imageName;
    NSUInteger _pageIndex;
    BOOL _locked;
}

@end

@implementation PageContentViewController
@synthesize pageIndex = _pageIndex;

- (id)initWithPageTitle:(NSString *)pageTitle andDescription:(NSString *)pageDescription andImage:(NSString *)imageName atIndex:(NSUInteger)index
{
    if (self = [super init]) {
        _pageTitle = [[NSString alloc] initWithFormat:@"%@", pageTitle];
        _pageDescription = [[NSString alloc] initWithFormat:@"%@", pageDescription];
        _imageName = [UIImage imageNamed:imageName];
        _pageIndex = index;
        self.view.tag = index;

        self.singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sendChangeToParent:)];
        self.singleTap.delegate = (id)self;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:NO];
    
    if (![self.appDelegate.chapters objectForKey:[NSString stringWithFormat:@"%lu.1-progress",(unsigned long)_pageIndex+1]] && _pageIndex>0) {
        _locked = YES;
        
        self.startLabel.text = @"Lektion noch nicht freigeschaltet";
        
        if ([[self.view gestureRecognizers] count]>0) {
            [self.view removeGestureRecognizer:self.singleTap];
        }
    }
    else {
        _locked = NO;
        
        self.startLabel.text = @"> Lektion starten";

        if ([[self.view gestureRecognizers] count]<=0) {
            [self.view addGestureRecognizer:self.singleTap];
        }
    }
}

- (void)loadView
{
    [super loadView];

    self.appDelegate = [[UIApplication sharedApplication] delegate];
    
    if (![self.appDelegate.chapters objectForKey:[NSString stringWithFormat:@"%lu.1-progress",(unsigned long)_pageIndex+1]] && _pageIndex>0) {
        _locked = YES;
    }
    else _locked = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:_imageName];
    [imageView setFrame:CGRectMake(96, 230, 832, 365)];
    [self.view addSubview:imageView];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(149, 240, 726, 90)];
    [titleLabel setFont:[UIFont fontWithName:@"Shojumaru-Regular" size:75]];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.text = _pageTitle;
    [self.view addSubview:titleLabel];
    
    NSInteger descriptionX;
    NSInteger descriptionWidth;
    NSInteger startY;
    switch (_pageIndex) {
        case 0:
            descriptionX = 457;
            descriptionWidth = 430;
            startY = 402;
            break;
            
        case 1:
            descriptionX = 149;
            descriptionWidth = 480;
            startY = 402;
            break;
            
        case 2:
            descriptionX = 420;
            descriptionWidth = 440;
            startY = 425;
            break;
            
        default:
            break;
    }
    UITextView *descriptionText = [[UITextView alloc] initWithFrame:CGRectMake(descriptionX, 335, descriptionWidth, 200)];
    descriptionText.userInteractionEnabled = NO;
    descriptionText.scrollEnabled = NO;
    descriptionText.editable = NO;
    descriptionText.backgroundColor = [UIColor clearColor];
    descriptionText.textColor = [UIColor whiteColor];
    descriptionText.font = [UIFont systemFontOfSize:20];
    descriptionText.text = _pageDescription;
    [self.view addSubview:descriptionText];
    
    self.startLabel = [[UILabel alloc] initWithFrame:CGRectMake(descriptionX, startY, descriptionWidth, 90)];
    [self.startLabel setFont:[UIFont fontWithName:@"Shojumaru-Regular" size:30]];
    self.startLabel.textColor = [UIColor whiteColor];
    self.startLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.startLabel.numberOfLines = 0;
    
    if (_locked) self.startLabel.text = @"Lektion noch nicht freigeschalten.";
    else self.startLabel.text = @"> Lektion starten";
    
    [self.view addSubview:self.startLabel];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)sendChangeToParent:(id)sender
{
    ViewController *parent = (ViewController *)self.parentViewController;
    if (parent.nameSaved) [parent changeVC:sender];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
