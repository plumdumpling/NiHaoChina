//
//  ViewController.m
//  NiHaoChina
//
//  Created by Leslie on 01.06.14.
//  Copyright (c) 2014 Leslie Zimmermann. All rights reserved.
//

#import "ViewController.h"
#import "PageContentViewController.h"
#import "ChapterViewController.h"
#import "InfoViewController.h"
#import "CustomButton.h"

@interface ViewController () {
    NSArray *_pageTitles;
    NSArray *_pageDescriptions;
    NSArray *_imageNames;
}

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.appDelegate = [[UIApplication sharedApplication] delegate];

    
    // intro video
    NSString *path = [[NSBundle mainBundle] pathForResource:@"introvideo" ofType:@"mp4"];
    NSURL * movieUrl = [[NSURL alloc] initFileURLWithPath:path];
    self.playerController = [[MPMoviePlayerViewController alloc]initWithContentURL:movieUrl];
    self.playerController.view.frame = CGRectMake(0, 0, 1024, 768);
    self.playerController.moviePlayer.controlStyle = MPMovieControlStyleNone;
    self.playerController.moviePlayer.shouldAutoplay = YES;
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(movieFinishedCallback:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:self.playerController.moviePlayer];
    [self.appDelegate.window.rootViewController presentViewController:self.playerController animated:NO completion:nil];

    self.skipBtn = [[UIButton alloc] initWithFrame:CGRectMake(924, 30, 60, 60)];
    [self.skipBtn setBackgroundImage:[UIImage imageNamed:@"skipIntro.png"] forState:UIControlStateNormal];
    [self.skipBtn addTarget:self action:@selector(skipVideo:) forControlEvents:UIControlEventTouchUpInside];
    [self.playerController.view addSubview:self.skipBtn];
    
    // pages
    UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background.png"]];
    [self.view addSubview:backgroundImage];
    [self.view sendSubviewToBack:backgroundImage];

    _pageTitles = @[@"Erste Schritte",@"Auf Reisen",@"Im Restaurant"];
    _pageDescriptions = @[
                          @"Gewinne einen Überblick über die Grundlagen der chinesischen Sprache.",
                          @"Stelle dich ersten Dialogen im Hotel und am Flughafen.",
                          @"Essen ist ein sehr zentraler Aspekt der chinesischen Kultur, den du nicht verpassen solltest."];
    _imageNames = @[@"page1.png",@"page2.png",@"page3.png"];
    self.dataSource = self;
    
    PageContentViewController *startVC = [[PageContentViewController alloc] initWithPageTitle:_pageTitles[0] andDescription:_pageDescriptions[0] andImage:_imageNames[0] atIndex:0];
    [self setViewControllers:@[startVC]
                   direction:UIPageViewControllerNavigationDirectionForward
                    animated:NO
                  completion:nil];
    
    self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, 600, self.view.frame.size.width, 30)];
    [self.view addSubview:self.pageControl];
    [self.view bringSubviewToFront:self.pageControl];
    
    [self initNavigationBarItemsWithHome:NO andBack:NO];
}

#pragma mark Intro Video

- (void)movieFinishedCallback:(NSNotification*)aNotification
{
    NSNumber *finishReason = [[aNotification userInfo] objectForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey];
    
    if ([finishReason intValue] != MPMovieFinishReasonPlaybackEnded) {
        MPMoviePlayerController *moviePlayer = [aNotification object];
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:MPMoviePlayerPlaybackDidFinishNotification
                                                      object:moviePlayer];
        [self dismissMoviePlayerViewControllerAnimated];
    }

    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"]) {
        [self performSelector:@selector(openInfokomponente) withObject:self afterDelay:0.5];
    }
}

- (void)skipVideo:(UIButton *)sender
{
    [self.playerController.moviePlayer stop];
    self.playerController = nil;
}

#pragma mark Appear Methods

