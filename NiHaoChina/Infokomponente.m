//
//  Infokomponente.m
//  NiHaoChina
//
//  Created by Leslie on 12.06.14.
//  Copyright (c) 2014 Leslie Zimmermann. All rights reserved.
//

#import "Infokomponente.h"

@implementation Infokomponente

- (id)init
{
    self = [super initWithFrame:CGRectMake(0, 518, 1024, 250)];
    if (self) {
        [self getJsonData];
        
        self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"infokomp_background.png"]];
        
        self.closeBtn = [[UIButton alloc] initWithFrame:CGRectMake(920, 12, 40, 35)];
        [self.closeBtn setImage:[UIImage imageNamed:@"close.png"] forState:UIControlStateNormal];
        [self.closeBtn setImage:[UIImage imageNamed:@"close.png"] forState:UIControlStateHighlighted];
        [self addSubview:self.closeBtn];

        UILabel *nizhidaoma = [[UILabel alloc] initWithFrame:CGRectMake(288, 20, 464, 50)];
        nizhidaoma.text = @"Nǐ zhī dào ma?";
        nizhidaoma.font = [UIFont fontWithName:@"Shojumaru-Regular" size:40];
        nizhidaoma.textColor = [UIColor colorWithRed:0.25 green:0.1 blue:0.04 alpha:1.0];
        [self addSubview:nizhidaoma];
        
        UITextView *infokompText = [[UITextView alloc] initWithFrame:CGRectMake(285, 67, 500, 125)];
        infokompText.userInteractionEnabled = NO;
        infokompText.scrollEnabled = NO;
        infokompText.editable = NO;
        infokompText.backgroundColor = [UIColor clearColor];
        infokompText.textColor = [UIColor colorWithRed:0.25 green:0.1 blue:0.04 alpha:1.0];
        infokompText.font = [UIFont systemFontOfSize:18];
        infokompText.text = self.infokompText;
        [self addSubview:infokompText];
        
        if (self.infokompURL!=nil && ![self.infokompURL isEqualToString:@""]) {
            UIButton *linkBtn = [[UIButton alloc] initWithFrame:CGRectMake(198, 126, 464, 125)];
            [linkBtn setTitle:@"> mehr Informationen" forState:UIControlStateNormal];
            [linkBtn setTitleColor:[UIColor colorWithRed:0.25 green:0.1 blue:0.04 alpha:1.0] forState:UIControlStateNormal];
            [linkBtn setTitleColor:[UIColor colorWithRed:0.25 green:0.1 blue:0.04 alpha:1.0] forState:UIControlStateHighlighted];
            linkBtn.titleLabel.font = [UIFont fontWithName:@"Shojumaru-Regular" size:20];
            linkBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
            [linkBtn addTarget:self action:@selector(moreInformations:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:linkBtn];
        }
        
        UIImageView *sackView = [[UIImageView alloc] initWithFrame:CGRectMake(38, -35, 260, 260)];
        [sackView setImage:[UIImage imageNamed:@"sack_happy.png"]];
        [self addSubview:sackView];
    }
    return self;
}

- (void)moreInformations:(UIButton *)sender
{
    NSURL *url = [NSURL URLWithString:self.infokompURL];
    [[UIApplication sharedApplication] openURL:url];
}

#pragma mark Json Data

- (void)getJsonData
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"infokomponenten" ofType:@"json"];
    NSData* data = [NSData dataWithContentsOfFile:filePath];
    NSError* error = nil;
    id json = [NSJSONSerialization JSONObjectWithData:data
                                              options:kNilOptions
                                                error:&error];
    
    if (!json) {
        NSLog(@"no json data received");
    }
    else{        
        NSArray *array = [json objectForKey:@"infokomponenten"];
        NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];

        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"]) {
            tempDict = array[0];
            self.infokompText = [tempDict objectForKey:@"fact"];
        }
        else {
            NSUInteger length = [array count]-2;
            tempDict = array[(arc4random()%length)+1];
            
            self.infokompText = [tempDict objectForKey:@"fact"];
            self.infokompURL = [tempDict objectForKey:@"url"];
        }
    }
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
