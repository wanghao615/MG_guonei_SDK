//
//  MGResetPasswordVC.m
//  MGPlatformTest
//
//  Created by wangcl on 14-8-19.
//  Copyright (c) 2014年 qmqj. All rights reserved.
//

#import "MGResetPasswordVC.h"
#import "MGUtility.h"
#import "MGManager.h"
#import "MGHttpClient.h"
#import "NSString+MGString.h"
#import "MGLoginViewController.h"
#import "MGScrollView.h"

@interface MGResetPasswordVC () <UITextFieldDelegate, UIAlertViewDelegate>


@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UILabel *labelUser;
@property (nonatomic, strong) UILabel *labelTip;

@property (nonatomic, strong) UITextField *tfPassword;
@property (nonatomic, strong) UITextField *tfRepeat;

@property (nonatomic, strong) UIButton *buttonSubmit;

@property (nonatomic, strong) MGScrollView *scrollView;

@end

@implementation MGResetPasswordVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSString *title = @"重新设置密码";
    if (TT_IS_IOS7_AND_UP) {
        self.title = title;
    } else {
        [self.navigationItem setTitleView:[MGUtility naviTitle:title]];
        if ([[self.navigationController.viewControllers firstObject] isKindOfClass:[MGLoginViewController class]]) {
            [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:[MGUtility newBackItemButtonIos6Target:self action:@selector(backToLoginVC:)]]];
        }
    }
    [self initUI];
}

- (void)initUI {
    
    
    _scrollView = [[MGScrollView alloc] initWithFrame:self.view.bounds];
    _scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:_scrollView];
    [_scrollView setBackgroundColor:[UIColor clearColor]];
    _scrollView.delaysContentTouches = NO;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    [_scrollView addGestureRecognizer:tap];
    
    
    CGFloat w = 320.0f;
    self.containerView = [[UIScrollView alloc] initWithFrame:CGRectMake(ceilf((self.view.bounds.size.width - w) / 2), 0, w, self.view.bounds.size.height)];
    self.containerView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [self.containerView setBackgroundColor:[UIColor clearColor]];
    [self.scrollView addSubview:self.containerView];
    
    CGFloat x = 15, y = 15;
    UIFont *font1 = I_PAD ? [UIFont systemFontOfSize:20] : [UIFont systemFontOfSize:18];
    self.labelUser = [[UILabel alloc] initWithFrame:CGRectMake(x, y, w - 2 * x, 20)];
    [self.labelUser setFont:font1];
    self.labelUser.text = [NSString stringWithFormat:@"您好，%@", self.account];
    self.labelUser.textColor = [UIColor blackColor];
    self.labelUser.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.labelUser.textAlignment = NSTextAlignmentCenter;
    [self.labelUser setBackgroundColor:[UIColor clearColor]];
    [self.containerView addSubview:self.labelUser];
    
    y += 20 + 15;
    [self newInputView:CGRectMake(15, y, w - 2 * x, 150)];
    
    self.buttonSubmit = [MGUtility newBlueButton:CGRectMake(15, self.tfRepeat.frame.origin.y + self.tfRepeat.frame.size.height + 15, w - 2 * x, 40) withTitle:@"确定" target:self action:@selector(onClickSubmit:)];
    [self.containerView addSubview:self.buttonSubmit];
}

