//
//  InfoViewController.m
//  NiHaoChina
//
//  Created by Leslie on 03.06.14.
//  Copyright (c) 2014 Leslie Zimmermann. All rights reserved.
//

#import "InfoViewController.h"
#import "CustomButton.h"
#import "Popup.h"

@interface InfoViewController () {
    NSInteger _infoIndex;
    NSString *_infoTitle;
    
    NSInteger _helpPart;
    NSInteger _helpMax;

    NSString *_selectedGlossarChapter;
    NSMutableArray *_vocDE;
    NSMutableArray *_vocCN;
}

@end

@implementation InfoViewController

- (id)initWithIndex:(NSInteger)index
{
    self = [super init];
    if (self) {
        _infoIndex = index;
        
        _vocDE = [[NSMutableArray alloc] init];
        _vocCN = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.appDelegate = [[UIApplication sharedApplication] delegate];

    switch (_infoIndex) {
        case 0:
            _infoTitle = [[NSString alloc] initWithFormat:@"Glossar"];
            [self contentForGlossar];
            break;
            
        case 1:
            _infoTitle = [[NSString alloc] initWithFormat:@"Einstellungen"];
            [self contentForSettings];
            break;
            
        case 2:
            _infoTitle = [[NSString alloc] initWithFormat:@"Hilfe"];
            [self contentForHelp];
            break;
            
        case 3:
            _infoTitle = [[NSString alloc] initWithFormat:@"Informationen"];
            [self contentForInfo];
            break;
            
        default:
            break;
    }

    UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background.png"]];
    [self.view addSubview:backgroundImage];
    [self.view sendSubviewToBack:backgroundImage];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(149, 120, 726, 90)];
    [titleLabel setFont:[UIFont fontWithName:@"Shojumaru-Regular" size:50]];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = _infoTitle;
    [self.view addSubview:titleLabel];
    
    [self initNavigationBarItemsWithHome:YES andBack:YES];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Initialize Glossar

- (void)contentForGlossar
{
    // left col
    self.glossarTopics = @[@"Begrüßung und Verabschiedung", @"Personalpronomen", @"Smalltalk", @"Zahlen", @"Frage und Verneinung", @"Farbe", @"Im Hotel", @"Am Flughafen", @"Essen und Getränke bestellen", @"Im Restaurant bezahlen"];
    self.glossarChapters = @[@"1.1", @"1.3", @"1.4", @"1.5", @"1.6", @"1.7", @"2.1", @"2.2", @"3.1", @"3.2"];

    UIButton *chapterButton;
    self.leftGlossarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 500, 768)];
    [self.view addSubview:self.leftGlossarView];
    
    for (int i=0; i<[self.glossarTopics count]; i++) {
        if (i<=5) chapterButton = [[UIButton alloc] initWithFrame:CGRectMake(100, (i*30)+250, 300, 20)];
        else if (i>=6 && i<=7) chapterButton = [[UIButton alloc] initWithFrame:CGRectMake(100, (i*30)+290, 300, 20)];
        else if (i>=8) chapterButton = [[UIButton alloc] initWithFrame:CGRectMake(100, (i*30)+330, 300, 20)];

        [chapterButton setTitle:self.glossarTopics[i] forState:UIControlStateNormal];
        chapterButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        chapterButton.tag = i;
        [chapterButton addTarget:self action:@selector(changeGlossarVocabulary:) forControlEvents:UIControlEventTouchUpInside];
        
        if (i==0) [chapterButton setSelected:YES];
        else [chapterButton setSelected:NO];
        
        [chapterButton setTitleColor:[UIColor colorWithRed:0.94 green:0.63 blue:0.35 alpha:1] forState:UIControlStateSelected];
        [chapterButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

        [self.leftGlossarView addSubview:chapterButton];
    }
    
    UILabel *chapterLabel;
    for (int c=0; c<3; c++) {
        switch (c) {
            case 0:
                chapterLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 210, 300, 30)];
                chapterLabel.text = @"Erste Schritte";
                break;
            case 1:
                chapterLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 434, 300, 30)];
                chapterLabel.text = @"Auf Reisen";
                break;
            case 2:
                chapterLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 535, 300, 30)];
                chapterLabel.text = @"Im Restaurant";
                break;
            default:
                break;
        }
        
        chapterLabel.font = [UIFont fontWithName:@"Shojumaru-Regular" size:25];
        chapterLabel.textColor = [UIColor whiteColor];
        [self.view addSubview:chapterLabel];
    }
    
    
    // right col
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(460, 210, 460, 440)];
    self.scrollView.backgroundColor = [UIColor colorWithRed:0.25 green:0.10 blue:0.04 alpha:0.5];
    [self.view addSubview:self.scrollView];
    
    self.topicLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 15, 360, 30)];
    self.topicLabel.text = self.glossarTopics[0];
    self.topicLabel.textColor = [UIColor whiteColor];
    self.topicLabel.font = [UIFont boldSystemFontOfSize:20];
    [self.scrollView addSubview:self.topicLabel];
    
    self.wordsDE = [[UITextView alloc] initWithFrame:CGRectMake(20, 60, 200, 340)];
    self.wordsDE.backgroundColor = [UIColor clearColor];
    self.wordsDE.editable = NO;
    self.wordsDE.userInteractionEnabled = NO;
    self.wordsDE.scrollEnabled = NO;
    self.wordsDE.textColor = [UIColor whiteColor];
    self.wordsDE.font = [UIFont systemFontOfSize:15];
    [self.scrollView addSubview:self.wordsDE];

    self.wordsCN = [[UITextView alloc] initWithFrame:CGRectMake(230, 60, 200, 340)];
    self.wordsCN.backgroundColor = [UIColor clearColor];
    self.wordsCN.editable = NO;
    self.wordsCN.userInteractionEnabled = NO;
    self.wordsCN.scrollEnabled = NO;
    self.wordsCN.textColor = [UIColor whiteColor];
    self.wordsCN.font = [UIFont systemFontOfSize:15];
    [self.scrollView addSubview:self.wordsCN];
    
    [self getJsonDataForChapterKey:@"1.1"];
}

