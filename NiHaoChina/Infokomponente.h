//
//  Infokomponente.h
//  NiHaoChina
//
//  Created by Leslie on 12.06.14.
//  Copyright (c) 2014 Leslie Zimmermann. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Infokomponente : UIView

@property (strong, nonatomic) NSString *infokompText;
@property (strong, nonatomic) NSString *infokompURL;
@property (strong, nonatomic) UIButton *closeBtn;

- (id)init;

@end
