//
//  MultipleChoice.m
//  NiHaoChina
//
//  Created by Leslie on 27.06.14.
//  Copyright (c) 2014 Leslie Zimmermann. All rights reserved.
//

#import "MultipleChoice.h"
#import "ChapterViewController.h"
#import "CustomButton.h"
#import "Popup.h"

@interface MultipleChoice () {
    NSString *_key;
    NSString *_kapitelFreigeschaltet;
    NSInteger _rank;
    NSInteger _wrongAnswered;
    BOOL _overlay;
    NSMutableArray *_questions;
    NSMutableArray *_answers;
    NSMutableArray *_correct;
    BOOL _end;
}

@end

@implementation MultipleChoice

- (id)initWithKey:(NSString *)key
{
    self = [super init];
    if (self) {
        _key = key;
        [self getJsonDataForChapterKey:_key];
        
        for (int i=0; i<[_answers count]; i++) {
            [self shuffle:_answers[i] and:nil and:nil];
        }
        [self shuffle:_answers and:_questions and:_correct];
        
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

    UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background.png"]];
    [self.view addSubview:backgroundImage];
    [self.view sendSubviewToBack:backgroundImage];

    self.questionLabel = [[UILabel alloc] initWithFrame:CGRectMake(212, 130, 600, 120)];
    self.questionLabel.text = _questions[0];
    self.questionLabel.font = [UIFont fontWithName:@"Shojumaru-Regular" size:30];
    self.questionLabel.textColor = [UIColor whiteColor];
    self.questionLabel.textAlignment = NSTextAlignmentCenter;
    self.questionLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.questionLabel.numberOfLines = 0;
    [self.view addSubview:self.questionLabel];
    
    
    UIGestureRecognizer *tapOnOverlay = [[UIGestureRecognizer alloc] initWithTarget:self action:@selector(nextPart)];
    
    self.correctOverlay = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
    self.correctOverlay.image = [UIImage imageNamed:@"mc_richtig_overlay.png"];
    [self.correctOverlay addGestureRecognizer:tapOnOverlay];

    self.wrongOverlay = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
    self.wrongOverlay.image = [UIImage imageNamed:@"mc_falsch_overlay.png"];
    [self.wrongOverlay addGestureRecognizer:tapOnOverlay];
    
    
    self.answersView = [[UIView alloc] initWithFrame:CGRectMake(101, 280, 822, 400)];
    [self.view addSubview:self.answersView];
    [self initButtonsForPart:0];
    
    [self initNavigationBarItemsWithBack:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark initButtons

- (void)initButtonsForPart:(NSInteger)part
{
    UIButton *button;
    for (int i=0; i<[_answers[part] count]; i++) {
        if (i%2) {
            button = [[UIButton alloc] initWithFrame:CGRectMake(433, (i-1)*60, 389, 130)];
        }
        else {
            button = [[UIButton alloc] initWithFrame:CGRectMake(0, i*60, 389, 130)];
        }
        
        [button setTitle:_answers[part][i] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor colorWithRed:0.83 green:0.55 blue:0.27 alpha:1.0] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"btnNormal.png"] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"btnHighlighted.png"] forState:UIControlStateHighlighted];
        button.titleLabel.font = [UIFont systemFontOfSize:20];
        
        if ([_answers[part][i] isEqualToString:_correct[part]]) {
            [button addTarget:self action:@selector(answeredCorrect:) forControlEvents:UIControlEventTouchUpInside];
        }
        else {
            [button addTarget:self action:@selector(answeredWrong:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        [self.answersView addSubview:button];
    }
}

#pragma mark Answer a question

- (void)answeredCorrect:(UIButton *)sender
{
    if (!_overlay) {
        _overlay = YES;
        [self.view addSubview:self.correctOverlay];
        [self performSelector:@selector(nextPart) withObject:self afterDelay:1.5];
        [self.audioPlayerCorrect play];
    }
}

- (void)answeredWrong:(UIButton *)sender
{
    if (!_overlay) {
        _overlay = YES;
        _wrongAnswered++;
        [self.view addSubview:self.wrongOverlay];
        [self performSelector:@selector(nextPart) withObject:self afterDelay:1.5];
        [self.audioPlayerWrong play];
    }
}

- (void)nextPart
{
    _overlay = NO;
    
    NSArray *buttons = [self.answersView subviews];
    for (int i=0; i<[buttons count]; i++) {
        [buttons[i] removeFromSuperview];
    }
    [self.correctOverlay removeFromSuperview];
    [self.wrongOverlay removeFromSuperview];

    if (self.part+1<[_questions count]) {
        self.part++;
        self.questionLabel.text = _questions[self.part];

        [self.correctOverlay removeFromSuperview];
        [self.wrongOverlay removeFromSuperview];
        
        [self initButtonsForPart:self.part];
    }
    else {
        if (_wrongAnswered>=[_questions count]-1) _rank = 1;
        else if (_wrongAnswered>=[_questions count]/2) _rank = 2;
        else _rank = 3;
        
        [self saveData];
        [self.questionLabel removeFromSuperview];
        [self.answersView removeFromSuperview];
        [self.correctOverlay removeFromSuperview];
        [self.wrongOverlay removeFromSuperview];
        [self openPopup];
    }
}

#pragma mark Popup

- (void)openPopup
{
    _end = YES;
    NSString *description;
    NSString *sackGraphic;
    
    NSString *freigeschaltet;
    if (_kapitelFreigeschaltet!=nil && ![_kapitelFreigeschaltet isEqualToString:@""]) {
        freigeschaltet = [NSString stringWithFormat:@"\n\nEs ist jetzt das Kapitel %@ freigeschaltet.", _kapitelFreigeschaltet];
    }
    else freigeschaltet = @"";

    switch (_rank) {
        case 1:
            description = [NSString stringWithFormat:@"Schade, NAME!\nDu hast leider nur 1 Stern erreicht.\nDu kannst den Test so oft du möchtest wiederholen. Übe ein bisschen und versuche es noch einmal.%@", freigeschaltet];
            sackGraphic = @"sack_sad.png";
            break;
        case 2:
            description = [NSString stringWithFormat:@"Sehr gut, NAME!\nDu hast 2 Sterne erreicht.\nMit ein bisschen mehr Übung schaffst du sicher 3 Sterne.%@", freigeschaltet];
            sackGraphic = @"sack_normal.png";
            break;
        case 3:
            description = [NSString stringWithFormat:@"Excellent, NAME!\nDu hast alle 3 Sterne erreicht.%@", freigeschaltet];
            sackGraphic = @"sack_happy.png";
            break;
        default:
            break;
    }
    
    Popup *popup = [[Popup alloc] initFor:sackGraphic withDescription:description returnBtn:NO menuBtn:YES nextBtn:NO yesBtn:NO noBtn:NO];
    [popup.menuBtn addTarget:self action:@selector(returnToMenu:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:popup];
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
    
    UIButton *button = (UIButton *)sender;
    [button.superview removeFromSuperview];
}

- (void)closePopup:(id)sender
{
    UIButton *button = (UIButton *)sender;
    [button.superview removeFromSuperview];
}

#pragma mark Shuffle

- (void)shuffle:(NSMutableArray *)arrayA and:(NSMutableArray *)arrayB and:(NSMutableArray *)arrayC
{
    NSUInteger count = [arrayA count];
    for (NSUInteger i=0; i<count; ++i) {
        NSInteger n = arc4random_uniform(count-i)+i;
        [arrayA exchangeObjectAtIndex:i withObjectAtIndex:n];
        if (arrayB!=nil) [arrayB exchangeObjectAtIndex:i withObjectAtIndex:n];
        if (arrayC!=nil) [arrayC exchangeObjectAtIndex:i withObjectAtIndex:n];
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
    if (!_end) {
        Popup *popup = [[Popup alloc] initFor:@"Info" withDescription:@"Bist du sicher, dass du den Test abbrechen möchtest?" returnBtn:NO menuBtn:NO nextBtn:NO yesBtn:YES noBtn:YES];
        [popup.yesBtn addTarget:self action:@selector(returnToMenu:) forControlEvents:UIControlEventTouchUpInside];
        [popup.noBtn addTarget:self action:@selector(closePopup:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:popup];
    }
}

#pragma mark Json Data

- (void)getJsonDataForChapterKey:(NSString *)chapterKey
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"multiplechoice" ofType:@"json"];
    NSData* data = [NSData dataWithContentsOfFile:filePath];
    NSError* error = nil;
    id json = [NSJSONSerialization JSONObjectWithData:data
                                              options:kNilOptions
                                                error:&error];
    
    if (!json) {
        NSLog(@"no json data received");
    }
    else{
        NSArray *array = [json objectForKey:chapterKey];
        NSDictionary *tempDict = [[NSDictionary alloc] init];
        NSMutableArray *tempArray = [[NSMutableArray alloc] init];
        NSMutableArray *tempWrongAnswers;
        
        _questions = [[NSMutableArray alloc] init];
        _correct = [[NSMutableArray alloc] init];
        _answers = [[NSMutableArray alloc] init];
        
        for (int i=0; i<[array count]; i++) {
            tempDict = array[i];
            [tempArray removeAllObjects];
            [tempWrongAnswers removeAllObjects];
            
            [_questions addObject:[tempDict objectForKey:@"question"]];
            
            [_correct addObject:[tempDict objectForKey:@"correctAnswer"]];
            
            [tempArray addObject:[tempDict objectForKey:@"correctAnswer"]];
            tempWrongAnswers = [[NSMutableArray alloc] initWithArray:[tempDict objectForKey:@"wrongAnswers"]];
            for (int n=0; n<[tempWrongAnswers count]; n++) {
                [tempArray addObject:tempWrongAnswers[n]];
            }
            [_answers addObject:[[NSMutableArray alloc] initWithArray:tempArray]];
        }
    }
}

#pragma mark Save Data

- (void)saveData
{
    NSMutableDictionary *chaptersSavedData = [[NSMutableDictionary alloc] initWithDictionary:self.appDelegate.chapters];
    [chaptersSavedData setObject:[NSNumber numberWithInt:3] forKey:[NSString stringWithFormat:@"%@-progress",_key]];
    if (_rank>[[self.appDelegate.chapters objectForKey:[NSString stringWithFormat:@"%@",_key]] integerValue]) {
        [chaptersSavedData setObject:[NSNumber numberWithInt:_rank] forKey:[NSString stringWithFormat:@"%@",_key]];
    }

    if (_rank>1) {
        if (([_key isEqualToString:@"1.1"] && ![self.appDelegate.chapters objectForKey:@"1.2"]) ||
            ([_key isEqualToString:@"1.1"] && [[self.appDelegate.chapters objectForKey:@"1.2"] integerValue]<1)) {
            [chaptersSavedData setObject:[NSNumber numberWithInt:0] forKey:[NSString stringWithFormat:@"1.2-progress"]];
            _kapitelFreigeschaltet = @"1.2";
        }
        else if (([_key isEqualToString:@"1.2"] && ![self.appDelegate.chapters objectForKey:@"1.3"]) ||
                 ([_key isEqualToString:@"1.2"] && [[self.appDelegate.chapters objectForKey:@"1.3"] integerValue]<1)) {
            [chaptersSavedData setObject:[NSNumber numberWithInt:0] forKey:[NSString stringWithFormat:@"1.3-progress"]];
            _kapitelFreigeschaltet = @"1.3";
        }
        else if (([_key isEqualToString:@"1.3"] && ![self.appDelegate.chapters objectForKey:@"1.4"]) ||
                 ([_key isEqualToString:@"1.3"] && [[self.appDelegate.chapters objectForKey:@"1.4"] integerValue]<1)) {
            [chaptersSavedData setObject:[NSNumber numberWithInt:0] forKey:[NSString stringWithFormat:@"1.4-progress"]];
            _kapitelFreigeschaltet = @"1.4";
        }
        else if (([_key isEqualToString:@"1.4"] && ![self.appDelegate.chapters objectForKey:@"1.5"]) ||
                 ([_key isEqualToString:@"1.4"] && [[self.appDelegate.chapters objectForKey:@"1.5"] integerValue]<1)) {
            [chaptersSavedData setObject:[NSNumber numberWithInt:0] forKey:[NSString stringWithFormat:@"1.5-progress"]];
            _kapitelFreigeschaltet = @"1.5";
        }
        else if ([_key isEqualToString:@"1.5"]) {
            if (![self.appDelegate.chapters objectForKey:@"1.6"] || [[self.appDelegate.chapters objectForKey:@"1.6"] integerValue]<1) {
                [chaptersSavedData setObject:[NSNumber numberWithInt:0] forKey:[NSString stringWithFormat:@"1.6-progress"]];
                _kapitelFreigeschaltet = @"1.6";
            }
            if (![self.appDelegate.chapters objectForKey:@"2.1"] || [[self.appDelegate.chapters objectForKey:@"2.1"] integerValue]<1) {
                [chaptersSavedData setObject:[NSNumber numberWithInt:0] forKey:[NSString stringWithFormat:@"2.1-progress"]];
                _kapitelFreigeschaltet = @"2.1";
            }
        }
        else if ([_key isEqualToString:@"1.6"]) {
            if (![self.appDelegate.chapters objectForKey:@"1.7"] || [[self.appDelegate.chapters objectForKey:@"1.7"] integerValue]<1) {
                [chaptersSavedData setObject:[NSNumber numberWithInt:0] forKey:[NSString stringWithFormat:@"1.7-progress"]];
                _kapitelFreigeschaltet = @"1.7";
            }
            if (![self.appDelegate.chapters objectForKey:@"3.1"] || [[self.appDelegate.chapters objectForKey:@"3.1"] integerValue]<1) {
                [chaptersSavedData setObject:[NSNumber numberWithInt:0] forKey:[NSString stringWithFormat:@"3.1-progress"]];
                _kapitelFreigeschaltet = @"3.1";
            }
        }
        else if (([_key isEqualToString:@"2.1"] && ![self.appDelegate.chapters objectForKey:@"2.2"]) ||
                 ([_key isEqualToString:@"2.1"] && [[self.appDelegate.chapters objectForKey:@"2.2"] integerValue]<1)) {
            [chaptersSavedData setObject:[NSNumber numberWithInt:0] forKey:[NSString stringWithFormat:@"2.2-progress"]];
            _kapitelFreigeschaltet = @"2.2";
        }
        else if (([_key isEqualToString:@"3.1"] && ![self.appDelegate.chapters objectForKey:@"3.2"]) ||
                 ([_key isEqualToString:@"3.1"] && [[self.appDelegate.chapters objectForKey:@"3.2"] integerValue]<1)) {
            [chaptersSavedData setObject:[NSNumber numberWithInt:0] forKey:[NSString stringWithFormat:@"3.2-progress"]];
            _kapitelFreigeschaltet = @"3.2";
        }
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
