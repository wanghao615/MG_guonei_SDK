//
//  MGModifySecret.m
//  MGPlatformTest
//
//  Created by caosq on 14-7-2.
//  Copyright (c) 2014年 qmqj. All rights reserved.
//

#import "MGModifyUserSecret.h"
#import "MGModelObj.h"
#import "MGHttpClient.h"
#import "MGScrollView.h"

@interface MGModifyUserSecret ()<UITextFieldDelegate>

@property (nonatomic, strong) MGScrollView *scrollView;

@property (nonatomic, strong) UITextField *tfOld;
@property (nonatomic, strong) UITextField *tfNew;
@property (nonatomic, strong) UITextField *tfNew2;

@property (nonatomic, strong) UIButton *btnSure;

@end

@implementation MGModifyUserSecret


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (TT_IS_IOS7_AND_UP) {
        self.title = @"修改密码";
    }else{
        [self.navigationItem setTitleView:[MGUtility naviTitle:@"修改密码"]];
        [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:[MGUtility newBackItemButtonIos6Target:self action:@selector(back:)]]];
    }
    
    
    _scrollView = [[MGScrollView alloc] initWithFrame:self.view.bounds];
    _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [_scrollView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:_scrollView];
    
    CGFloat x,y,w,h;
    if (I_PHONE) {
        x = 15.0; y=15.0; w = self.view.bounds.size.width-30.0; h = 139.0;
    }else{
        w = 440.0; x = ceilf((self.view.bounds.size.width-w)/2); y=15.0; h = 45.0*4 + 4;
    }
    UIView *cornerView = [MGUtility newRoundCornerView:CGRectMake(x, y, w, h)];
    [self.scrollView addSubview:cornerView];
    
    NSString *account = [[MGManager defaultManager] MGLoginUserAccount];
    y = .0, w = cornerView.bounds.size.width; h = I_PHONE ? 34.0 : 45.0;
    
    CGFloat fontsize = I_PHONE ? 13.0 : 16.0;
    
    UITextField *tfAccount = nil;
    [cornerView addSubview:(tfAccount = [MGUtility newTextField_XLineWithFrame:CGRectMake(0, y + 1.0, w, h) leftTitle:@"修改用户：" andContent:account placeHoder:nil fontSize:fontsize])];
    tfAccount.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    tfAccount.enabled = NO;
    
    y += h+1;
    [cornerView addSubview:(_tfOld = [MGUtility newTextField_XLineWithFrame:CGRectMake(0, y, w, h) leftTitle:@"当前密码：" andContent:nil placeHoder:@"输入当前密码" fontSize:fontsize])];
    _tfOld.secureTextEntry = YES;
    _tfOld.returnKeyType = UIReturnKeyNext;
    _tfOld.delegate = self;
    y += h+1;
    [cornerView addSubview:(_tfNew = [MGUtility newTextField_XLineWithFrame:CGRectMake(0, y, w, h) leftTitle:@"设置密码：" andContent:nil placeHoder:@"6-16位字符组合" fontSize:fontsize])];
    _tfNew.secureTextEntry = YES;
    _tfNew.returnKeyType = UIReturnKeyNext;
    _tfNew.delegate = self;
    y += h+1;
    [cornerView addSubview:(_tfNew2 = [MGUtility newTextFieldWithFrame:CGRectMake(0, y, w, h) leftTitle:@"确认密码：" andContent:nil placeHoder:@"6-16位字符组合" fontSize:fontsize])];
    _tfNew2.delegate = self;
    _tfNew2.secureTextEntry = YES;
    _tfNew2.returnKeyType = UIReturnKeyDone;
    
    
    y = 15.0 + h * 4 + 20.0;
    h = I_PHONE ? 44.0 : 50.0;
    [self.scrollView addSubview:(self.btnSure = [MGUtility newBlueButton:CGRectMake(x, y, w, h) withTitle:@"确定" target:self action:@selector(doModifyAction:)])];
    
    if (I_PAD) {
        cornerView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
        self.btnSure.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
        self.btnSure.titleLabel.font = [UIFont systemFontOfSize:17];
    }else
        cornerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
}

- (void) back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isEqual:self.tfOld]) {
        [self.tfNew becomeFirstResponder];
    }else if ([textField isEqual:self.tfNew]){
        [self.tfNew2 becomeFirstResponder];
    }else if ([textField isEqual:self.tfNew2]){
        [self.view endEditing:YES];
        [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
        
        [self doModifyAction:nil];
        
    }
    return YES;
}

- (BOOL) textFieldShouldBeginEditing:(UITextField *)textField
{
    if (iPhone_L) {
        if ([textField isEqual:self.tfNew]) {
            [self.scrollView setContentOffset:CGPointMake(0, 30) animated:YES];
        }else if ([textField isEqual:self.tfNew2]){
            [self.scrollView setContentOffset:CGPointMake(0, 50) animated:YES];
        }
    }
    return YES;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) doModifyAction:(id)sender
{
    if ([self.tfOld.text length ] == 0) {
        [MGSVProgressHUD showErrorWithStatus:@"当前密码不能输入为空"];
        return;
    }
    
    BOOL bOK = [MGUtility validatePassword:self.tfNew.text andErrorMsg:^(NSString *errorMsg) {
        [MGSVProgressHUD showErrorWithStatus:errorMsg];
    }];
    if (!bOK) return;
    
    if (![_tfNew2.text isEqualToString:_tfNew.text]) {
        [MGSVProgressHUD showErrorWithStatus:@"确认密码输入不一致"];
        return;
    }
    
    [self.view endEditing:YES];
    
    [self performSelector:@selector(doModifyActionX:) withObject:nil afterDelay:0.6];

}


- (void) doModifyActionX:(id)sender
{
    
    MGModifySecret *secretInfo = [[MGModifySecret alloc] init];
//    secretInfo.oldpwd = [MGUtility md5:_tfOld.text];
//    secretInfo.newpwd1 =[MGUtility md5:_tfNew.text];
//    secretInfo.newpwd2 = [MGUtility md5:_tfNew2.text];
    
    secretInfo.oldpwd = _tfOld.text;
    secretInfo.newpwd1 =_tfNew.text;
    secretInfo.newpwd2 = _tfNew2.text;
    secretInfo.uid = [[MGManager defaultManager] MGOpenUID];
    secretInfo.token = [[MGManager defaultManager] MGToken];
    [MGSVProgressHUD showWithStatus:@"正在提交修改" maskType:MGSVProgressHUDMaskTypeClear];
    __weak MGModifyUserSecret *weakself = self;
    [[MGHttpClient shareMGHttpClient] modifySecret:secretInfo completion:^(NSDictionary *responseDic) {
        [MGSVProgressHUD showSuccessWithStatus:@"修改成功,请使用新密码"];

        if (weakself) {
            
            MGAccountSettingInfo *info = [MGStorage currentAccountSettingInfo];
            info.secret = [MGStorage AES256Encrypt:weakself.tfNew2.text];
            [MGStorage saveOneAccountSettingInfo:info];
        }
        [weakself performSelector:@selector(pop:) withObject:nil afterDelay:1.0];
        
    } failed:^(NSInteger ret, NSString *errMsg) {
        
        [MGSVProgressHUD showErrorWithStatus:errMsg];
        
    }];
}

- (void) pop:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
    [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
}


@end
