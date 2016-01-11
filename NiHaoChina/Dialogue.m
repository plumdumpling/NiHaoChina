//
//  Dialogue.m
//  NiHaoChina
//
//  Created by Leslie on 12.06.14.
//  Copyright (c) 2014 Leslie Zimmermann. All rights reserved.
//

#import "Dialogue.h"
#import "ChapterViewController.h"
#import "CustomButton.h"
#import "Popup.h"

#import "Memory.h"
#import "MurmelGame.h"
#import "InteractiveGraphics.h"
#import "Textadventure.h"

#import "FillInText.h"
#import "TrueOrFalse.h"

@interface Dialogue () {
    NSString *_dialogueKey;
    NSString *_personA;
    NSString *_personB;
    NSMutableArray *_dialogueCN;
    NSMutableArray *_dialogueDE;
    NSMutableArray *_dialogueDescriptions;
    NSMutableArray *_dialogueImages;
    NSMutableArray *_sounds;
    BOOL _end;
}

@end

@implementation Dialogue

- (id)initWithKey:(NSString *)key
{
    self = [super init];
    if (self) {
        _dialogueKey = key;
        [self getJsonDataForDialogueKey:_dialogueKey];
        
        self.bubbleDE =  [UIImage imageNamed:@"bubbleDE.png"];
        self.bubbleCN =  [UIImage imageNamed:@"bubbleCN.png"];

        self.appDelegate = [[UIApplication sharedApplication] delegate];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self customInit];
    [self initNavigationBarItemsWithBack:YES];
}

