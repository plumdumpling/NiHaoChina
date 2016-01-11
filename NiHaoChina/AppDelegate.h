//
//  AppDelegate.h
//  NiHaoChina
//
//  Created by Leslie on 01.06.14.
//  Copyright (c) 2014 Leslie Zimmermann. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) id<UIApplicationDelegate>delegate;
@property (nonatomic, retain) NSString *userName;
@property (nonatomic, retain) NSDictionary *chapters;

- (void)saveData;
- (void)deleteData;

@end
