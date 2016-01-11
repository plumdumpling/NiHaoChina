//
//  ChapterContentViewController.m
//  NiHaoChina
//
//  Created by Leslie on 02.06.14.
//  Copyright (c) 2014 Leslie Zimmermann. All rights reserved.
//

#import "ChapterContentViewController.h"
#import "ChapterViewController.h"

@interface ChapterContentViewController () {
    NSString *_chapterTitle;
    NSUInteger _chapterIndex;
    NSUInteger _pageIndex;
    NSInteger _rank;
    NSInteger _progress;
    BOOL _showButtons;
    BOOL _locked;
}

@end

@implementation ChapterContentViewController
@synthesize chapterIndex = _chapterIndex;

- (id)initWithChapterTitle:(NSString *)chapterTitle atIndex:(NSUInteger)index forPage:(NSInteger)pageIndex
{
    if (self = [super init]) {
        _chapterTitle = [[NSString alloc] initWithFormat:@"%@", chapterTitle];
        _chapterIndex = index;
        _pageIndex = pageIndex;
        self.view.tag = index;
        
        if (!_locked) {
            self.singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapChange:)];
            self.singleTap.delegate = (id)self;
            [self.view addGestureRecognizer:self.singleTap];
        }
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self checkForStatus];
    
    NSString *key = [[NSString alloc] initWithFormat:@"%lu.%lu",(unsigned long)_pageIndex+1, (unsigned long)_chapterIndex+1];
    _rank = [[self.appDelegate.chapters objectForKey:key] intValue];
    if (!_locked) {
        // gesture recoginzer
        if ([[self.view gestureRecognizers] count]<=0) {
            self.singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapChange:)];
            self.singleTap.delegate = (id)self;
            [self.view addGestureRecognizer:self.singleTap];
        }
        
        // update stars
        [self.starsImageView setImage:[UIImage imageNamed:[[NSString alloc] initWithFormat:@"stars%ld.png", (long)_rank]]];
        
        // update buttons
        if (_progress>0) {
            self.learnBtn = [[UIButton alloc] init];
            if (_progress == 3) {
                NSString *key = [[NSString alloc] initWithFormat:@"%lu.%lu",(unsigned long)_pageIndex+1, (unsigned long)_chapterIndex+1];
                if ([key isEqualToString:@"1.6"]) {
                    // no practice available
                    [self.learnBtn setFrame:CGRectMake(235, 360, 270, 100)];
                }
                else {
                    [self.learnBtn setFrame:CGRectMake(120, 360, 270, 100)];
                }
            }
            if (_progress == 2) [self.learnBtn setFrame:CGRectMake(235, 360, 270, 100)];
            if (_progress == 1) [self.learnBtn setFrame:CGRectMake(377, 360, 270, 100)];
            [self.learnBtn setImage:[UIImage imageNamed:@"lernen.png"] forState:UIControlStateNormal];
            [self.learnBtn setImage:[UIImage imageNamed:@"lernen.png"] forState:UIControlStateHighlighted];
            self.learnBtn.tag = 1;
            [self.learnBtn addTarget:self action:@selector(sendChangeToParent:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        if (_progress>1) {
            NSString *key = [[NSString alloc] initWithFormat:@"%lu.%lu",(unsigned long)_pageIndex+1, (unsigned long)_chapterIndex+1];
            if ([key isEqualToString:@"1.6"]) {
                // no practice available
            }
            else {
                self.practiceBtn = [[UIButton alloc] init];
                if (_progress == 3) [self.practiceBtn setFrame:CGRectMake(377, 360, 270, 100)];
                if (_progress == 2) [self.practiceBtn setFrame:CGRectMake(519, 360, 270, 100)];
                [self.practiceBtn setImage:[UIImage imageNamed:@"ueben.png"] forState:UIControlStateNormal];
                [self.practiceBtn setImage:[UIImage imageNamed:@"ueben.png"] forState:UIControlStateHighlighted];
                self.practiceBtn.tag = 2;
                [self.practiceBtn addTarget:self action:@selector(sendChangeToParent:) forControlEvents:UIControlEventTouchUpInside];
            }
        }
        
        if (_progress>2) {
            NSString *key = [[NSString alloc] initWithFormat:@"%lu.%lu",(unsigned long)_pageIndex+1, (unsigned long)_chapterIndex+1];
            if ([key isEqualToString:@"1.6"]) {
                // no practice available
                self.testBtn = [[UIButton alloc] initWithFrame:CGRectMake(519, 360, 270, 100)];
            }
            else {
                self.testBtn = [[UIButton alloc] initWithFrame:CGRectMake(634, 360, 270, 100)];
            }
            [self.testBtn setImage:[UIImage imageNamed:@"testen.png"] forState:UIControlStateNormal];
            [self.testBtn setImage:[UIImage imageNamed:@"testen.png"] forState:UIControlStateHighlighted];
            self.testBtn.tag = 3;
            [self.testBtn addTarget:self action:@selector(sendChangeToParent:) forControlEvents:UIControlEventTouchUpInside];
        }
    }


    if (_locked) {
        self.descriptionLabel.text = @"Kapitel noch nicht freigeschaltet";
    }
    else {
        switch (_rank) {
            case 0:
                self.descriptionLabel.text = @"Kapitel jetzt starten";
                break;
                
            case 1:
                self.descriptionLabel.text = @"Gut";
                break;
                
            case 2:
                self.descriptionLabel.text = @"Sehr gut";
                break;
                
            case 3:
                self.descriptionLabel.text = @"Excellent";
                break;
                
            default:
                break;
        }
    }
}

- (void)loadView
{
    [super loadView];
    
    self.appDelegate = [[UIApplication sharedApplication] delegate];

    [self checkForStatus];
}

- (void)checkForStatus
{
    NSString *key = [[NSString alloc] initWithFormat:@"%lu.%lu",(unsigned long)_pageIndex+1, (unsigned long)_chapterIndex+1];
    if (![self.appDelegate.chapters objectForKey:key]) {
        _rank = 0;
        if (![self.appDelegate.chapters objectForKey:[NSString stringWithFormat:@"%@-progress",key]] ||
            [[self.appDelegate.chapters objectForKey:[NSString stringWithFormat:@"%@-progress",key]] intValue]<1) {
            _progress = 1;
        }
        else if ([[self.appDelegate.chapters objectForKey:[NSString stringWithFormat:@"%@-progress",key]] intValue]==1) {
            _progress = 2;
        }
        else if ([[self.appDelegate.chapters objectForKey:[NSString stringWithFormat:@"%@-progress",key]] intValue]==2) {
            _progress = 3;
        }
    }
    else {
        _rank = [[self.appDelegate.chapters objectForKey:key] intValue];
        _progress = 3;
    }
    
    NSString *keyBefore = [[NSString alloc] initWithFormat:@"%lu.%lu",(unsigned long)_pageIndex+1, (unsigned long)_chapterIndex];
    if ((![self.appDelegate.chapters objectForKey:[NSString stringWithFormat:@"%@-progress",keyBefore]] ||
         [[self.appDelegate.chapters objectForKey:[NSString stringWithFormat:@"%@-progress",keyBefore]] integerValue]<3) && _chapterIndex>0) {
        _locked = YES;
        _progress = 0;
    }
    else _locked = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // stars
    UIImage *starsBack = [UIImage imageNamed:@"starsBackground.png"];
    self.starsBackView = [[UIImageView alloc] initWithImage:starsBack];
    [self.starsBackView setFrame:CGRectMake(251.5, 460, 521, 109)];
    [self.view addSubview:self.starsBackView];
    
    NSString *starsImageName;
    if (_locked) starsImageName = [[NSString alloc] initWithFormat:@"chapterLocked.png"];
    else starsImageName = [[NSString alloc] initWithFormat:@"stars%ld.png", (long)_rank];
    UIImage *starsImage = [UIImage imageNamed:starsImageName];
    self.starsImageView = [[UIImageView alloc] initWithImage:starsImage];
    [self.starsImageView setFrame:CGRectMake(317.5, 360, 389, 176)];
    [self.view addSubview:self.starsImageView];
    
    
    // text
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(149, 180, 726, 90)];
    [titleLabel setFont:[UIFont fontWithName:@"Shojumaru-Regular" size:33]];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = _chapterTitle;
    [self.view addSubview:titleLabel];
    
    
    self.descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(149, 230, 726, 90)];
    [self.descriptionLabel setFont:[UIFont systemFontOfSize:20]];
    self.descriptionLabel.textColor = [UIColor whiteColor];
    self.descriptionLabel.textAlignment = NSTextAlignmentCenter;
    
    [self.view addSubview:self.descriptionLabel];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tapChange:(id)sender
{
    if (!_showButtons) {
        [self.starsBackView removeFromSuperview];
        [self.starsImageView removeFromSuperview];
        
        switch (_progress) {
            case 1:
                [self.view addSubview:self.learnBtn];
                break;

            case 2:
                [self.view addSubview:self.learnBtn];
                [self.view addSubview:self.practiceBtn];
                break;

            case 3:
                [self.view addSubview:self.learnBtn];
                [self.view addSubview:self.practiceBtn];
                [self.view addSubview:self.testBtn];
                break;

            default:
                break;
        }

        _showButtons = YES;
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    if (_showButtons) {
        [self.view addSubview:self.starsBackView];
        [self.view addSubview:self.starsImageView];
        
        [self.learnBtn removeFromSuperview];
        [self.practiceBtn removeFromSuperview];
        [self.testBtn removeFromSuperview];
        _showButtons = NO;
    }
}

- (void)sendChangeToParent:(UIButton *)sender
{
    ChapterViewController *parent = (ChapterViewController *)self.parentViewController;
    [parent changeVC:self toPart:sender.tag];
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
