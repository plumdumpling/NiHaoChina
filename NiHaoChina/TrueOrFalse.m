//
//  TrueOrFalse.m
//  NiHaoChina
//
//  Created by Leslie on 28.06.14.
//  Copyright (c) 2014 Leslie Zimmermann. All rights reserved.
//

#import "TrueOrFalse.h"
#import "ChapterViewController.h"
#import "CustomButton.h"
#import "Popup.h"

@interface TrueOrFalse () {
    NSString *_key;
    NSString *_kapitelFreigeschaltet;
    NSInteger _rank;
    NSInteger _wrongAnswered;
    NSMutableArray *_rightValues;
    NSMutableArray *_wrongValues;
    NSMutableArray *_statements;
    BOOL _overlay;
    BOOL _end;
}

@end

@implementation TrueOrFalse

- (id)initWithKey:(NSString *)key
{
    self = [super init];
    if (self) {
        _key = key;
        [self getJsonDataForChapterKey:_key];

        [self shuffle:_rightValues and:_wrongValues and:_statements];
        
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

    
    self.correctOverlay = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
    self.correctOverlay.image = [UIImage imageNamed:@"mc_richtig_overlay.png"];
    self.wrongOverlay = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
    self.wrongOverlay.image = [UIImage imageNamed:@"mc_falsch_overlay.png"];
    
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(100, 130, 824, 100)];
    label.text = @"Vervollständige den Satz.";
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont fontWithName:@"Shojumaru-Regular" size:30];
    label.textColor = [UIColor whiteColor];
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.numberOfLines = 0;
    [self.view addSubview:label];
    
    
    self.statementView = [[UIView alloc] initWithFrame:CGRectMake(100, 300, 824, 300)];
    [self.view addSubview:self.statementView];
    
    self.leftButton = [[UIButton alloc] initWithFrame:CGRectMake(100, 400, 360, 120)];
    [self.leftButton setBackgroundImage:[UIImage imageNamed:@"btnNormal.png"] forState:UIControlStateNormal];
    [self.leftButton setBackgroundImage:[UIImage imageNamed:@"btnHighlighted.png"] forState:UIControlStateHighlighted];
    [self.leftButton addTarget:self action:@selector(tapButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.leftButton setTitleColor:[UIColor colorWithRed:0.83 green:0.55 blue:0.27 alpha:1.0] forState:UIControlStateNormal];
    self.leftButton.titleLabel.font = [UIFont systemFontOfSize:30];
    [self.view addSubview:self.leftButton];
    
    self.rightButton = [[UIButton alloc] initWithFrame:CGRectMake(564, 400, 360, 120)];
    [self.rightButton setBackgroundImage:[UIImage imageNamed:@"btnNormal.png"] forState:UIControlStateNormal];
    [self.rightButton setBackgroundImage:[UIImage imageNamed:@"btnHighlighted.png"] forState:UIControlStateHighlighted];
    [self.rightButton addTarget:self action:@selector(tapButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.rightButton setTitleColor:[UIColor colorWithRed:0.83 green:0.55 blue:0.27 alpha:1.0] forState:UIControlStateNormal];
    self.rightButton.titleLabel.font = [UIFont systemFontOfSize:30];
    [self.view addSubview:self.rightButton];

    [self nextPart];
    
    [self initNavigationBarItemsWithBack:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tapButton:(UIButton *)sender
{
    if (!_overlay) {
        _overlay = YES;

        UIButton *button = (UIButton *)sender;
        
        if ([_rightValues[self.part] isEqualToString:button.titleLabel.text]) {
            // correct answer
            [self.audioPlayerCorrect play];
            [self performSelector:@selector(addCorrectOverlay) withObject:self afterDelay:1];
            
            NSArray *subviews = [self.statementView subviews];
            
            for (int i=0; i<[subviews count]; i++) {
                if ([subviews[i] isKindOfClass:[UITextField class]]) {
                    UITextField *textField = (UITextField *)subviews[i];
                    if ([_rightValues[self.part] isEqualToString:@"kein bù"]) textField.text = @"";
                    else textField.text = button.titleLabel.text;
                    textField.textColor = [UIColor whiteColor];
                }
            }
        }
        else {
            // wrong answer
            [self.audioPlayerWrong play];
            [self performSelector:@selector(addWrongOverlay) withObject:self afterDelay:1];
            _wrongAnswered++;
            
            NSArray *subviews = [self.statementView subviews];
            
            for (int i=0; i<[subviews count]; i++) {
                if ([subviews[i] isKindOfClass:[UITextField class]]) {
                    UITextField *textField = (UITextField *)subviews[i];
                    if ([_rightValues[self.part] isEqualToString:@"kein bù"]) textField.text = @"";
                    else textField.text = _rightValues[self.part];
                    textField.textColor = [UIColor colorWithRed:0.83 green:0.55 blue:0.27 alpha:1.0];
                }
            }
        }
        
        if (self.part<[_statements count]-1) {
            self.part++;
            [self performSelector:@selector(nextPart) withObject:self afterDelay:2];
        }
        else {
            [self performSelector:@selector(endOfTest) withObject:self afterDelay:2];
        }
    }
}

- (void)endOfTest
{
    _end = YES;
    
    if (_wrongAnswered>=[_statements count]-1) _rank = 1;
    else if (_wrongAnswered>=[_statements count]/2) _rank = 2;
    else _rank = 3;
    
    [self saveData];
    [self.correctOverlay removeFromSuperview];
    [self.wrongOverlay removeFromSuperview];
    [self openPopup];
}

- (void)addCorrectOverlay
{
    if (!_end) [self.view addSubview:self.correctOverlay];
}

- (void)addWrongOverlay
{
    if (!_end) [self.view addSubview:self.wrongOverlay];
}


- (void)nextPart
{
    [self.correctOverlay removeFromSuperview];
    [self.wrongOverlay removeFromSuperview];
    _overlay = NO;

    NSArray *array = [_statements[self.part] componentsSeparatedByString:@"+"];
    UILabel *label;
    UITextField *textField;
    
    if (self.part!=0) [self.statementView.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
    
    for (int i=0; i<[array count]; i++) {
        if ([array[i] isEqualToString:@"$"]) {
            textField = [[UITextField alloc] init];
            textField.background = [UIImage imageNamed:@"gap.png"];
            textField.userInteractionEnabled = NO;
            textField.textAlignment = NSTextAlignmentCenter;
            textField.font = [UIFont systemFontOfSize:30];
                        
            if (i==0) textField.frame = CGRectMake(0, 0, 80, 50);
            else {
                NSArray *subviews = [self.statementView subviews];
                NSNumber *posNewLabel = [[NSNumber alloc] initWithInt:0];
                
                for (int n=0; n<[subviews count]; n++) {
                    UILabel *label = (UILabel *)subviews[n];
                    posNewLabel = [NSNumber numberWithFloat:([posNewLabel floatValue] + label.frame.size.width + 20)];
                }
                textField.frame = CGRectMake([posNewLabel floatValue], 0, 80, 50);
            }
            
            [self.statementView addSubview:textField];
        }
        else {
            label = [[UILabel alloc] init];
            label.text = array[i];
            label.font = [UIFont systemFontOfSize:30];
            label.textColor = [UIColor whiteColor];
            CGSize textSize = [[label text] sizeWithAttributes:@{NSFontAttributeName:[label font]}];
            CGFloat strikeWidth = textSize.width;
            
            if (i==0) label.frame = CGRectMake(0, 5, strikeWidth, 40);
            else {
                NSArray *subviews = [self.statementView subviews];
                NSNumber *posNewLabel = [[NSNumber alloc] initWithInt:0];
                
                for (int n=0; n<[subviews count]; n++) {
                    UILabel *label = (UILabel *)subviews[n];
                    posNewLabel = [NSNumber numberWithFloat:([posNewLabel floatValue] + label.frame.size.width + 20)];
                }
                label.frame = CGRectMake([posNewLabel floatValue], 5, strikeWidth, 40);
            }
            
            [self.statementView addSubview:label];
        }
    }
    
    if ([_rightValues[self.part] isEqualToString:@"."] || [_rightValues[self.part] isEqualToString:@"bù"]) {
        [self.leftButton setTitle:_rightValues[self.part] forState:UIControlStateNormal];
        [self.rightButton setTitle:_wrongValues[self.part] forState:UIControlStateNormal];
    }
    else {
        [self.leftButton setTitle:_wrongValues[self.part] forState:UIControlStateNormal];
        [self.rightButton setTitle:_rightValues[self.part] forState:UIControlStateNormal];
    }
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
    Popup *popup = [[Popup alloc] initFor:@"Info" withDescription:@"Bist du sicher, dass du den Test abbrechen möchtest?" returnBtn:NO menuBtn:NO nextBtn:NO yesBtn:YES noBtn:YES];
    [popup.yesBtn addTarget:self action:@selector(returnToMenu:) forControlEvents:UIControlEventTouchUpInside];
    [popup.noBtn addTarget:self action:@selector(closePopup:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:popup];
}

#pragma mark Popup

- (void)openPopup
{
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

#pragma mark Json Data

- (void)getJsonDataForChapterKey:(NSString *)chapterKey
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"richtigfalsch" ofType:@"json"];
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
        NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
        
        _rightValues = [[NSMutableArray alloc] init];
        _wrongValues = [[NSMutableArray alloc] init];
        _statements = [[NSMutableArray alloc] init];
        
        for (int i=0; i<[array count]; i++) {
            tempDict = array[i];
            
            [_rightValues addObject:[tempDict objectForKey:@"buttonRight"]];
            [_wrongValues addObject:[tempDict objectForKey:@"buttonWrong"]];
            [_statements addObject:[tempDict objectForKey:@"statement"]];
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