- (void)customInit
{
    UIImageView *backgroundImage;
    
    if ([_personA isEqualToString:@"airport"] || [_personB isEqualToString:@"airport"]) {
        backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background_airport.png"]];
    }
    else if ([_personA isEqualToString:@"restaurant"] || [_personB isEqualToString:@"restaurant"]) {
        backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background_restaurant.png"]];
    }
    else if ([_personA isEqualToString:@"hotel"] || [_personB isEqualToString:@"hotel"]) {
        backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background_hotel.png"]];
    }
    else if ([_personA isEqualToString:@"sack"] || [_personB isEqualToString:@"sack"]) {
        backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background.png"]];
    }
    else {
        backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background_chineseStreet.png"]];
    }

    [self.view addSubview:backgroundImage];
    [self.view sendSubviewToBack:backgroundImage];

    self.part = 0;

    if ([_dialogueImages count]>0) {
        self.personDE = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@%@.png",_personA,_dialogueImages[0]]]];
        [self.personDE setFrame:CGRectMake(0, 0, 450, 768)];
        [self.view addSubview:self.personDE];
        
        self.personCN = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@%@.png",_personB,_dialogueImages[1]]]];
        [self.personCN setFrame:CGRectMake(574, 0, 450, 768)];
        [self.view addSubview:self.personCN];
    }

    self.speakBubble = [[UIImageView alloc] initWithImage:self.bubbleDE];
    [self.speakBubble setFrame:CGRectMake(0, 518, 1024, 250)];
    [self.view addSubview:self.speakBubble];

    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.minimumLineHeight = 70.0f;
    
    if ([_dialogueCN count]>0) {
        self.textDE = [[UITextView alloc] initWithFrame:CGRectMake(130, 580, 900, 200)];
        self.textDE.allowsEditingTextAttributes = YES;
        self.textDE.userInteractionEnabled = NO;
        self.textDE.scrollEnabled = NO;
        self.textDE.editable = NO;
        self.textDE.text = _dialogueDE[0];
        self.textDE.attributedText = [[NSAttributedString alloc] initWithString:self.textDE.text
                                                                     attributes:@{NSParagraphStyleAttributeName:paragraphStyle, NSFontAttributeName:[UIFont systemFontOfSize:25.0f]}];
        self.textDE.backgroundColor = [UIColor clearColor];
        self.textDE.textColor = [UIColor colorWithRed:0.65 green:0.04 blue:0.04 alpha:1.0];
        [self.view addSubview:self.textDE];
    }
    
    if ([_dialogueCN count]>0) {
        self.textCN = [[UITextView alloc] initWithFrame:CGRectMake(130, 545, 900, 200)];
        self.textCN.allowsEditingTextAttributes = YES;
        self.textCN.userInteractionEnabled = NO;
        self.textCN.scrollEnabled = NO;
        self.textCN.editable = NO;
        self.textCN.text = _dialogueCN[0];
        self.textCN.attributedText = [[NSAttributedString alloc] initWithString:self.textCN.text
                                                                     attributes:@{NSParagraphStyleAttributeName:paragraphStyle, NSFontAttributeName:[UIFont systemFontOfSize:30.0f]}];
        self.textCN.backgroundColor = [UIColor clearColor];
        self.textCN.textColor = [UIColor colorWithRed:0.25 green:0.10 blue:0.04 alpha:1.0];
        [self.view addSubview:self.textCN];
    }

    if ([_dialogueDescriptions count]>0) {
        self.textDescription = [[UITextView alloc] initWithFrame:CGRectMake(130, 570, 764, 200)];
        self.textDescription.allowsEditingTextAttributes = YES;
        self.textDescription.userInteractionEnabled = NO;
        self.textDescription.scrollEnabled = NO;
        self.textDescription.editable = NO;
        self.textDescription.text = _dialogueDescriptions[0];
        self.textDescription.textAlignment = NSTextAlignmentLeft;
        self.textDescription.backgroundColor = [UIColor clearColor];
        self.textDescription.textColor = [UIColor colorWithRed:0.25 green:0.10 blue:0.04 alpha:1.0];
        self.textDescription.font = [UIFont systemFontOfSize:20];
        [self.view addSubview:self.textDescription];
    }

    self.nextBtn = [[UIButton alloc] initWithFrame:CGRectMake(893, 630, 60, 60)];
    [self.nextBtn setBackgroundImage:[UIImage imageNamed:@"btnNextDialog.png"] forState:UIControlStateNormal];
    [self.nextBtn setBackgroundImage:[UIImage imageNamed:@"btnNextDialog.png"] forState:UIControlStateHighlighted];
    [self.nextBtn addTarget:self action:@selector(nextPart:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.nextBtn];

    self.listenAgainBtn = [[UIButton alloc] initWithFrame:CGRectMake(893, 570, 60, 60)];
    [self.listenAgainBtn setBackgroundImage:[UIImage imageNamed:@"btnSound.png"] forState:UIControlStateNormal];
    [self.listenAgainBtn setBackgroundImage:[UIImage imageNamed:@"btnSound.png"] forState:UIControlStateHighlighted];
    [self.listenAgainBtn addTarget:self action:@selector(listenAgain:) forControlEvents:UIControlEventTouchUpInside];
    if (![_dialogueKey isEqualToString:@"1.2"] && ![_dialogueKey isEqualToString:@"1.3"]) [self.view addSubview:self.listenAgainBtn];

    [self playSoundFile];
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
        Popup *popup = [[Popup alloc] initFor:@"Info" withDescription:@"Bist du sicher, dass du diese Lektion abbrechen möchtest?" returnBtn:NO menuBtn:NO nextBtn:NO yesBtn:YES noBtn:YES];
        [popup.yesBtn addTarget:self action:@selector(returnToMenu:) forControlEvents:UIControlEventTouchUpInside];
        [popup.noBtn addTarget:self action:@selector(closePopup:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:popup];
    }
}

#pragma mark Continue Dialogue

- (void)nextPart:(UIGestureRecognizer *)sender
{
    if (self.part+1<[_dialogueCN count]) {
        self.part++;
        self.textCN.text = _dialogueCN[self.part];
        self.textDE.text = _dialogueDE[self.part];
        
        if ([_dialogueKey isEqualToString:@"1.2"] || [_dialogueKey isEqualToString:@"1.3"]) {
            if (![_dialogueDescriptions[self.part] isEqualToString:@""]) {
                self.textDescription.text = _dialogueDescriptions[self.part];
                self.speakBubble.image = self.bubbleDE;
                [self.listenAgainBtn removeFromSuperview];
            }
            else {
                self.textDescription.text = _dialogueDescriptions[self.part];
                self.speakBubble.image = self.bubbleCN;
                [self.view addSubview:self.listenAgainBtn];
                [self.view bringSubviewToFront:self.textCN];
                [self.view bringSubviewToFront:self.textDE];
                
                self.speakBubble.image = self.bubbleCN;
                self.personCN.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@%@.png",_personB,_dialogueImages[self.part]]];
                
                NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
                paragraphStyle.minimumLineHeight = 70.0f;
                self.textDE.attributedText = [[NSAttributedString alloc] initWithString:self.textDE.text
                                                                             attributes:@{NSParagraphStyleAttributeName:paragraphStyle, NSFontAttributeName:[UIFont systemFontOfSize:25.0f]}];
                self.textDE.textColor = [UIColor colorWithRed:0.65 green:0.04 blue:0.04 alpha:1.0];
                self.textCN.attributedText = [[NSAttributedString alloc] initWithString:self.textCN.text
                                                                             attributes:@{NSParagraphStyleAttributeName:paragraphStyle, NSFontAttributeName:[UIFont systemFontOfSize:30.0f]}];
                self.textCN.textColor = [UIColor colorWithRed:0.25 green:0.10 blue:0.04 alpha:1.0];
           }
        }
        else if ([_dialogueKey isEqualToString:@"1.7"]) {
            if (self.part==0 || self.part==7 || self.part==9) {
                self.speakBubble.image = self.bubbleDE;
                self.personDE.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@%@.png",_personA,_dialogueImages[self.part]]];
            }
            else {
                self.speakBubble.image = self.bubbleCN;
                self.personCN.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@%@.png",_personB,_dialogueImages[self.part]]];
            }
        }
        else {
            if ([_dialogueKey isEqualToString:@"1.6"] && self.part==3) {
                self.textCN.font = [UIFont systemFontOfSize:27];
            }
            else if ([_dialogueKey isEqualToString:@"1.6"] && self.part==4) {
                self.textCN.font = [UIFont systemFontOfSize:30];
            }
            
            if ((self.part % 2) == 0) {
                self.speakBubble.image = self.bubbleDE;
                self.personDE.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@%@.png",_personA,_dialogueImages[self.part]]];
            }
            else {
                self.speakBubble.image = self.bubbleCN;
                self.personCN.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@%@.png",_personB,_dialogueImages[self.part]]];
            }
        }
        
        [self playSoundFile];
    }
    else {
        [self saveData];
        [self.speakBubble removeFromSuperview];
        [self.nextBtn removeFromSuperview];
        [self.listenAgainBtn removeFromSuperview];
        [self.textCN removeFromSuperview];
        [self.textDE removeFromSuperview];
        [self endOfDialogue];
    }
}

#pragma mark Popup

- (void)endOfDialogue
{
    _end = YES;
    Popup *popup = [[Popup alloc] initFor:@"Dialogue" withDescription:@"Sehr gut! Du hast den ersten Lernabschnitt der Lektion abgeschlossen. Du kannst ihn jederzeit wiederholen, indem du ihn im Hauptmenü erneut auswählst." returnBtn:YES menuBtn:YES nextBtn:YES yesBtn:NO noBtn:NO];
    [popup.returnBtn addTarget:self action:@selector(startDialogueAgain:) forControlEvents:UIControlEventTouchUpInside];
    [popup.menuBtn addTarget:self action:@selector(returnToMenu:) forControlEvents:UIControlEventTouchUpInside];
    [popup.nextBtn addTarget:self action:@selector(loadGame:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:popup];
}

- (void)startDialogueAgain:(UIGestureRecognizer *)sender
{
    _end = NO;
    [self.personCN removeFromSuperview];
    [self.personDE removeFromSuperview];
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

- (void)loadGame:(UIGestureRecognizer *)sender
{
    _end = NO;
    
    if ([_dialogueKey isEqualToString:@"1.1"] || [_dialogueKey isEqualToString:@"1.5"] || [_dialogueKey isEqualToString:@"2.1"] || [_dialogueKey isEqualToString:@"3.1"] || [_dialogueKey isEqualToString:@"3.2"]) {
        Textadventure *practiceViewController = [[Textadventure alloc] initWithKey:_dialogueKey];
        [self.navigationController pushViewController:practiceViewController animated:NO];
    }
    else if ([_dialogueKey isEqualToString:@"1.7"]) {
        InteractiveGraphics *practiceViewController = [[InteractiveGraphics alloc] initWithKey:_dialogueKey];
        [self.navigationController pushViewController:practiceViewController animated:NO];
    }
    else if ([_dialogueKey isEqualToString:@"1.3"] || [_dialogueKey isEqualToString:@"2.2"]) {
        Memory *practiceViewController = [[Memory alloc] initWithKey:_dialogueKey];
        [self.navigationController pushViewController:practiceViewController animated:NO];
    }
    else if ([_dialogueKey isEqualToString:@"1.2"] || [_dialogueKey isEqualToString:@"1.4"]) {
        MurmelGame *practiceViewController = [[MurmelGame alloc] initWithKey:_dialogueKey];
        [self.navigationController pushViewController:practiceViewController animated:NO];
    }
    else if ([_dialogueKey isEqualToString:@"1.6"]) {
        TrueOrFalse *testsViewController = [[TrueOrFalse alloc] initWithKey:_dialogueKey];
        [self.navigationController pushViewController:testsViewController animated:NO];
    }
}

- (void)closePopup:(id)sender
{
    UIButton *button = (UIButton *)sender;
    [button.superview removeFromSuperview];
}

#pragma mark Playing Sound

- (void)playSoundFile
{
    NSString *fileName = [NSString stringWithFormat:@"%@", _sounds[self.part]];
    NSString *soundFilePath = [NSString stringWithFormat:@"%@/%@.mp3", [[NSBundle mainBundle] resourcePath], fileName];
    NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
    
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:nil];
    self.audioPlayer.numberOfLoops = 0;
    [self.audioPlayer play];
}

- (void)listenAgain:(UIButton *)sender
{
    [self.audioPlayer play];
}

#pragma mark Json Data

- (void)getJsonDataForDialogueKey:(NSString *)dialogueKey
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"dialogues" ofType:@"json"];
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
        
        _dialogueCN = [[NSMutableArray alloc] init];
        _dialogueDE = [[NSMutableArray alloc] init];
        if ([dialogueKey isEqualToString:@"1.2"] || [_dialogueKey isEqualToString:@"1.3"]) _dialogueDescriptions = [[NSMutableArray alloc] init];
        _dialogueImages = [[NSMutableArray alloc] init];
        _sounds = [[NSMutableArray alloc] init];
        
        for (int i=0; i<[array count]; i++) {
            tempDict = array[i];
            [_dialogueCN addObject:[tempDict objectForKey:@"cn"]];
            [_dialogueDE addObject:[tempDict objectForKey:@"de"]];
            if ([dialogueKey isEqualToString:@"1.2"] || [_dialogueKey isEqualToString:@"1.3"]) {
                [_dialogueDescriptions addObject:[tempDict objectForKey:@"text"]];
            }
            [_dialogueImages addObject:[tempDict objectForKey:@"characterImage"]];
            [_sounds addObject:[tempDict objectForKey:@"sfx"]];
        }
    }
}

#pragma mark Save Data

- (void)saveData
{
    NSMutableDictionary *chaptersSavedData = [[NSMutableDictionary alloc] initWithDictionary:self.appDelegate.chapters];
    
    if ([_dialogueKey isEqualToString:@"1.6"]) {
        // no practice available
        if ([[self.appDelegate.chapters objectForKey:[NSString stringWithFormat:@"%@-progress",_dialogueKey]] integerValue]<2) {
            [chaptersSavedData setObject:[NSNumber numberWithInt:2] forKey:[NSString stringWithFormat:@"%@-progress",_dialogueKey]];
        }
    }
    else {
        if ([[self.appDelegate.chapters objectForKey:[NSString stringWithFormat:@"%@-progress",_dialogueKey]] integerValue]<1) {
            [chaptersSavedData setObject:[NSNumber numberWithInt:1] forKey:[NSString stringWithFormat:@"%@-progress",_dialogueKey]];
        }
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
