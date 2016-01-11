//
//  ChapterViewController.m
//  NiHaoChina
//
//  Created by Leslie on 02.06.14.
//  Copyright (c) 2014 Leslie Zimmermann. All rights reserved.
//

#import "ChapterViewController.h"
#import "ChapterContentViewController.h"
#import "InfoViewController.h"
#import "CustomButton.h"

#import "Dialogue.h"

#import "Memory.h"
#import "MurmelGame.h"
#import "Textadventure.h"
#import "InteractiveGraphics.h"

#import "MultipleChoice.h"
#import "FillInText.h"
#import "TrueOrFalse.h"

@interface ChapterViewController () {
    NSInteger _pageIndex;
    NSArray *_chapterTitles;
    NSArray *_imageNames;
}

@end

@implementation ChapterViewController

- (id)initWithChaptersForPageNumber:(NSInteger)page
{
    self = [super initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    if (self) {
        _pageIndex = page;
        switch (page) {
            case 0:
                _chapterTitles = @[@"Begrüßung und Verabschiedung",@"Pinyin",@"Personalpronomen",@"Smalltalk",@"Zahlen",@"Frage und Verneinung",@"Farben"];
                break;

            case 1:
                _chapterTitles = @[@"Im Hotel",@"Am Flughafen"];
                break;

            case 2:
                _chapterTitles = @[@"Essen und Getränke bestellen",@"Im Restaurant bezahlen"];
                break;

            default:
                break;
        }
        
        self.dataSource = self;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.appDelegate = [[UIApplication sharedApplication] delegate];

    UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background.png"]];
    [self.view addSubview:backgroundImage];
    [self.view sendSubviewToBack:backgroundImage];
    
    ChapterContentViewController *startVC = [[ChapterContentViewController alloc] initWithChapterTitle:_chapterTitles[0] atIndex:0 forPage:_pageIndex];

    [self setViewControllers:@[startVC]
                   direction:UIPageViewControllerNavigationDirectionForward
                    animated:NO
                  completion:nil];
    
    self.chaptersControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, 600, self.view.frame.size.width, 30)];
    [self.view addSubview:self.chaptersControl];
    [self.view bringSubviewToFront:self.chaptersControl];

    [self initNavigationBarItemsWithHome:YES andBack:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    UIBarButtonItem *senderItem = (UIBarButtonItem*)sender;
    NSInteger navigationIndex = senderItem.tag;
    InfoViewController *newVC = [[InfoViewController alloc] initWithIndex:navigationIndex];
    
    [self.navigationController pushViewController:newVC animated:NO];
}

#pragma mark Page View Controller Methods

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(ChapterContentViewController *)viewController
{
    [self.chaptersControl setCurrentPage:viewController.chapterIndex];
    
    if (viewController.chapterIndex==[_chapterTitles count]-1) {
        return nil;
    }
    else {
        return [[ChapterContentViewController alloc] initWithChapterTitle:_chapterTitles[viewController.chapterIndex+1] atIndex:viewController.chapterIndex+1 forPage:_pageIndex];
    }
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(ChapterContentViewController *)viewController
{
    [self.chaptersControl setCurrentPage:viewController.chapterIndex];
    
    if (viewController.chapterIndex==0) {
        return nil;
    }
    else {
        return [[ChapterContentViewController alloc] initWithChapterTitle:_chapterTitles[viewController.chapterIndex-1] atIndex:viewController.chapterIndex-1 forPage:_pageIndex];
    }
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    [self.chaptersControl setNumberOfPages:[_chapterTitles count]];
    return 0;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    ChapterContentViewController *controller = (ChapterContentViewController *)pageViewController.viewControllers[0];
    return controller.chapterIndex;
}

#pragma mark Single Tap Action

- (void)changeVC:(id)sender toPart:(NSInteger)part
{
    ChapterContentViewController *senderVC = (ChapterContentViewController *)sender;
    NSInteger chapter = senderVC.view.tag;
    
    NSString *key = [NSString stringWithFormat:@"%d.%d",_pageIndex+1,chapter+1];
    
    if (part==1) {
        Dialogue *dialogueViewController = [[Dialogue alloc] initWithKey:key];
        [self.navigationController pushViewController:dialogueViewController animated:NO];
    }
    else if (part==2) {
        if ([key isEqualToString:@"1.1"] || [key isEqualToString:@"1.5"] || [key isEqualToString:@"2.1"] || [key isEqualToString:@"3.1"] || [key isEqualToString:@"3.2"]) {
            Textadventure *practiceViewController = [[Textadventure alloc] initWithKey:key];
            [self.navigationController pushViewController:practiceViewController animated:NO];
        }
        else if ([key isEqualToString:@"1.7"]) {
            InteractiveGraphics *practiceViewController = [[InteractiveGraphics alloc] initWithKey:key];
            [self.navigationController pushViewController:practiceViewController animated:NO];
        }
        else if ([key isEqualToString:@"1.3"] || [key isEqualToString:@"2.2"]) {
            Memory *practiceViewController = [[Memory alloc] initWithKey:key];
            [self.navigationController pushViewController:practiceViewController animated:NO];
        }
        else if ([key isEqualToString:@"1.2"] || [key isEqualToString:@"1.4"]) {
            MurmelGame *practiceViewController = [[MurmelGame alloc] initWithKey:key];
            [self.navigationController pushViewController:practiceViewController animated:NO];
        }
    }
    else if (part==3) {
        if ([key isEqualToString:@"1.1"] || [key isEqualToString:@"1.4"] || [key isEqualToString:@"1.7"] || [key isEqualToString:@"2.1"] || [key isEqualToString:@"3.1"]) {
            FillInText *testsViewController = [[FillInText alloc] initWithKey:key];
            [self.navigationController pushViewController:testsViewController animated:NO];
        }
        else if ([key isEqualToString:@"1.2"] || [key isEqualToString:@"1.3"] || [key isEqualToString:@"1.5"] || [key isEqualToString:@"2.2"] || [key isEqualToString:@"3.2"]) {
            MultipleChoice *mcViewController = [[MultipleChoice alloc] initWithKey:key];
            [self.navigationController pushViewController:mcViewController animated:NO];
        }
        else if ([key isEqualToString:@"1.6"]) {
            TrueOrFalse *practiceViewController = [[TrueOrFalse alloc] initWithKey:key];
            [self.navigationController pushViewController:practiceViewController animated:NO];
        }
    }
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
