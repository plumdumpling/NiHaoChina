//
//  MurmelGame.m
//  NiHaoChina
//
//  Created by Leslie on 23.06.14.
//  Copyright (c) 2014 Leslie Zimmermann. All rights reserved.
//

#import "MurmelGame.h"
#import "MurmelScene.h"
#import "ChapterViewController.h"
#import "CustomButton.h"
#import "Popup.h"

#import "FillInText.h"
#import "MultipleChoice.h"
#import "TrueOrFalse.h"

@interface MurmelGame () {
    NSString *_key;
}

@end

@implementation MurmelGame

- (id)initWithKey:(NSString *)key
{
    self = [super init];
    if (self) {
        _key = key;
        self.appDelegate = [[UIApplication sharedApplication] delegate];
    }
    return self;
}

- (void)loadView
{
    self.view = [[SKView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initNavigationBarItemsWithBack:YES];
    
    CGSize screenSize = CGSizeMake(1024, 768);
    MurmelScene *scene = [[MurmelScene alloc] initWithSize:screenSize andKey:_key];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    scene.parentViewController = self;
    
    [(SKView *)self.view presentScene:scene];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(100, 110, 824, 100)];
    
    if ([_key isEqualToString:@"1.2"]) label.text = @"Welchen Ton findest du auf dieser Silbe?\nRolle die Murmel zur richtigen Lösung.";
    else if ([_key isEqualToString:@"1.4"]) label.text = @"Rolle die Murmel von dem deutschen Begriff zur chinesischen Übersetzung.";

    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont fontWithName:@"Shojumaru-Regular" size:30];
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.textColor = [UIColor whiteColor];
    [self.view addSubview:label];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Initialize Navigation Bar

- (void)initNavigationBarItemsWithBack:(BOOL)back
{
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    
    CGSize buttonSize = CGSizeMake(85, 85);
    
    // left items
    
    CustomButton *backBtn = [[CustomButton alloc] initWithFrame:CGRectMake(100, 0, buttonSize.width, buttonSize.height) andImage:@"back.png"];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    [backBtn addTarget:self action:@selector(performBackNavigation:) forControlEvents:UIControlEventTouchUpInside];
    
    NSArray *leftItems;
    leftItems = [[NSArray alloc] initWithObjects:backItem, nil];
    
    self.navigationItem.leftBarButtonItems = leftItems;
}

#pragma mark Navigation Bar Actions

- (void)performBackNavigation:(id)sender
{
    Popup *popup = [[Popup alloc] initFor:@"Info" withDescription:@"Bist du sicher, dass du diese Übung abbrechen möchtest?" returnBtn:NO menuBtn:NO nextBtn:NO yesBtn:YES noBtn:YES];
    [popup.yesBtn addTarget:self action:@selector(returnToMenu:) forControlEvents:UIControlEventTouchUpInside];
    [popup.noBtn addTarget:self action:@selector(closePopup:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:popup];
}

#pragma mark Popup

- (void)endOfGame
{
    Popup *popup = [[Popup alloc] initFor:@"Game" withDescription:@"Sehr gut! Du hast die Übung abgeschlossen. Wenn du dich noch nicht sicher genug fühlst, um mit dem Test fortzufahren, kannst du diese Übung jederzeit wiederholen, oder dir den ersten Lernabschnitt nochmal anschauen." returnBtn:YES menuBtn:YES nextBtn:YES yesBtn:NO noBtn:NO];
    [popup.returnBtn addTarget:self action:@selector(startExerciseAgain:) forControlEvents:UIControlEventTouchUpInside];
    [popup.menuBtn addTarget:self action:@selector(returnToMenu:) forControlEvents:UIControlEventTouchUpInside];
    [popup.nextBtn addTarget:self action:@selector(loadTest:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:popup];
    
    [self saveData];
}

- (void)startExerciseAgain:(UIGestureRecognizer *)sender
{
    CGSize screenSize = CGSizeMake(1024, 768);
    MurmelScene *scene = [[MurmelScene alloc] initWithSize:screenSize andKey:_key];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    scene.parentViewController = self;
    
    [(SKView *)self.view presentScene:scene];
    
    [self closePopup:sender];
}


- (void)returnToMenu:(UIGestureRecognizer *)sender
{
    for (UIViewController *controller in self.navigationController.viewControllers) {
        if ([controller isKindOfClass:[ChapterViewController class]]) {
            [self.navigationController popToViewController:controller animated:NO];
            break;
        }
    }
    [self closePopup:sender];
}

- (void)loadTest:(UIGestureRecognizer *)sender
{
    if ([_key isEqualToString:@"1.1"] || [_key isEqualToString:@"1.4"] || [_key isEqualToString:@"1.7"] || [_key isEqualToString:@"2.1"] || [_key isEqualToString:@"3.1"]) {
        FillInText *testsViewController = [[FillInText alloc] initWithKey:_key];
        [self.navigationController pushViewController:testsViewController animated:NO];
    }
    else if ([_key isEqualToString:@"1.2"] || [_key isEqualToString:@"1.3"] || [_key isEqualToString:@"1.5"] || [_key isEqualToString:@"2.2"] || [_key isEqualToString:@"3.2"]) {
        MultipleChoice *mcViewController = [[MultipleChoice alloc] initWithKey:_key];
        [self.navigationController pushViewController:mcViewController animated:NO];
    }
    else if ([_key isEqualToString:@"1.6"]) {
        TrueOrFalse *practiceViewController = [[TrueOrFalse alloc] initWithKey:_key];
        [self.navigationController pushViewController:practiceViewController animated:NO];
    }
    [self closePopup:sender];
}

- (void)closePopup:(id)sender
{
    UIButton *button = (UIButton *)sender;
    [button.superview removeFromSuperview];
}

#pragma mark Save Data

- (void)saveData
{
    NSMutableDictionary *chaptersSavedData = [[NSMutableDictionary alloc] initWithDictionary:self.appDelegate.chapters];
    if ([[self.appDelegate.chapters objectForKey:[NSString stringWithFormat:@"%@-progress",_key]] integerValue]<2) {
        [chaptersSavedData setObject:[NSNumber numberWithInt:2] forKey:[NSString stringWithFormat:@"%@-progress",_key]];
    }
    _appDelegate.chapters = chaptersSavedData;
    [self.appDelegate saveData];
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
