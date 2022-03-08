//
//  MGPhoneRegisterAgreement.h
//  MGPlatformTest
//
//  Created by ZYZ on 2017/9/4.
//  Copyright © 2017年 MGzs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MGPhoneRegisterAgreement : UIView


@property (nonatomic, strong) MGCheckBox* protocolCheckbox;
@property (nonatomic, strong) UIButton* agreementButton;
@property (nonatomic, strong) UIButton* privacyButton;
@property (nonatomic, strong) UILabel * newLab;
@property (nonatomic, assign) NSUInteger conType;

- (id)initWithFrame:(CGRect)frame fromCon:(NSUInteger )fromCon;

- (void) resizeForiPhoneLandscape;

- (void) resizeForiPhonePortrait;

- (void) resizeForiPad;

@end