- (void)changeGlossarVocabulary:(UIButton *)sender
{
    NSArray *subviews = [self.leftGlossarView subviews];
    for (int i=0; i<[subviews count]; i++) {
        if ([subviews[i] isKindOfClass:[UIButton class]]) {
            UIButton *button = subviews[i];
            [button setSelected:NO];
        }
    }

    UIButton *senderBtn = (UIButton *)sender;
    [senderBtn setSelected:YES];
    [self getJsonDataForChapterKey:self.glossarChapters[senderBtn.tag]];
    self.topicLabel.text = self.glossarTopics[senderBtn.tag];
}


#pragma mark Initialize Settings

- (void)contentForSettings
{
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(300, 260, 200, 60)];
    nameLabel.text = @"Dein Name:";
    nameLabel.font = [UIFont fontWithName:@"Shojumaru-Regular" size:25];
    nameLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:nameLabel];
    
    self.nameField = [[UITextField alloc] initWithFrame:CGRectMake(490, 260, 224, 60)];
    self.nameField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.nameField.textAlignment = NSTextAlignmentLeft;
    self.nameField.userInteractionEnabled = YES;
    self.nameField.enabled = YES;
    self.nameField.enablesReturnKeyAutomatically = NO;
    self.nameField.clearsOnBeginEditing = NO;
    self.nameField.borderStyle = UITextBorderStyleRoundedRect;
    self.nameField.keyboardType = UIKeyboardTypeDefault;
    self.nameField.delegate = (id)self;
    self.nameField.text = self.appDelegate.userName;
    self.nameField.textAlignment = NSTextAlignmentCenter;
    self.nameField.font = [UIFont systemFontOfSize:25];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewDidChange:) name:UITextFieldTextDidEndEditingNotification object:self.nameField];
    [self.view addSubview:self.nameField];
    
    UIButton *resetButton = [[UIButton alloc] initWithFrame:CGRectMake(312, 360, 400, 60)];
    [resetButton setTitle:@"App zurücksetzen" forState:UIControlStateNormal];
    [resetButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    resetButton.titleLabel.font = [UIFont fontWithName:@"Shojumaru-Regular" size:30];
    [resetButton addTarget:self action:@selector(setAppDataToDefault:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:resetButton];

    UIButton *unblockButton = [[UIButton alloc] initWithFrame:CGRectMake(232, 450, 560, 60)];
    [unblockButton setTitle:@"Alle Kapitel freischalten" forState:UIControlStateNormal];
    [unblockButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    unblockButton.titleLabel.font = [UIFont fontWithName:@"Shojumaru-Regular" size:30];
    [unblockButton addTarget:self action:@selector(unblockAll:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:unblockButton];
    
    UITextView *unblockText = [[UITextView alloc] initWithFrame:CGRectMake(202, 500, 620, 100)];
    unblockText.userInteractionEnabled = NO;
    unblockText.editable = NO;
    unblockText.scrollEnabled = NO;
    unblockText.backgroundColor = [UIColor clearColor];
    unblockText.text = @"Die Freischalt-Funktion wurde für die Abgabe im Fach E-Learning implementiert.\nIn der App-Store-Version ist diese Funktion nicht verfügbar.";
    unblockText.textColor = [UIColor whiteColor];
    unblockText.font = [UIFont systemFontOfSize:15];
    unblockText.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:unblockText];
}

- (void)setAppDataToDefault:(UIButton *)sender
{
    Popup *popup = [[Popup alloc] initFor:@"Info" withDescription:@"Bist Du sicher, dass Du die App zurücksetzen möchtest?\nDein Fortschritt geht dabei verloren." returnBtn:NO menuBtn:NO nextBtn:NO yesBtn:YES noBtn:YES];
    [popup.yesBtn addTarget:self action:@selector(deleteAppData:) forControlEvents:UIControlEventTouchUpInside];
    [popup.noBtn addTarget:self action:@selector(closePopup:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:popup];
}

- (void)closePopup:(UIButton *)sender
{
    UIButton *button = (UIButton *)sender;
    [button.superview removeFromSuperview];    
}
    
- (void)deleteAppData:(UIButton *)sender
{
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"HasLaunchedOnce"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    _appDelegate.chapters = [[NSMutableDictionary alloc] init];
    _appDelegate.userName = @"";
    
    [self.appDelegate deleteData];
    
    UIButton *button = (UIButton *)sender;
    [button.superview removeFromSuperview];
    Popup *popup = [[Popup alloc] initFor:@"Info" withDescription:@"Die App wird zurückgesetzt." returnBtn:NO menuBtn:NO nextBtn:NO yesBtn:NO noBtn:NO];
    [self.view addSubview:popup];

    [self performSelector:@selector(returnToRootVC) withObject:self afterDelay:2];
}

- (void)unblockAll:(UIButton *)sender
{
    NSMutableDictionary *chapterSavedData = [[NSMutableDictionary alloc] initWithDictionary:self.appDelegate.chapters];
    [chapterSavedData setObject:[NSNumber numberWithInt:3] forKey:[NSString stringWithFormat:@"1.1-progress"]];
    [chapterSavedData setObject:[NSNumber numberWithInt:0] forKey:[NSString stringWithFormat:@"1.1"]];
    [chapterSavedData setObject:[NSNumber numberWithInt:3] forKey:[NSString stringWithFormat:@"1.2-progress"]];
    [chapterSavedData setObject:[NSNumber numberWithInt:0] forKey:[NSString stringWithFormat:@"1.2"]];
    [chapterSavedData setObject:[NSNumber numberWithInt:3] forKey:[NSString stringWithFormat:@"1.3-progress"]];
    [chapterSavedData setObject:[NSNumber numberWithInt:0] forKey:[NSString stringWithFormat:@"1.3"]];
    [chapterSavedData setObject:[NSNumber numberWithInt:3] forKey:[NSString stringWithFormat:@"1.4-progress"]];
    [chapterSavedData setObject:[NSNumber numberWithInt:0] forKey:[NSString stringWithFormat:@"1.4"]];
    [chapterSavedData setObject:[NSNumber numberWithInt:3] forKey:[NSString stringWithFormat:@"1.5-progress"]];
    [chapterSavedData setObject:[NSNumber numberWithInt:0] forKey:[NSString stringWithFormat:@"1.5"]];
    [chapterSavedData setObject:[NSNumber numberWithInt:3] forKey:[NSString stringWithFormat:@"1.6-progress"]];
    [chapterSavedData setObject:[NSNumber numberWithInt:0] forKey:[NSString stringWithFormat:@"1.6"]];
    [chapterSavedData setObject:[NSNumber numberWithInt:3] forKey:[NSString stringWithFormat:@"1.7-progress"]];
    [chapterSavedData setObject:[NSNumber numberWithInt:0] forKey:[NSString stringWithFormat:@"1.7"]];
    [chapterSavedData setObject:[NSNumber numberWithInt:3] forKey:[NSString stringWithFormat:@"1.8-progress"]];
    [chapterSavedData setObject:[NSNumber numberWithInt:0] forKey:[NSString stringWithFormat:@"1.8"]];
    
    [chapterSavedData setObject:[NSNumber numberWithInt:3] forKey:[NSString stringWithFormat:@"2.1-progress"]];
    [chapterSavedData setObject:[NSNumber numberWithInt:0] forKey:[NSString stringWithFormat:@"2.1"]];
    [chapterSavedData setObject:[NSNumber numberWithInt:3] forKey:[NSString stringWithFormat:@"2.2-progress"]];
    [chapterSavedData setObject:[NSNumber numberWithInt:0] forKey:[NSString stringWithFormat:@"2.2"]];
    [chapterSavedData setObject:[NSNumber numberWithInt:3] forKey:[NSString stringWithFormat:@"2.3-progress"]];
    [chapterSavedData setObject:[NSNumber numberWithInt:0] forKey:[NSString stringWithFormat:@"2.3"]];

    [chapterSavedData setObject:[NSNumber numberWithInt:3] forKey:[NSString stringWithFormat:@"3.1-progress"]];
    [chapterSavedData setObject:[NSNumber numberWithInt:0] forKey:[NSString stringWithFormat:@"3.1"]];
    [chapterSavedData setObject:[NSNumber numberWithInt:3] forKey:[NSString stringWithFormat:@"3.2-progress"]];
    [chapterSavedData setObject:[NSNumber numberWithInt:0] forKey:[NSString stringWithFormat:@"3.2"]];
    
    _appDelegate.chapters = chapterSavedData;

    [self.appDelegate saveData];
    
    Popup *popup = [[Popup alloc] initFor:@"Info" withDescription:@"Es werden alle Kapitel freigeschaltet." returnBtn:NO menuBtn:NO nextBtn:NO yesBtn:NO noBtn:NO];
    [self.view addSubview:popup];
    
    [self performSelector:@selector(returnToRootVC) withObject:self afterDelay:2];
}


#pragma mark Initialize Help

- (void)contentForHelp
{
    UIButton *generalHelp = [[UIButton alloc] initWithFrame:CGRectMake(262, 260, 500, 60)];
    [generalHelp setTitle:@"Hilfe zur Navigation" forState:UIControlStateNormal];
    [generalHelp setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    generalHelp.titleLabel.font = [UIFont fontWithName:@"Shojumaru-Regular" size:30];
    [generalHelp addTarget:self action:@selector(showHelp:) forControlEvents:UIControlEventTouchUpInside];
    generalHelp.tag = 0;
    [self.view addSubview:generalHelp];

    UIButton *gamesAndTestsHelp = [[UIButton alloc] initWithFrame:CGRectMake(212, 340, 600, 60)];
    [gamesAndTestsHelp setTitle:@"Hilfe zu Übungen und Tests" forState:UIControlStateNormal];
    [gamesAndTestsHelp setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    gamesAndTestsHelp.titleLabel.font = [UIFont fontWithName:@"Shojumaru-Regular" size:30];
    [gamesAndTestsHelp addTarget:self action:@selector(showHelp:) forControlEvents:UIControlEventTouchUpInside];
    gamesAndTestsHelp.tag = 1;
    [self.view addSubview:gamesAndTestsHelp];
}

- (void)showHelp:(UIButton *)sender
{
    self.navigationController.navigationBar.hidden = YES;

    UIButton *button = (UIButton *)sender;
    if (button.tag==0) {
        _helpPart = 1;
        _helpMax = 6;
    }
    else {
        _helpPart = 7;
        _helpMax = 10;
    }
    
    self.helpView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
    [self.helpView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"hilfe_%ld.png", (long)_helpPart]]];

    UITapGestureRecognizer *tapHelp = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(nextHelpscreen:)];
    tapHelp.delegate = (id)self;
    [tapHelp setNumberOfTouchesRequired:1];
    [tapHelp setNumberOfTapsRequired:1];
    [self.helpView setUserInteractionEnabled:YES];
    [self.helpView addGestureRecognizer:tapHelp];
    
    [self.view addSubview:self.helpView];
}

- (void)nextHelpscreen:(UITapGestureRecognizer *)sender
{
    if (_helpPart<_helpMax) {
        _helpPart++;
        [self.helpView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"hilfe_%ld.png", (long)_helpPart]]];
    }
    else {
        self.navigationController.navigationBar.hidden = NO;
        [self.helpView removeFromSuperview];
    }
}

