//
//  MGBaseViewController.h
//  MGPlatformDemo
//
//  Created by Eason on 21/04/2014.
//  Copyright (c) 2014 Eason. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MGBaseViewController : UIViewController

- (float)getStartOriginY;

- (UIInterfaceOrientation)getScreenOrientation;

- (float)getScreenWidth;

- (float)getScreenHeight;

- (int)getDeviceType;

- (void) initializeView; // virtual function


@property (nonatomic, assign) MGAction MGAction;
- (void) dismissself:(UIButton *) btn;

@end
