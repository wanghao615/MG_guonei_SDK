//
//  MGLoginAgreement.m
//  MGPlatformDemo
//
//  Created by SunYuan on 14-4-22.
//  Copyright (c) 2014年 Eason. All rights reserved.
//

#import "MGRegisterAgreement.h"
#import "MGConfiguration.h"

@interface MGRegisterAgreement ()
//提示
@property(nonatomic,strong)UILabel *tipLabel;
@end

@implementation MGRegisterAgreement
@synthesize registerButton = _registerButton;
@synthesize agreementButton = _agreementButton;
@synthesize protocolCheckbox = _protocolCheckbox;
@synthesize privacyButton = _privacyButton;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self addSubview:[self registerButton]];
        [self addSubview:[self protocolCheckbox]];
        [self addSubview:[self agreementButton]];
        [self addSubview:[self privacyButton]];
        [self addSubview:self.tipLabel];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(showNewValue:) name:GDListenForAttributeDidChanges object:nil];
    }
    return self;
}

-(void)showNewValue:(NSNotification *)userInfo
{
       
    BOOL showNew = [userInfo.userInfo[@"showPrivacyNew"] boolValue];
    self.newLab.hidden = !showNew;
   
}

- (UILabel *)tipLabel {
    if (_tipLabel == nil) {
        _tipLabel = [[UILabel alloc]initWithFrame:CGRectMake(20.0f, 58.f, 120.f, 40.f)];
        _tipLabel.text = @"为保护您的账号安全，建议保存到相册并绑定手机";
        _tipLabel.textColor = [UIColor redColor];
        _tipLabel.font = I_FONT_13_14;
        _tipLabel.numberOfLines = 0;
    }
    return _tipLabel;
}

- (UIButton*)registerButton
{
    if (!_registerButton) {
        _registerButton = [[UIButton alloc] initWithFrame:CGRectMake(15.0f, 0.f, self.bounds.size.width-15.0*2, 40.f)];
        [_registerButton setTitle:NSLocalizedString(@"提交注册", nil)
                         forState:UIControlStateNormal];
        [_registerButton setBackgroundColor:TTGlobalColor];

        UIImage* strechedImage = [[MGUtility MGImageName:@"MG_login_button_sel.png"] stretchableImageWithLeftCapWidth:5
                                                                                                                      topCapHeight:5];

        [_registerButton setBackgroundImage:strechedImage
                                   forState:UIControlStateNormal];

        _registerButton.titleLabel.font = TTSystemFont(16);
        [_registerButton setTitleColor:TTWhiteColor
                              forState:UIControlStateNormal];
        [_registerButton.layer setCornerRadius:3];
        [_registerButton.layer setMasksToBounds:YES];
    }
    return _registerButton;
}

- (MGCheckBox *)protocolCheckbox
{
    if (!_protocolCheckbox) {
        _protocolCheckbox = [[MGCheckBox alloc] initWithDelegate:self fromCon:fromControllerRegister];
        _protocolCheckbox.frame = CGRectMake(20.0f, 78.f, 120.f, 15.f);
        [_protocolCheckbox setTitle:@"我已经阅读并同意"
                           forState:UIControlStateNormal];
        [_protocolCheckbox setTitleColor:TTBlackColor
                                forState:UIControlStateSelected];
        [_protocolCheckbox.titleLabel setFont:I_FONT_12_14];
        [_protocolCheckbox setChecked:NO];
    }
    return _protocolCheckbox;
}

- (UIButton*)agreementButton
{
    if (!_agreementButton) {
        _agreementButton = [[UIButton alloc] initWithFrame:CGRectMake(136, 78.f, 160, 15)];
       
        [_agreementButton setTitle:[NSString stringWithFormat:@"《注册许可协议》"]
                          forState:UIControlStateNormal];
        [_agreementButton setTitleColor:TTGlobalColor
                               forState:UIControlStateNormal];
        [_agreementButton.titleLabel setFont:I_FONT_12_14];
    }
    return _agreementButton;
}

- (UIButton *)privacyButton {
    if (!_privacyButton) {
        _privacyButton = [[UIButton alloc] initWithFrame:CGRectMake(296, 78.f, 160, 15)];
    
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
        _newLab.textColor = UIColor.whiteColor;
        _newLab.font = [UIFont systemFontOfSize:18];
        _newLab.hidden = ![MGConfiguration shareConfiguration].showPrivacyNew;
        [self addSubview:_newLab];
    }
    return _newLab;
}

- (void) resizeForiPhoneLandscape
{
    CGFloat w = 245.0/2;
    CGFloat x = self.bounds.size.width - w;
    self.registerButton.frame = CGRectMake(x, 0, w, 35.0f);
    CGFloat y = self.bounds.size.height - 15.0f - 5.0f - 35.f;
    
    x = 8.0f;
    self.tipLabel.frame = CGRectMake(x, y, self.bounds.size.width-15.0*2, 20.f);
    y = y + 30.f;
    self.protocolCheckbox.frame = CGRectMake(x, y, 120.0f, 20.0f);
    self.agreementButton.frame = CGRectMake(x + 120.0f, y, 100.0f, 20.0f);
    self.privacyButton.frame = CGRectMake(x + 215.0f, y-10, 120.0f, 40.0f);
    self.newLab.frame = CGRectMake(CGRectGetMaxX(self.privacyButton.frame)-5, y, 30, 20);
    self.newLab.font = [UIFont systemFontOfSize:12];
}

- (void) resizeForiPhonePortrait
{
    self.registerButton.frame = CGRectMake(15.0f, 0.0, self.bounds.size.width-15.0*2, 40.0f);
    self.agreementButton.frame = CGRectMake(136.0, 103.0, 100.0, 15.0);
    self.privacyButton.frame = CGRectMake(306, 103.0, 170.0, 15.0);
    self.protocolCheckbox.frame = CGRectMake(20.0f, 103.0f, 120.0f, 15.0f);
    self.tipLabel.frame = CGRectMake(20.0f, 58.f, self.bounds.size.width-15.0*2, 40.f);
}

- (void) resizeForiPad
{
    self.registerButton.frame = CGRectMake(0, 0, self.bounds.size.width, 50.0);
    self.tipLabel.frame = CGRectMake(10.0f, 60.f, self.bounds.size.width-15.0*2, 15.f);
    self.protocolCheckbox.frame = CGRectMake(10.0, 90.0, 185.0, 24.0f);
    self.agreementButton.frame = CGRectMake(CGRectGetMaxX(self.protocolCheckbox.frame)-5, 90.0, 165.0, 24.0);
    self.privacyButton.frame = CGRectMake(CGRectGetMaxX(self.agreementButton.frame)-10, 75.0, 185.0, 50.0);
    self.newLab.frame = CGRectMake(CGRectGetMaxX(self.privacyButton.frame)+5, 90.0f, 45, 24);

}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
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