#pragma mark Initialize Info

- (void)contentForInfo
{
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(100, 220, 824, 450)];
    textView.backgroundColor = [UIColor clearColor];
    textView.userInteractionEnabled = NO;
    textView.scrollEnabled = NO;
    textView.editable = NO;
    textView.textAlignment = NSTextAlignmentCenter;
    textView.textColor = [UIColor whiteColor];
    textView.font = [UIFont systemFontOfSize:20];
    textView.text = @"Diese App ist im Fach E-Learning an der Hochschule Ulm\nim Sommersemester 2014 entstanden.\n\nBetreuende Dozentin:\nProf. Susanne P. Radtke\n\nStudierende:\nChristoph Blome, David Lawendel, Sascha Müller,\nMarius Schneider und Leslie Zimmermann";
    [self.view addSubview:textView];
}


#pragma mark Saving Data Methods

- (void)textViewDidChange:(NSNotification *)notification
{
    if (![self.nameField.text isEqualToString:@""] && ![self.nameField.text isEqualToString:@" "]) {
        self.appDelegate.userName = self.nameField.text;
        [self.appDelegate saveData];
    }
    else {
        self.nameField.text = self.appDelegate.userName;
    }
}

#pragma mark Navigation Bar

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

- (void)returnToRootVC
{
    [self.navigationController popToRootViewControllerAnimated:NO];
}


