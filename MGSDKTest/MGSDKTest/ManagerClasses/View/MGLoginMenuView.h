//
//  MGLoginMenuView.h
//  MGPlatformDemo
//
//  Created by SunYuan on 14-4-24.
//  Copyright (c) 2014年 Eason. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGChooseView.h"

@interface MGLoginMenuView : UIView

@property (nonatomic, strong) MGChooseView* rememberPasswordView;
@property (nonatomic, strong) MGChooseView* automaticView;

@property (nonatomic, strong) MGCheckBox* passwordCheckbox;

@property (nonatomic, strong) MGCheckBox* autologinCheckbox;

@property (nonatomic, strong) UIButton* forgotButton;

@property (nonatomic, strong) UIButton* loginButton;

@property (nonatomic, strong) UIButton* registerButton;

@property (nonatomic,strong) UIButton *fastButton;

- (void) resizeForLandscape;

- (void) resizeForPortrait;

- (void) resizeForiPad;


@end
