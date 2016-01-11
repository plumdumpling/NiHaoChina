//
//  Textadventure.m
//  NiHaoChina
//
//  Created by Leslie on 28.06.14.
//  Copyright (c) 2014 Leslie Zimmermann. All rights reserved.
//

#import "Textadventure.h"
#import "ChapterViewController.h"
#import "CustomButton.h"
#import "Popup.h"

#import "FillInText.h"
#import "MultipleChoice.h"
#import "TrueOrFalse.h"

@interface Textadventure () {
    NSString *_key;
    NSString *_personA;
    NSString *_personB;
    NSMutableArray *_adventureImages;
    NSMutableArray *_answers;
    NSMutableArray *_clickables;
    NSMutableArray *_correct;
    BOOL _showButtons;
    BOOL _end;
}

@end

@implementation Textadventure

- (id)initWithKey:(NSString *)key
{
    self = [super init];
    if (self) {
        _key = key;
        [self getJsonDataForDialogueKey:_key];
        
        NSMutableArray *shuffledArray;
        for (int i=0; i<[_clickables count]; i++) {
            shuffledArray = [[NSMutableArray alloc] initWithArray:_clickables[i]];
            [self shuffle:shuffledArray];
            _clickables[i] = shuffledArray;
        }

        self.bubbleCN =  [UIImage imageNamed:@"bubbleCN.png"];
        self.part = 0;

        self.appDelegate = [[UIApplication sharedApplication] delegate];
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

    [self customInit];

    [self initNavigationBarItemsWithBack:YES];
}

- (void)customInit
{
    UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background.png"]];
    [self.view addSubview:backgroundImage];
    [self.view sendSubviewToBack:backgroundImage];

    if ([_adventureImages count]>0) {
        self.personDE = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@%@.png",_personA,_adventureImages[0]]]];
        [self.personDE setFrame:CGRectMake(0, 0, 450, 768)];
        [self.view addSubview:self.personDE];
        
        self.personCN = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@%@.png",_personB,_adventureImages[1]]]];
        [self.personCN setFrame:CGRectMake(574, 0, 450, 768)];
        [self.view addSubview:self.personCN];
    }
    
    self.speakBubble = [[UIImageView alloc] initWithImage:self.bubbleCN];
    [self.speakBubble setFrame:CGRectMake(0, 518, 1024, 250)];
    
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.minimumLineHeight = 70.0f;
    
    if ([_answers count]>0) {
        self.textCN = [[UITextView alloc] initWithFrame:CGRectMake(130, 27, 900, 200)];
        self.textCN.allowsEditingTextAttributes = YES;
        self.textCN.userInteractionEnabled = NO;
        self.textCN.scrollEnabled = NO;
        self.textCN.editable = NO;
        self.textCN.text = _answers[self.part];
        self.textCN.attributedText = [[NSAttributedString alloc] initWithString:self.textCN.text
                                                                     attributes:@{NSParagraphStyleAttributeName:paragraphStyle, NSFontAttributeName:[UIFont systemFontOfSize:32.0f]}];
        self.textCN.backgroundColor = [UIColor clearColor];
        self.textCN.textColor = [UIColor colorWithRed:0.25 green:0.10 blue:0.04 alpha:1.0];
        [self.speakBubble addSubview:self.textCN];
    }
    
    self.nextBtn = [[UIButton alloc] initWithFrame:CGRectMake(893, 604, 60, 60)];
    [self.nextBtn setBackgroundImage:[UIImage imageNamed:@"btnNextDialog.png"] forState:UIControlStateNormal];
    [self.nextBtn setBackgroundImage:[UIImage imageNamed:@"btnNextDialog.png"] forState:UIControlStateHighlighted];
    [self.nextBtn addTarget:self action:@selector(nextPart:) forControlEvents:UIControlEventTouchUpInside];
    
    self.buttonsView = [[UIView alloc] initWithFrame:CGRectMake(0, 448, 1024, 250)];
    UIButton *button;
    for (int i=0; i<3; i++) {
        button = [[UIButton alloc] initWithFrame:CGRectMake(100, i*90, 824, 70)];
        [button setBackgroundImage:[UIImage imageNamed:@"adventureBtn.png"] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"adventureBtnHighlighted.png"] forState:UIControlStateHighlighted];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:25];
        [button addTarget:self action:@selector(tapButton:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = i;
        [self.buttonsView addSubview:button];
    }
    [self.view addSubview:self.buttonsView];
    
    
    if ([_clickables[self.part][0] isEqualToString:@""]) {
        _showButtons = YES;
    }
    
    [self nextPart:nil];
}

- (void)nextPart:(UIButton *)sender
{
    if (self.part<[_correct count]) {
        if ([_clickables[self.part] count]>0 && !_showButtons) {
            // show buttons
            _showButtons = YES;
            [self.speakBubble removeFromSuperview];
            [self.nextBtn removeFromSuperview];
            
            int i=0;
            NSArray *subviews = [self.buttonsView subviews];
            for (UIButton *button in subviews) {
                if (i<[_clickables[self.part] count]) {
                    if (![_clickables[self.part][i] isEqualToString:@""] && _clickables[self.part][i]!=nil) {
                        [button setTitle:_clickables[self.part][i] forState:UIControlStateNormal];
                        [button setBackgroundImage:[UIImage imageNamed:@"adventureBtn.png"] forState:UIControlStateNormal];
                        button.alpha = 1;
                    }
                    else button.alpha = 0;
                }
                i++;
            }
            
            [self.view addSubview:self.buttonsView];
        }
        else if (![_answers[self.part] isEqualToString:@""] && _answers[self.part]!=nil) {
            // show chinese
            _showButtons = NO;
            [self.buttonsView removeFromSuperview];
            
            self.textCN.text = _answers[self.part];
            [self.view addSubview:self.speakBubble];
            [self.view addSubview:self.nextBtn];
            
            self.part++;
        }
        else {
            _showButtons = NO;
            self.part++;
            [self nextPart:nil];
        }
    }
    else {
        // end of adventure
        [self saveData];
        [self.speakBubble removeFromSuperview];
        [self.nextBtn removeFromSuperview];
        [self.buttonsView removeFromSuperview];
        [self endOfTextadventure];
    }
}

- (void)tapButton:(UIButton *)sender
{
    UIButton *button = (UIButton *)sender;
    if ([button.titleLabel.text isEqualToString:_correct[self.part]]) {
        // correct selected
        [button setBackgroundImage:[UIImage imageNamed:@"adventureBtnHighlighted.png"] forState:UIControlStateNormal];
        [self performSelector:@selector(nextPart:) withObject:nil afterDelay:1];
        [self.audioPlayerCorrect play];
    }
    else {
        // wrong selected
        [self.personCN setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_question.png",_personB]]];
        [button setBackgroundImage:[UIImage imageNamed:@"adventureBtnHighlighted.png"] forState:UIControlStateNormal];
        [self performSelector:@selector(changeImageBack) withObject:nil afterDelay:1];
        [self.audioPlayerWrong play];
    }
}

- (void)changeImageBack
{
    [self.personCN setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@%@.png",_personB,_adventureImages[1]]]];
    NSArray *subviews = [self.buttonsView subviews];
    for (UIButton *button in subviews) {
        [button setBackgroundImage:[UIImage imageNamed:@"adventureBtn.png"] forState:UIControlStateNormal];
    }
}

#pragma mark Shuffle

- (void)shuffle:(NSMutableArray *)arrayA
{
    NSUInteger count = [arrayA count];
    for (NSUInteger i=0; i<count; ++i) {
        NSInteger n = arc4random_uniform(count-i)+i;
        [arrayA exchangeObjectAtIndex:i withObjectAtIndex:n];
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

#pragma mark Popup

- (void)endOfTextadventure
{
    _end = YES;
    Popup *popup = [[Popup alloc] initFor:@"Game" withDescription:@"Sehr gut! Du hast die Übung abgeschlossen. Wenn du dich noch nicht sicher genug fühlst, um mit dem Test fortzufahren, kannst du diese Übung jederzeit wiederholen, oder dir den ersten Lernabschnitt nochmal anschauen." returnBtn:YES menuBtn:YES nextBtn:YES yesBtn:NO noBtn:NO];
    [popup.returnBtn addTarget:self action:@selector(startExerciseAgain:) forControlEvents:UIControlEventTouchUpInside];
    [popup.menuBtn addTarget:self action:@selector(returnToMenu:) forControlEvents:UIControlEventTouchUpInside];
    [popup.nextBtn addTarget:self action:@selector(loadTest:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:popup];
}

- (void)startExerciseAgain:(UIGestureRecognizer *)sender
{
    _end = NO;
    self.part = 0;
    
    if ([_clickables[self.part][0] isEqualToString:@""]) {
        _showButtons = YES;
    }
    
    for (int i=0; i<[_clickables count]; i++) {
        [self shuffle:_clickables[i]];
    }

    [self closePopup:sender];
    [self nextPart:nil];
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

#pragma mark Json Data

- (void)getJsonDataForDialogueKey:(NSString *)dialogueKey
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"textadventures" ofType:@"json"];
    NSData* data = [NSData dataWithContentsOfFile:filePath];
    NSError* error = nil;
    id json = [NSJSONSerialization JSONObjectWithData:data
                                              options:kNilOptions
                                                error:&error];
    
    if (!json) {
        NSLog(@"no json data received");
    }
    else{
        NSDictionary *characters = [json objectForKey:@"characters"];
        _personA = [characters objectForKey:[NSString stringWithFormat:@"%@A",dialogueKey]];
        _personB = [characters objectForKey:[NSString stringWithFormat:@"%@B",dialogueKey]];
        
        NSArray *array = [json objectForKey:dialogueKey];
        NSDictionary *tempDict = [[NSDictionary alloc] init];
        NSMutableArray *tempArray = [[NSMutableArray alloc] init];
        
        _adventureImages = [[NSMutableArray alloc] init];
        _answers = [[NSMutableArray alloc] init];
        _correct = [[NSMutableArray alloc] init];
        _clickables = [[NSMutableArray alloc] init];
        
        for (int i=0; i<[array count]; i++) {
            tempDict = array[i];
            [tempArray removeAllObjects];

            [tempArray addObjectsFromArray:[tempDict objectForKey:@"false"]];
            [tempArray addObject:[tempDict objectForKey:@"correct"]];
            [_clickables addObject:[NSArray arrayWithArray:tempArray]];
            
            [_correct addObject:[tempDict objectForKey:@"correct"]];
            [_answers addObject:[tempDict objectForKey:@"answer"]];
            [_adventureImages addObject:[tempDict objectForKey:@"image"]];
        }
    }
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
