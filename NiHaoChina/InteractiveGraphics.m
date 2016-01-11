//
//  InteractiveGraphics.m
//  NiHaoChina
//
//  Created by Leslie on 28.06.14.
//  Copyright (c) 2014 Leslie Zimmermann. All rights reserved.
//

#import "InteractiveGraphics.h"
#import "ChapterViewController.h"
#import "CustomButton.h"
#import "Popup.h"

#import "FillInText.h"
#import "MultipleChoice.h"
#import "TrueOrFalse.h"

@interface InteractiveGraphics () {
    NSString *_key;
    NSInteger _part;
    BOOL _end;
    NSMutableArray *_images;
    NSMutableArray *_colors;
    NSMutableArray *_shuffledNums;
}

@end

@implementation InteractiveGraphics

- (id)initWithKey:(NSString *)key
{
    self = [super init];
    if (self) {
        _key = key;
        
        if ([_key isEqualToString:@"1.7"]) {
            _images = [[NSMutableArray alloc] initWithArray:@[@"coconut", @"banana", @"apple", @"blackberry",  @"orange", @"strawberry", @"blueberry"]];
            _colors = [[NSMutableArray alloc] initWithArray:@[@"bái", @"huáng", @"lǜ", @"hēi", @"chéng", @"hóng", @"lán"]];
            
            _shuffledNums = [[NSMutableArray alloc] init];
            for (int i=0; i<[_images count]; i++) {
                [_shuffledNums addObject:[NSNumber numberWithInt:i]];
            }
            
            _part = 0;

            self.appDelegate = [[UIApplication sharedApplication] delegate];
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *fileName = @"ding";
    NSString *soundFilePath = [NSString stringWithFormat:@"%@/%@.mp3", [[NSBundle mainBundle] resourcePath], fileName];
    NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
    
    self.audioPlayerCorrect = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:nil];
    self.audioPlayerCorrect.numberOfLoops = 0;
    
    NSString *fileNameWrong = @"wrong";
    NSString *soundFilePathWrong = [NSString stringWithFormat:@"%@/%@.mp3", [[NSBundle mainBundle] resourcePath], fileNameWrong];
    NSURL *soundFileURLWrong = [NSURL fileURLWithPath:soundFilePathWrong];
    
    self.audioPlayerWrong = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURLWrong error:nil];
    self.audioPlayerWrong.numberOfLoops = 0;

    UIImageView *backgroundImage2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"farben_background.png"]];
    [self.view addSubview:backgroundImage2];
    [self.view sendSubviewToBack:backgroundImage2];

    UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background.png"]];
    [self.view addSubview:backgroundImage];
    [self.view sendSubviewToBack:backgroundImage];


    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(100, 130, 824, 50)];
    label.text = @"Welche Farbe hat diese Frucht?";
    label.font = [UIFont fontWithName:@"Shojumaru-Regular" size:34];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label];
    
    UIImageView *tellerView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"farben_teller.png"]];
    [tellerView setFrame:CGRectMake(50, 350, 640, 384)];
    [self.view addSubview:tellerView];

    [self customInit];

    [self initNavigationBarItemsWithBack:YES];
}

- (void)customInit
{
    [self shuffle:_shuffledNums];

    self.imagesView = [[UIView alloc] initWithFrame:CGRectMake(50, 350, 640, 384)];
    [self.view addSubview:self.imagesView];

    self.buttonsView = [[UIView alloc] initWithFrame:CGRectMake(680, 180, 260, 600)];
    [self.view addSubview:self.buttonsView];

    UIImageView *fruitImage;
    UIButton *colorBtn;
    
    for (int i=0; i<[_images count]; i++) {
        if (i==[_shuffledNums[0] integerValue]) fruitImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_bw.png",_images[i]]]];
        else fruitImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_sil.png",_images[i]]]];
        fruitImage.tag = i;
        [self.imagesView addSubview:fruitImage];

        colorBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, (i*75), 270, 90)];
        [colorBtn setBackgroundImage:[UIImage imageNamed:@"btnNormal.png"] forState:UIControlStateNormal];
        [colorBtn setBackgroundImage:[UIImage imageNamed:@"btnHighlighted.png"] forState:UIControlStateHighlighted];
        [colorBtn setTitle:_colors[i] forState:UIControlStateNormal];
        [colorBtn setTitleColor:[UIColor colorWithRed:0.83 green:0.55 blue:0.27 alpha:1.0] forState:UIControlStateNormal];
        colorBtn.tag = i;
        [colorBtn addTarget:self action:@selector(tapColor:) forControlEvents:UIControlEventTouchUpInside];
        [self.buttonsView addSubview:colorBtn];
    }
}

