//
//  MGLoginMenuView.m
//  MGPlatformDemo
//
//  Created by SunYuan on 14-4-24.
//  Copyright (c) 2014年 Eason. All rights reserved.
//

#import "MGLoginMenuView.h"

@implementation MGLoginMenuView
@synthesize forgotButton = _forgotButton;
@synthesize registerButton = _registerButton;
@synthesize rememberPasswordView = _rememberPasswordView;
@synthesize automaticView = _automaticView;
@synthesize loginButton = _loginButton;
@synthesize passwordCheckbox = _passwordCheckbox;
@synthesize autologinCheckbox = _autologinCheckbox;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code

        [self addSubview:[self loginButton]];

//        [self addSubview:[self passwordCheckbox]];
//        [self addSubview:[self autologinCheckbox]];

        [self addSubview:[self forgotButton]];
        [self addSubview:[self registerButton]];
        [self addSubview:[self fastButton]];

    }
    return self;
}

- (MGChooseView *)rememberPasswordView
{
    if (!_rememberPasswordView) {
        _rememberPasswordView = [[MGChooseView alloc] init];
        _rememberPasswordView.frame = CGRectMake(15.f, 0, 100, 17.f);
        _rememberPasswordView.MGChooseLabel.text = @"记住密码";
    }
    return _rememberPasswordView;
}

- (MGChooseView *)automaticView
{
    if (!_automaticView) {
        _automaticView = [[MGChooseView alloc] init];
        _automaticView.frame = CGRectMake(115, 0, 100, 17.f);
        _automaticView.MGChooseLabel.text = @"自动登录";
    }
    return _automaticView;
}

- (MGCheckBox *)autologinCheckbox
{
    if (!_autologinCheckbox) {
        _autologinCheckbox = [[MGCheckBox alloc] initWithDelegate:self fromCon:fromControllerLogin];
        _autologinCheckbox.frame = CGRectMake(230, 0, 100, 17.f);
        [_autologinCheckbox setTitle:@"自动登录"
                            forState:UIControlStateNormal];
        [_autologinCheckbox.titleLabel setFont:TTSystemFont(13)];
        [_autologinCheckbox setChecked:YES];
    }
    return _autologinCheckbox;
}

- (MGCheckBox *)passwordCheckbox
{
    if (!_passwordCheckbox) {
        _passwordCheckbox = [[MGCheckBox alloc] initWithDelegate:self fromCon:fromControllerLogin];
        _passwordCheckbox.frame = CGRectMake(20.f, 0, 100, 17.f);
        [_passwordCheckbox setTitle:@"记住密码"
                           forState:UIControlStateNormal];
        [_passwordCheckbox.titleLabel setFont:TTSystemFont(13)];
        [_passwordCheckbox setChecked:YES];
    }
    return _passwordCheckbox;
}

- (UIButton*)forgotButton
{
    if (!_forgotButton) {
        _forgotButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_forgotButton setTitle:NSLocalizedString(@"忘记密码", nil)
                      forState:UIControlStateNormal];
        
        UIImage* strechedImage = [[MGUtility MGImageName:@"MG_login_button_sel.png"] stretchableImageWithLeftCapWidth:5
                                                                                                         topCapHeight:5];
        
        [_forgotButton setBackgroundImage:strechedImage
                                forState:UIControlStateNormal];
        [_forgotButton setTitleColor:TTWhiteColor
                           forState:UIControlStateNormal];
        
        _forgotButton.titleLabel.font = TTSystemFont(16);
        
        [_forgotButton.layer setCornerRadius:3];
        [_forgotButton.layer setMasksToBounds:YES];
    }
    return _forgotButton;
}

- (UIButton*)loginButton
{
    if (!_loginButton) {

        _loginButton = [[UIButton alloc] initWithFrame:CGRectMake(15, 35.f, self.frame.size.width - 30, 40.f)];
        [_loginButton setTitle:NSLocalizedString(@"登录", nil)
                      forState:UIControlStateNormal];

        UIImage* strechedImage = [[MGUtility MGImageName:@"MG_login_button_sel.png"] stretchableImageWithLeftCapWidth:5
                                                                                                                      topCapHeight:5];

        [_loginButton setBackgroundImage:strechedImage
                                forState:UIControlStateNormal];
        [_loginButton setTitleColor:TTWhiteColor
                           forState:UIControlStateNormal];

        _loginButton.titleLabel.font = TTSystemFont(16);

        [_loginButton.layer setCornerRadius:3];
        [_loginButton.layer setMasksToBounds:YES];
    }
    return _loginButton;
}