- (void)viewWillAppear:(BOOL)animated
{
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"]) {
        self.nameSaved = NO;
        self.launchPopup = [[Popup alloc] initFor:@"AppLaunch" withDescription:@"Willkommen!\nBitte gib einen Namen für dein Benutzerprofil ein." returnBtn:NO menuBtn:NO nextBtn:NO yesBtn:YES noBtn:NO];
        [self.launchPopup.yesBtn addTarget:self action:@selector(closePopupAndSetUserDefaults:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.launchPopup];
    }
    else {
        self.nameSaved = YES;
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self.infokomp removeFromSuperview];
    self.infokomp = nil;
}

- (void)openInfokomponente
{
    self.infokomp = [[Infokomponente alloc] init];
    [self.infokomp.closeBtn addTarget:self action:@selector(closePopup:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.infokomp];
    
    [self.infokomp setFrame:CGRectMake(0, 768, 1024, 250)];
    [UIView beginAnimations:@"animateTableView" context:nil];
    [UIView setAnimationDuration:0.2];
    [self.infokomp setFrame:CGRectMake(0, 518, 1024, 250)];
    [UIView commitAnimations];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Popups

- (void)closePopup:(id)sender
{
    UIButton *button = (UIButton *)sender;
    [button.superview removeFromSuperview];
}

- (void)closePopupAndSetUserDefaults:(id)sender
{
    UIButton *button = (UIButton *)sender;
    if (![self.launchPopup.nameField.text isEqualToString:@""] && ![self.launchPopup.nameField.text isEqualToString:@" "]) {
        [self openInfokomponente];

        [button.superview removeFromSuperview];
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HasLaunchedOnce"];
        [[NSUserDefaults standardUserDefaults] synchronize];

        self.appDelegate.userName = self.launchPopup.nameField.text;
        [self.appDelegate saveData];
        
        self.nameSaved = YES;
    }
}

#pragma mark Initialize Navigation Bar

- (void)initNavigationBarItemsWithHome:(BOOL)home andBack:(BOOL)back
{
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    
    CGSize buttonSize = CGSizeMake(85, 85);
    
    // left items
    
    CustomButton *homeBtn = [[CustomButton alloc] initWithFrame:CGRectMake(10, 0, buttonSize.width, buttonSize.height) andImage:@"home.png"];
    UIBarButtonItem *homeItem = [[UIBarButtonItem alloc] initWithCustomView:homeBtn];
    [homeBtn addTarget:self action:@selector(performHomeNavigation:) forControlEvents:UIControlEventTouchUpInside];
    
    CustomButton *backBtn = [[CustomButton alloc] initWithFrame:CGRectMake(100, 0, buttonSize.width, buttonSize.height) andImage:@"back.png"];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    [backBtn addTarget:self action:@selector(performBackNavigation:) forControlEvents:UIControlEventTouchUpInside];

    NSArray *leftItems;
    if (home && !back) {
        leftItems = [[NSArray alloc] initWithObjects:homeItem, nil];
    }
    if (!home && back) {
        leftItems = [[NSArray alloc] initWithObjects:backItem, nil];
    }
    if (home && back) {
        leftItems = [[NSArray alloc] initWithObjects:homeItem, backItem, nil];
    }

    self.navigationItem.leftBarButtonItems = leftItems;

    // right items
    
    if ([self.rightItems count] <= 0) {
        CustomButton *glossarBtn = [[CustomButton alloc] initWithFrame:CGRectMake(10, 0, buttonSize.width, buttonSize.height) andImage:@"glossar.png"];
        UIBarButtonItem *glossarItem = [[UIBarButtonItem alloc] initWithCustomView:glossarBtn];
        [glossarBtn addTarget:self action:@selector(performRightNavigation:) forControlEvents:UIControlEventTouchUpInside];
        [glossarBtn setTag:0];
        
        CustomButton *settingsBtn = [[CustomButton alloc] initWithFrame:CGRectMake(100, 0, buttonSize.width, buttonSize.height) andImage:@"settings.png"];
        UIBarButtonItem *settingsItem = [[UIBarButtonItem alloc] initWithCustomView:settingsBtn];
        [settingsBtn addTarget:self action:@selector(performRightNavigation:) forControlEvents:UIControlEventTouchUpInside];
        [settingsBtn setTag:1];
        
        CustomButton *helpBtn = [[CustomButton alloc] initWithFrame:CGRectMake(10, 0, buttonSize.width, buttonSize.height) andImage:@"help.png"];
        UIBarButtonItem *helpItem = [[UIBarButtonItem alloc] initWithCustomView:helpBtn];
        [helpBtn addTarget:self action:@selector(performRightNavigation:) forControlEvents:UIControlEventTouchUpInside];
        [helpBtn setTag:2];
        
        CustomButton *infoBtn = [[CustomButton alloc] initWithFrame:CGRectMake(100, 0, buttonSize.width, buttonSize.height) andImage:@"info.png"];
        UIBarButtonItem *infoItem = [[UIBarButtonItem alloc] initWithCustomView:infoBtn];
        [infoBtn addTarget:self action:@selector(performRightNavigation:) forControlEvents:UIControlEventTouchUpInside];
        [infoBtn setTag:3];
        
        self.rightItems = [[NSArray alloc] initWithObjects:infoItem, helpItem, settingsItem, glossarItem, nil];
    }
    
    self.navigationItem.rightBarButtonItems = self.rightItems;
}

#pragma mark Navigation Bar Actions

- (void)performHomeNavigation:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:NO];
}