- (void)tapColor:(UIButton *)sender
{
    if (!_end) {
        if (sender.tag == [_shuffledNums[_part] integerValue]) {
            [sender setBackgroundImage:[UIImage imageNamed:@"btnHighlighted_correct.png"] forState:UIControlStateNormal];
            [sender setBackgroundImage:[UIImage imageNamed:@"btnHighlighted_correct.png"] forState:UIControlStateHighlighted];
            [sender removeTarget:self action:@selector(tapColor:) forControlEvents:UIControlEventTouchUpInside];
            [self.audioPlayerCorrect play];
        }
        else {
            [sender setBackgroundImage:[UIImage imageNamed:@"btnHighlighted_wrong.png"] forState:UIControlStateNormal];
            [sender setBackgroundImage:[UIImage imageNamed:@"btnHighlighted_wrong.png"] forState:UIControlStateHighlighted];
            [self performSelector:@selector(deselectButton) withObject:nil afterDelay:1];
            [self.audioPlayerWrong play];
        }
        
        NSArray *subviews = [self.imagesView subviews];
        for (int i=0; i<[subviews count]; i++) {
            if ([subviews[i] isKindOfClass:[UIImageView class]]) {
                UIImageView *imageView = (UIImageView *)subviews[i];
                if (imageView.tag == [_shuffledNums[_part] integerValue]) {
                    [imageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_color.png", _images[[_shuffledNums[_part] integerValue]]]]];
                }
                
                if (_part<[_images count]-1) {
                    if (imageView.tag == [_shuffledNums[_part+1] integerValue]) {
                        [imageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_bw.png", _images[[_shuffledNums[_part+1] integerValue]]]]];
                    }
                }
            }
        }
        
        if (_part<[_images count]-1) _part++;
        else {
            [self endOfGraphics];
        }
    }
}

- (void)deselectButton
{
    NSArray *subviews = [self.buttonsView subviews];
    for (UIButton *button in subviews) {
        if ([[button allTargets] count]>0) {
            [button setBackgroundImage:[UIImage imageNamed:@"btnNormal.png"] forState:UIControlStateNormal];
            [button setBackgroundImage:[UIImage imageNamed:@"btnNormal.png"] forState:UIControlStateHighlighted];
        }
    }
}

#pragma mark Popup

- (void)endOfGraphics
{
    _end = YES;
    
    Popup *popup = [[Popup alloc] initFor:@"Game" withDescription:@"Sehr gut! Du hast die Übung abgeschlossen. Wenn du dich noch nicht sicher genug fühlst, um mit dem Test fortzufahren, kannst du diese Übung jederzeit wiederholen, oder dir den ersten Lernabschnitt nochmal anschauen." returnBtn:YES menuBtn:YES nextBtn:YES yesBtn:NO noBtn:NO];
    [popup.returnBtn addTarget:self action:@selector(startExerciseAgain:) forControlEvents:UIControlEventTouchUpInside];
    [popup.menuBtn addTarget:self action:@selector(returnToMenu:) forControlEvents:UIControlEventTouchUpInside];
    [popup.nextBtn addTarget:self action:@selector(loadTest:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:popup];
    
    [self saveData];
}

- (void)startExerciseAgain:(UIGestureRecognizer *)sender
{
    _end = NO;
    _part = 0;

    for (UIImageView *view in [self.imagesView subviews]) {
        [view removeFromSuperview];
    }
    for (UIButton *button in [self.buttonsView subviews]) {
        [button removeFromSuperview];
    }

    [self closePopup:sender];
    [self customInit];
}


- (void)returnToMenu:(UIGestureRecognizer *)sender
{
    _end = NO;
    
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
    _end = NO;
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


#pragma mark Shuffle

- (void)shuffle:(NSMutableArray *)array
{
    NSUInteger count = [array count];
    for (NSUInteger i=0; i<count; ++i) {
        NSInteger n = arc4random_uniform(count-i)+i;
        [array exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
