//
//  Popup.m
//  NiHaoChina
//
//  Created by Leslie on 14.06.14.
//  Copyright (c) 2014 Leslie Zimmermann. All rights reserved.
//

#import "Popup.h"

@implementation Popup

- (id)initFor:(NSString *)type withDescription:(NSString *)description returnBtn:(BOOL)returnBtn menuBtn:(BOOL)menuBtn nextBtn:(BOOL)nextBtn yesBtn:(BOOL)yesBtn noBtn:(BOOL)noBtn
{
    self = [super initWithFrame:CGRectMake(262, 150, 500, 250)];
    if (self) {
        self.appDelegate = [[UIApplication sharedApplication] delegate];
        
        self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"popup_background.png"]];
        
        if (![type isEqualToString:@"AppLaunch"] && ![type isEqualToString:@"Info"]) {
            NSString *fileName = @"fanfare";
            NSString *soundFilePath = [NSString stringWithFormat:@"%@/%@.mp3", [[NSBundle mainBundle] resourcePath], fileName];
            NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
            
            self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:nil];
            self.audioPlayer.numberOfLoops = 0;
            [self.audioPlayer play];
        }
        
        if (returnBtn) {
            self.returnBtn = [[UIButton alloc] initWithFrame:CGRectMake(150, 215, 60, 60)];
            [self.returnBtn setImage:[UIImage imageNamed:@"btnReload.png"] forState:UIControlStateNormal];
            [self.returnBtn setImage:[UIImage imageNamed:@"btnReload.png"] forState:UIControlStateHighlighted];
            [self addSubview:self.returnBtn];
        }
        if (menuBtn) {
            self.menuBtn = [[UIButton alloc] initWithFrame:CGRectMake(227, 215, 60, 60)];
            [self.menuBtn setImage:[UIImage imageNamed:@"btnMenu.png"] forState:UIControlStateNormal];
            [self.menuBtn setImage:[UIImage imageNamed:@"btnMenu.png"] forState:UIControlStateHighlighted];
            [self addSubview:self.menuBtn];
        }
        if (nextBtn) {
            self.nextBtn = [[UIButton alloc] initWithFrame:CGRectMake(304, 215, 60, 60)];
            [self.nextBtn setImage:[UIImage imageNamed:@"btnNext.png"] forState:UIControlStateNormal];
            [self.nextBtn setImage:[UIImage imageNamed:@"btnNext.png"] forState:UIControlStateHighlighted];
            [self addSubview:self.nextBtn];
        }
        if (yesBtn) {
            self.yesBtn = [[UIButton alloc] initWithFrame:CGRectMake(188, 215, 60, 60)];
            [self.yesBtn setImage:[UIImage imageNamed:@"btnYes.png"] forState:UIControlStateNormal];
            [self.yesBtn setImage:[UIImage imageNamed:@"btnYes.png"] forState:UIControlStateHighlighted];
            [self addSubview:self.yesBtn];
        }
        if (noBtn) {
            self.noBtn = [[UIButton alloc] initWithFrame:CGRectMake(266, 215, 60, 60)];
            [self.noBtn setImage:[UIImage imageNamed:@"btnNo.png"] forState:UIControlStateNormal];
            [self.noBtn setImage:[UIImage imageNamed:@"btnNo.png"] forState:UIControlStateHighlighted];
            [self addSubview:self.noBtn];
        }
        
        if ([type isEqualToString:@"AppLaunch"]) {
            self.nameField = [[UITextField alloc] initWithFrame:CGRectMake(110, 130, 280, 40)];
            self.nameField.autocorrectionType = UITextAutocorrectionTypeNo;
            self.nameField.textAlignment = NSTextAlignmentLeft;
            self.nameField.userInteractionEnabled = YES;
            self.nameField.enabled = YES;
            self.nameField.enablesReturnKeyAutomatically = NO;
            self.nameField.clearsOnBeginEditing = NO;
            self.nameField.borderStyle = UITextBorderStyleRoundedRect;
            self.nameField.keyboardType = UIKeyboardTypeDefault;
            self.nameField.delegate = (id)self;
            self.nameField.font = [UIFont systemFontOfSize:20];
            [self addSubview:self.nameField];
            
            [self.yesBtn setFrame:CGRectMake(227, 215, 60, 60)];
        }
        else if ([type isEqualToString:@"sack_sad.png"] || [type isEqualToString:@"sack_normal.png"] || [type isEqualToString:@"sack_happy.png"]) {
            UIImageView *sackView = [[UIImageView alloc] initWithFrame:CGRectMake(-150, 20, 260, 260)];
            [sackView setImage:[UIImage imageNamed:type]];
            [self addSubview:sackView];
        }
        
        UITextView *descriptionText = [[UITextView alloc] initWithFrame:CGRectMake(60, 30, 380, 200)];
        descriptionText.userInteractionEnabled = NO;
        descriptionText.scrollEnabled = NO;
        descriptionText.editable = NO;
        descriptionText.backgroundColor = [UIColor clearColor];
        descriptionText.textColor = [UIColor colorWithRed:0.25 green:0.1 blue:0.04 alpha:1.0];
        descriptionText.font = [UIFont systemFontOfSize:20];
        descriptionText.textAlignment = NSTextAlignmentCenter;
        
        if ([description rangeOfString:@"NAME"].location == NSNotFound) {
            descriptionText.text = description;
        }
        else {
            if (self.appDelegate.userName!=nil && ![self.appDelegate.userName isEqualToString:@""]) {
                descriptionText.text = [description stringByReplacingOccurrencesOfString:@"NAME" withString:[NSString stringWithFormat:@"%@",self.appDelegate.userName]];
            }
            else {
                descriptionText.text = [description stringByReplacingOccurrencesOfString:@"NAME" withString:@""];
            }
        }

        [self addSubview:descriptionText];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
