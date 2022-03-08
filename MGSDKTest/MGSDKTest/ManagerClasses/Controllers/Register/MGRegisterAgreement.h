//
//  MGLoginAgreement.h
//  MGPlatformDemo
//
//  Created by SunYuan on 14-4-22.
//  Copyright (c) 2014年 Eason. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MGRegisterAgreement : UIView

@property (nonatomic, strong) UIButton* registerButton;
@property (nonatomic, strong) MGCheckBox* protocolCheckbox;
@property (nonatomic, strong) UIButton* agreementButton;
@property (nonatomic, strong) UIButton* privacyButton;
@property (nonatomic, strong) UILabel * newLab;

- (void) resizeForiPhoneLandscape;

- (void) resizeForiPhonePortrait;

- (void) resizeForiPad;

@end