- (void)performBackNavigation:(id)sender
{
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)performRightNavigation:(id)sender
{
    if (self.nameSaved) {
        [self.infokomp removeFromSuperview];
        
        UIBarButtonItem *senderItem = (UIBarButtonItem*)sender;
        NSInteger navigationIndex = senderItem.tag;
        InfoViewController *newVC = [[InfoViewController alloc] initWithIndex:navigationIndex];
        
        [self.navigationController pushViewController:newVC animated:NO];
    }
}

#pragma mark Page View Controller Methods

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(PageContentViewController *)viewController
{
    [self.pageControl setCurrentPage:viewController.pageIndex];

    if (viewController.pageIndex==[_pageTitles count]-1) {
        return nil;
    }
    else {
        PageContentViewController *afterVC = [[PageContentViewController alloc] initWithPageTitle:_pageTitles[viewController.pageIndex+1] andDescription:_pageDescriptions[viewController.pageIndex+1] andImage:_imageNames[viewController.pageIndex+1] atIndex:viewController.pageIndex+1];
        return afterVC;
    }
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(PageContentViewController *)viewController
{
    [self.pageControl setCurrentPage:viewController.pageIndex];
    
    if (viewController.pageIndex==0) {
        return nil;
    }
    else {
        PageContentViewController *beforeVC = [[PageContentViewController alloc] initWithPageTitle:_pageTitles[viewController.pageIndex-1] andDescription:_pageDescriptions[viewController.pageIndex-1] andImage:_imageNames[viewController.pageIndex-1] atIndex:viewController.pageIndex-1];
        return beforeVC;
    }
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    [self.pageControl setNumberOfPages:[_pageTitles count]];
    return 0;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    PageContentViewController *controller = (PageContentViewController *)pageViewController.viewControllers[0];
    return controller.pageIndex;
}

#pragma mark Single Tap Action

- (void)changeVC:(id)sender
{
    if (self.nameSaved) {
        PageContentViewController *senderVC = (PageContentViewController *)sender;
        NSInteger page = senderVC.view.tag;
        ChapterViewController *chapterViewController = [[ChapterViewController alloc] initWithChaptersForPageNumber:page];
        [self.navigationController pushViewController:chapterViewController animated:NO];
    }
}

@end