- (UIButton *)fastButton {
    if (_fastButton == nil) {
        _fastButton = [[UIButton alloc] initWithFrame:CGRectMake(15, 35.f, self.frame.size.width - 30, 40.f)];
        [_fastButton setTitle:NSLocalizedString(@"一秒注册", nil)
                       forState:UIControlStateNormal];
        
        UIImage* strechedImage = [[MGUtility MGImageName:@"MG_login_button_sel.png"] stretchableImageWithLeftCapWidth:5
                                                                                                         topCapHeight:5];
        
        [_fastButton setBackgroundImage:strechedImage
                                 forState:UIControlStateNormal];
        [_fastButton setTitleColor:TTWhiteColor
                            forState:UIControlStateNormal];
        
        _fastButton.titleLabel.font = TTSystemFont(16);
        
        [_fastButton.layer setCornerRadius:3];
        [_fastButton.layer setMasksToBounds:YES];
    }
    return _fastButton;
}


- (UIButton*)registerButton
{
    if (!_registerButton) {
        _registerButton = [[UIButton alloc] initWithFrame:CGRectMake(15.f, 90.f, self.frame.size.width - 30, 40.f)];
        [_registerButton setTitle:NSLocalizedString(@"手机注册", nil)
                     forState:UIControlStateNormal];
        
        UIImage* strechedImage = [[MGUtility MGImageName:@"MG_login_button_sel.png"] stretchableImageWithLeftCapWidth:5
                                                                                                         topCapHeight:5];
        
        [_registerButton setBackgroundImage:strechedImage
                               forState:UIControlStateNormal];
        [_registerButton setTitleColor:TTWhiteColor
                          forState:UIControlStateNormal];
        
        _registerButton.titleLabel.font = TTSystemFont(16);
        
        [_registerButton.layer setCornerRadius:3];
        [_registerButton.layer setMasksToBounds:YES];
    }
    return _registerButton;
}

- (void) resizeForLandscape
{
    CGFloat x = 10.0;
    CGFloat y = 80.0;
//    self.passwordCheckbox.frame = CGRectMake(x, y, 100, 17.0);
//    self.autologinCheckbox.frame = CGRectMake(165.0, y, 100.0, 17.0);
    self.registerButton.frame = CGRectMake(320.0, 0.0, 100, 33.0);
    self.forgotButton.frame = CGRectMake(320.0, 37.0, 100.0, 33.0);
//    self.loginButton.frame = CGRectMake(330, y, 62.0f, 15.0f);
    
//    self.registerButton.frame = CGRectMake(290.0, 12.0, 122, 30.0);
//    self.forgotButton.frame = CGRectMake(290.0, 48.0, 122.0, 30.0);
    self.loginButton.frame = CGRectMake(250, CGRectGetMaxY(self.forgotButton.frame) + 30, 122.0, 30.0);
    self.fastButton.frame = CGRectMake(50, CGRectGetMaxY(self.forgotButton.frame) + 30, 122.0, 30.0);
}

- (void) resizeForPortrait
{
//    self.autologinCheckbox.frame = CGRectMake(138, 0, 100, 17.f);
//    self.passwordCheckbox.frame = CGRectMake(20.f, 0, 100, 17.f);
    self.forgotButton.frame = CGRectMake(225, 0, 100, 17.f);
    self.loginButton.frame = CGRectMake(15, 35.f, self.frame.size.width - 30, 40.f);
    self.registerButton.frame = CGRectMake(15.0f, 90.0f, self.frame.size.width-30.0, 40.0);
}

- (void) resizeForiPad
{
//    CGFloat x = 22.5, y=0.0;
//    self.passwordCheckbox.frame = CGRectMake(x, y, 167.5, 17.0f);
//    x += 167.5;
//    self.autologinCheckbox.frame = CGRectMake(x, y, 167.5, 17.0f);
//    y += 17.0 + 20.0f;
//    self.loginButton.frame = CGRectMake(0, y, self.frame.size.width, 50.0f);
//    y += 50.0 + 15.0;
//    self.registerButton.frame = CGRectMake(0, y, self.frame.size.width, 50.0f);
    self.registerButton.frame = CGRectMake(337.0, 0.0, 100, 37.0);
    self.forgotButton.frame = CGRectMake(337.0, 52.0, 100.0, 37.0);
    self.loginButton.frame = CGRectMake(250, CGRectGetMaxY(self.forgotButton.frame) + 50, 122.0, 37.0);
    self.fastButton.frame = CGRectMake(50, CGRectGetMaxY(self.forgotButton.frame) + 50, 122.0, 37.0);
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
