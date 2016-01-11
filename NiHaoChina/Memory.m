//
//  Memory.m
//  NiHaoChina
//
//  Created by Leslie on 18.06.14.
//  Copyright (c) 2014 Leslie Zimmermann. All rights reserved.
//

#import "Memory.h"
#import "ChapterViewController.h"
#import "Cell.h"
#import "CustomButton.h"
#import "Popup.h"

#import "FillInText.h"
#import "MultipleChoice.h"
#import "TrueOrFalse.h"

@interface Memory () {
    NSString *_key;
    NSInteger _cardsRemoved;
    NSInteger _cardCount;
    NSMutableArray *_wordsDE;
    NSMutableArray *_wordsCN;
    BOOL _end;
}

@end

@implementation Memory

- (id)initWithKey:(NSString *)key
{
    self = [super init];
    if (self) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Memory" bundle:nil];
        self = [sb instantiateViewControllerWithIdentifier:@"MemoryVC"];
        self.automaticallyAdjustsScrollViewInsets = NO;
        
        _key = key;
        
        if ([_key isEqualToString:@"1.3"]) _cardCount=12;
        else _cardCount=18;

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
    
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:nil];
    self.audioPlayer.numberOfLoops = 0;

    [self customInit];
}


- (void)customInit
{
    self.collectionView.backgroundColor =  [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
    [self initNavigationBarItemsWithBack:YES];
    
    self.dataArray = [[NSMutableArray alloc] init];
    
    [self getJsonDataForDialogueKey:_key];
    
    [self createShuffledArray];
}

- (void)createShuffledArray
{
    self.dataArray = [[NSMutableArray alloc] init];
    
    NSMutableArray *found = [[NSMutableArray alloc] init];
    
    while ([self.dataArray count]<_cardCount) {
        int randomnum = arc4random_uniform([_wordsDE count]-1) +1;
        BOOL objectAlreadyExists = NO;
        
        for (int i=0; i<[found count]; i++) {
            if ([[found objectAtIndex:i] integerValue] == randomnum) {
                objectAlreadyExists = YES;
            }
        }
        
        [found addObject:[NSNumber numberWithInt:randomnum]];
        
        if (!objectAlreadyExists) {
            NSDictionary *dictA = [[NSDictionary alloc] initWithObjects:@[[_wordsDE objectAtIndex:randomnum],[NSNumber numberWithInt:randomnum]] forKeys:@[@"value",@"pairNum"]];
            NSDictionary *dictB = [[NSDictionary alloc] initWithObjects:@[[_wordsCN objectAtIndex:randomnum],[NSNumber numberWithInt:randomnum]] forKeys:@[@"value",@"pairNum"]];
            [self.dataArray addObject:dictA];
            [self.dataArray addObject:dictB];
        }
    }
    
    [self shuffle:self.dataArray];
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
        Popup *popup = [[Popup alloc] initFor:@"Info" withDescription:@"Bist du sicher, dass du diese Übung abbrechen möchtest?" returnBtn:NO menuBtn:NO nextBtn:NO yesBtn:YES noBtn:YES];
        [popup.yesBtn addTarget:self action:@selector(returnToMenu:) forControlEvents:UIControlEventTouchUpInside];
        [popup.noBtn addTarget:self action:@selector(closePopup:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:popup];
    }
}

#pragma mark Shuffle and Flip Methods

- (void)shuffle:(NSMutableArray*)array
{
    NSUInteger count = [array count];
    for (NSUInteger i=0; i<count; ++i) {
        NSInteger n = arc4random_uniform(count-i)+i;
        [array exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
}

- (void)flippedCardOfPair:(NSInteger)pair andIndex:(NSInteger)index
{
    if (self.cardFlipped && self.flippedIndex!=index) {
        NSArray *allCells = [[self collectionView] visibleCells];
        for (int i=[allCells count]-1; i>=0; i--) {
            Cell *aCell = allCells[i];
            aCell.stopFlipping = YES;
        }
        
        if (self.flippedPair == pair) {
            for (int i=[allCells count]-1; i>=0; i--) {
                Cell *aCell = allCells[i];
                if (aCell.flipped) {
                    [aCell performSelector:@selector(removeCards) withObject:nil afterDelay:2];
                    [self.audioPlayer play];
                    _cardsRemoved++;
                    if (_cardsRemoved>=_cardCount) {
                        [self performSelector:@selector(endOfMemory) withObject:nil afterDelay:2];
                    }
                }
                [aCell performSelector:@selector(allFlippedBack) withObject:nil afterDelay:2];
            }
        }
        else {
            for (int i=[allCells count]-1; i>=0; i--) {
                Cell *aCell = allCells[i];
                if (aCell.flipped) {
                    [aCell performSelector:@selector(flipBack) withObject:nil afterDelay:2];
                }
                [aCell performSelector:@selector(allFlippedBack) withObject:nil afterDelay:2];
            }
        }
        self.cardFlipped = NO;
    }
    else if (self.flippedIndex!=index) {
        self.cardFlipped = YES;
        self.flippedPair = pair;
        self.flippedIndex = index;
    }
}

#pragma mark Delegate Methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    Cell *cardCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"myCell" forIndexPath:indexPath];
    NSDictionary *dataDict = self.dataArray[indexPath.row];
    cardCell.cardLabel.text = [dataDict objectForKey:@"value"];
    cardCell.parentViewController = self;
    cardCell.tag = indexPath.row;
    cardCell.pairNum = [[dataDict objectForKey:@"pairNum"] intValue];
    [cardCell.cardLabel removeFromSuperview];
    
    return cardCell;
}


#pragma mark Popup

- (void)endOfMemory
{
    _end = YES;
    
    Popup *popup = [[Popup alloc] initFor:@"Game" withDescription:@"Sehr gut! Du hast die Übung abgeschlossen. Wenn du dich noch nicht sicher genug fühlst, um mit dem Test fortzufahren, kannst du diese Übung jederzeit wiederholen, oder dir den ersten Lernabschnitt nochmal anschauen." returnBtn:NO menuBtn:YES nextBtn:YES yesBtn:NO noBtn:NO];
    [popup.menuBtn addTarget:self action:@selector(returnToMenu:) forControlEvents:UIControlEventTouchUpInside];
    [popup.nextBtn addTarget:self action:@selector(loadTest:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:popup];

    [self saveData];
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

- (void)getJsonDataForDialogueKey:(NSString *)key
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"memory" ofType:@"json"];
    NSData* data = [NSData dataWithContentsOfFile:filePath];
    NSError* error = nil;
    id json = [NSJSONSerialization JSONObjectWithData:data
                                              options:kNilOptions
                                                error:&error];
    
    if (!json) {
        NSLog(@"no json data received");
    }
    else{
        NSArray *array = [json objectForKey:key];
        NSDictionary *tempDict = [[NSDictionary alloc] init];
        
        _wordsCN = [[NSMutableArray alloc] init];
        _wordsDE = [[NSMutableArray alloc] init];
        
        for (int i=0; i<[array count]; i++) {
            tempDict = array[i];
            [_wordsDE addObject:[tempDict objectForKey:@"de"]];
            [_wordsCN addObject:[tempDict objectForKey:@"cn"]];
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

@end