- (void) newInputView:(CGRect) frame
{
    CGFloat x = frame.origin.x;
    CGFloat y = frame.origin.y;
    self.tfPassword = [[UITextField alloc] initWithFrame:CGRectMake(x, y, frame.size.width,  35.0)];
    [_tfPassword setBackground:[[MGUtility MGImageName:@"MG_tf_gray.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(4, 4, 4, 4)]];
    _tfPassword.autocorrectionType = UITextAutocorrectionTypeNo;
    [MGUtility setTextField:_tfPassword leftTitle:@"     重置密码：" leftWidth: I_PAD ? 75.0 : 85.0];
    _tfPassword.font =  I_FONT_13_16;
    _tfPassword.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _tfPassword.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _tfPassword.delegate = self;
    _tfPassword.returnKeyType = UIReturnKeyNext;
    _tfPassword.secureTextEntry = YES;
    _tfPassword.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.containerView addSubview:_tfPassword];
    
    y += 35.0f + 10;
    self.labelTip = [[UILabel alloc] initWithFrame:CGRectMake(x + 20, y, frame.size.width, 16)];
    self.labelTip.font = I_FONT_13_16;
    self.labelTip.text = @"6-12个字符组成，区分大小写";
    [self.labelTip setTextColor:TTHexColor(0xcbcdda)];
    [self.labelTip setBackgroundColor:[UIColor clearColor]];
    [self.containerView addSubview:self.labelTip];
    
    y += 16 + 10;
    self.tfRepeat = [[UITextField alloc] initWithFrame:CGRectMake(x, y, frame.size.width, 35.0)];
    _tfRepeat.secureTextEntry = YES;
    [_tfRepeat setBackground:[[MGUtility MGImageName:@"MG_tf_gray.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(4, 4, 4, 4)]];
    _tfRepeat.font = I_FONT_13_16;
    _tfRepeat.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _tfRepeat.delegate = self;
    _tfRepeat.returnKeyType = UIReturnKeyDone;
    _tfRepeat.secureTextEntry = YES;
    _tfRepeat.clearButtonMode = UITextFieldViewModeWhileEditing;
    [MGUtility setTextField:_tfRepeat leftTitle:@"     确认密码：" leftWidth: I_PAD ? 75.0 : 85.0];
    [self.containerView addSubview:self.tfRepeat];

}

- (void)onClickSubmit:(UIButton *)sender {
    
    
    if (![MGUtility validatePassword:self.tfPassword.text andErrorMsg:^(NSString *errorMsg) {
        [MGSVProgressHUD showErrorWithStatus:errorMsg];
    }]) {
        return;
    }
    
    if (![MGUtility validatePassword:self.tfRepeat.text andErrorMsg:^(NSString *errorMsg) {
        [MGSVProgressHUD showErrorWithStatus:errorMsg];
    }]) {
        return;
    }

    if (![self.tfPassword.text isEqualToString:self.tfRepeat.text]) {
        [MGSVProgressHUD showErrorWithStatus:@"2次输入密码不一致"];
        return;
    }
    
    [self.view endEditing:YES];
    
    __weak typeof(&*self) weakSelf = self;
    NSDictionary *dict = @{@"account": self.account,
                           @"appid": [[MGManager defaultManager] MG_APPID],
                           @"p": [MGUtility md5:self.tfPassword.text],
                           @"t": _token};
    [MGSVProgressHUD showWithStatus:@"正在重置" maskType:MGSVProgressHUDMaskTypeClear];
    [[MGHttpClient shareMGHttpClient] findPasswordWithParams:dict completion:^(NSDictionary *responseDic) {
        TTDEBUGLOG(@"**** %@", responseDic);
        [MGSVProgressHUD dismiss];
        __strong typeof(&*weakSelf) strongSelf = weakSelf;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"重置密码成功，请使用新密码登录" delegate:strongSelf cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        
    } failed:^(NSInteger ret, NSString *errMsg) {
        [MGSVProgressHUD showErrorWithStatus:errMsg];
    }];
    
}

- (void) tapAction:(id)sender
{
    [self touchesBegan:nil withEvent:nil];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
    
    [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self resizeUI];
}

- (void)resizeUI {
    
    if (iPhone_P) {
        self.scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height);
    }else if (iPhone_L){
        self.scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height + 100.0);
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.tfPassword) {
        [self.tfRepeat becomeFirstResponder];
    } else if (textField == self.tfRepeat) {
        [textField resignFirstResponder];
    }
    return YES;
}

- (void) textFieldDidBeginEditing:(UITextField *)textField
{
    if (iPhone_L) {
        
        if ([textField isEqual:self.tfPassword]) {
            [self.scrollView setContentOffset:CGPointMake(0, 20) animated:YES];
        }else if ([textField isEqual:self.tfRepeat]){
            [self.scrollView setContentOffset:CGPointMake(0, 70) animated:YES ];
        }
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    self.tfRepeat.delegate = nil;
    self.tfPassword.delegate = nil;
}

- (void) backToLoginVC:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