#pragma mark Dismiss Keyboard

-(void)dismissKeyboard {
    [self.nameField resignFirstResponder];
}

#pragma mark Json Data

- (void)getJsonDataForChapterKey:(NSString *)chapterKey
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"vocabulary" ofType:@"json"];
    NSData* data = [NSData dataWithContentsOfFile:filePath];
    NSError* error = nil;
    id json = [NSJSONSerialization JSONObjectWithData:data
                                              options:kNilOptions
                                                error:&error];
    
    if (!json) {
        NSLog(@"no json data received");
    }
    else{
        _selectedGlossarChapter = chapterKey;
        
        NSArray *dataArray = [json objectForKey:chapterKey];
        NSDictionary *tempDict;
        
        [_vocDE removeAllObjects];
        [_vocCN removeAllObjects];
        
        for (int i=0; i<[dataArray count]; i++) {
            tempDict = dataArray[i];
            [_vocDE addObject:[tempDict objectForKey:@"de"]];
            [_vocCN addObject:[tempDict objectForKey:@"cn"]];
        }
        
        NSMutableString *tempStringDE = [[NSMutableString alloc] init];
        NSMutableString *tempStringCN = [[NSMutableString alloc] init];
        [tempStringDE setString:@""];
        [tempStringCN setString:@""];
        
        for (int n=0; n<[_vocDE count]; n++) {
            [tempStringDE appendString:_vocDE[n]];
            if (n<[_vocDE count]-1) [tempStringDE appendString:@"\n\n"];

            [tempStringCN appendString:_vocCN[n]];
            if (n<[_vocDE count]-1) [tempStringCN appendString:@"\n\n"];
        }
        
        [self.wordsDE setText:tempStringDE];
        [self.wordsCN setText:tempStringCN];

        
        CGSize textViewSize = [self.wordsDE sizeThatFits:self.wordsDE.frame.size];
        CGRect frameDE = self.wordsDE.frame;
        CGRect frameCN = self.wordsCN.frame;
        frameDE.size.height = textViewSize.height;
        frameCN.size.height = textViewSize.height;
        self.wordsDE.frame = frameDE;
        self.wordsCN.frame = frameCN;
        
        CGSize tempSize = CGSizeMake(textViewSize.width, textViewSize.height+100);
        self.scrollView.contentSize = tempSize;
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
