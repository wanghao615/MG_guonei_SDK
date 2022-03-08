//
//  MGPhoneRegisterAgreement.m
//  MGPlatformTest
//
//  Created by ZYZ on 2017/9/4.
//  Copyright © 2017年 MGzs. All rights reserved.
//

#import "MGPhoneRegisterAgreement.h"
#import "MGConfiguration.h"

@interface MGPhoneRegisterAgreement  ()

@end

@implementation MGPhoneRegisterAgreement


@synthesize agreementButton = _agreementButton;
@synthesize protocolCheckbox = _protocolCheckbox;
@synthesize privacyButton = _privacyButton;

- (id)initWithFrame:(CGRect)frame fromCon:(NSUInteger )fromCon
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _conType = fromCon;
        [self addSubview:[self protocolCheckbox]];
        [self addSubview:[self agreementButton]];
        [self addSubview:[self privacyButton]];
//        [[MGConfiguration shareConfiguration] addObserver:self forKeyPath:@"showPrivacyNew" options:NSKeyValueObservingOptionNew context:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(showNewValue:) name:GDListenForAttributeDidChanges object:nil];
    }
    return self;
}

-(void)showNewValue:(NSNotification *)userInfo
{
       
    BOOL showNew = [userInfo.userInfo[@"showPrivacyNew"] boolValue];
    self.newLab.hidden = !showNew;
   
}




- (MGCheckBox *)protocolCheckbox
{
    if (!_protocolCheckbox) {
        _protocolCheckbox = [[MGCheckBox alloc] initWithDelegate:self fromCon:self.conType];
        _protocolCheckbox.frame = CGRectMake(0.0f, 58.f, 200.f, 15.f);
        if (self.conType==fromControllerLogin) {
            [_protocolCheckbox setTitle:@"登录即代表同意"
                               forState:UIControlStateNormal];
            [_protocolCheckbox setChecked:YES];
            [_protocolCheckbox.titleLabel setFont:I_FONT_12_14];
           
        }else{
            [_protocolCheckbox setTitle:@"我已经阅读并同意"
                               forState:UIControlStateNormal];
            [_protocolCheckbox setChecked:NO];
            [_protocolCheckbox.titleLabel setFont:I_FONT_12_14];
        }
        [_protocolCheckbox setTitleColor:TTBlackColor
                                forState:UIControlStateSelected];
       
       
    }
    return _protocolCheckbox;
}

- (UIButton*)agreementButton
{
    if (!_agreementButton) {
        _agreementButton = [[UIButton alloc] initWithFrame:CGRectMake(136, 58.f, 160, 15)];
       
        [_agreementButton setTitle:[NSString stringWithFormat:@"《注册许可协议》"]
                          forState:UIControlStateNormal];
        [_agreementButton setTitleColor:TTGlobalColor
                               forState:UIControlStateNormal];
        [_agreementButton.titleLabel setFont:I_FONT_12_14];
    }
    return _agreementButton;
}

- (UIButton*)privacyButton
{
    if (!_privacyButton) {
        _privacyButton = [UIButton buttonWithType:UIButtonTypeCustom];
       
        [_privacyButton setTitle:[NSString stringWithFormat:@"《隐私保护协议&\n儿童隐私保护协议》"]
                          forState:UIControlStateNormal];
        [_privacyButton setTitleColor:TTGlobalColor
                               forState:UIControlStateNormal];
        _privacyButton.titleLabel.numberOfLines = 2;
        _privacyButton.titleLabel.textAlignment = NSTextAlignmentLeft;
        [_privacyButton.titleLabel setFont:I_FONT_12_14];
    }
    return _privacyButton;
}

- (UILabel *)newLab{
    if (!_newLab) {
        _newLab = [[UILabel alloc]init];
        _newLab.backgroundColor = UIColor.redColor;
        _newLab.layer.cornerRadius = 4;
        _newLab.layer.masksToBounds = YES;
        _newLab.textAlignment = NSTextAlignmentCenter;
        _newLab.text = @"New";
        _newLab.hidden = ![MGConfiguration shareConfiguration].showPrivacyNew;
        _newLab.textColor = UIColor.whiteColor;
        _newLab.font = [UIFont systemFontOfSize:18];
        [self addSubview:_newLab];
    }
    return _newLab;
}

- (void) resizeForiPhoneLandscape
{
    CGFloat w = 245.0/2;
    CGFloat x = self.bounds.size.width - w;
    
    
    x = 8.0f;
    
    if (self.conType==fromControllerLogin) {
        self.protocolCheckbox.frame = CGRectMake(-20.f, 10, 110.0f, 20.0f);
       
    }else{
        self.protocolCheckbox.frame = CGRectMake(0.0f, 10, 135.0f, 20.0f);
    }
//    self.protocolCheckbox.frame = CGRectMake(x, 0, 170.0f, 15.0f);
    self.agreementButton.frame = CGRectMake(CGRectGetMaxX(self.protocolCheckbox.frame)-10, 10, 100.0f, 20.0f);
    self.privacyButton.frame = CGRectMake(CGRectGetMaxX(self.agreementButton.frame), -2, 120.0f, 40.0f);
    self.newLab.frame = CGRectMake(CGRectGetMaxX(self.privacyButton.frame)-5, 10, 30, 20);
    self.newLab.font = [UIFont systemFontOfSize:12];
}

- (void) resizeForiPhonePortrait
{
    self.protocolCheckbox.frame = CGRectMake(20.0f, 0.0, 110.0f, 15.0f);
    self.agreementButton.frame = CGRectMake(CGRectGetMaxX(self.protocolCheckbox.frame), 0.0, 100.0, 15.0);
    self.privacyButton.frame = CGRectMake(CGRectGetMaxX(self.agreementButton.frame), 0.0, 100.0, 15.0);
    
}

- (void) resizeForiPad
{
    if (self.conType==fromControllerLogin) {
        self.protocolCheckbox.frame = CGRectMake(0.0f, 20, 170.0f, 20.0f);
    }else{
        self.protocolCheckbox.frame = CGRectMake(0.0f, 20, 185.0f, 20.0f);
    }
    self.agreementButton.frame = CGRectMake(CGRectGetMaxX(self.protocolCheckbox.frame)-10, 20, 175.0f, 20.0f);
    
    self.privacyButton.frame = CGRectMake(CGRectGetMaxX(self.agreementButton.frame)-10, 5, 185.0, 50.0);
    self.newLab.frame = CGRectMake(CGRectGetMaxX(self.privacyButton.frame)+5, 20, 45, 24);
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end
