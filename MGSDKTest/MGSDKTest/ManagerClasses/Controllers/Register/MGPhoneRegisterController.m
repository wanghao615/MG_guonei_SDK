//
//  MGPhoneRegisterController.m
//  MGPlatformTest
//
//  Created by ZYZ on 17/1/19.
//  Copyright © 2017年 MGzs. All rights reserved.
//

#import "MGPhoneRegisterController.h"
#import "MGRegisterAgreementController.h"
#import "MGModelObj.h"
#import "MGHttpClient.h"
#import "MGUITextField_XLine.h"
#import "MGLoginViewController.h"
#import "MGAlertViewX.h"
#import "MGScrollView.h"
#import "MGRandomView.h"
#import "MGPhoneRegisterAgreement.h"
#import "UIView+MGHandleFrame.h"
#import "MGConfiguration.h"

static int iTick = 60;

@interface MGPhoneRegisterController ()<UITextFieldDelegate>
//账号
@property (nonatomic, strong) UITextField *tfAccount;

//验证码
@property (nonatomic, strong) UITextField *tfVerificationCode;
//获取验证码
@property (nonatomic, strong) UIButton *getVerificationCodeBtn;
//密码
@property (nonatomic, strong) UITextField *tfSecret;
@property (nonatomic, strong) UIView *bgView;

@property (nonatomic, strong) MGPhoneRegisterAgreement* registerAgreement;

@property (nonatomic, strong) MGScrollView *scrollView;


//需要对比的校验码
@property(nonatomic, strong)NSString *resultStr;

//提交注册
@property(nonatomic,strong)UIButton *registerBtn;
@property(nonatomic,strong)UIImageView *loginbcImage;
@end

@implementation MGPhoneRegisterController
{
    NSTimer *timer;
}

- (UIButton *)registerBtn {
    if (_registerBtn == nil) {
        _registerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_registerBtn setTitle:NSLocalizedString(@"提交注册", nil)
                                 forState:UIControlStateNormal];
        UIImage* strechedImage = [[MGUtility MGImageName:@"MG_login_button_sel.png"] stretchableImageWithLeftCapWidth:8 topCapHeight:8];
        
        [_registerBtn setBackgroundImage:strechedImage
                                           forState:UIControlStateNormal];
        
        
        _registerBtn.titleLabel.font = TTSystemFont(16);
        [_registerBtn setTitleColor:TTWhiteColor
                                      forState:UIControlStateNormal];
        [_registerBtn.layer setCornerRadius:3];
        [_registerBtn.layer setMasksToBounds:YES];
        [_registerBtn addTarget:self action:@selector(doRegisterAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _registerBtn;
}

- (UIButton *)getVerificationCodeBtn {
    if (_getVerificationCodeBtn == nil) {
        _getVerificationCodeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_getVerificationCodeBtn setTitle:NSLocalizedString(@"获取验证码", nil)
                         forState:UIControlStateNormal];
        UIImage* strechedImage = [[MGUtility MGImageName:@"MG_login_button_sel.png"] stretchableImageWithLeftCapWidth:8 topCapHeight:8];
        
        [_getVerificationCodeBtn setBackgroundImage:strechedImage
                                           forState:UIControlStateNormal];

        
        _getVerificationCodeBtn.titleLabel.font = TTSystemFont(16);
        [_getVerificationCodeBtn setTitleColor:TTWhiteColor
                              forState:UIControlStateNormal];
        [_getVerificationCodeBtn.layer setCornerRadius:3];
        [_getVerificationCodeBtn.layer setMasksToBounds:YES];
        [_getVerificationCodeBtn addTarget:self action:@selector(getVerificatCode:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _getVerificationCodeBtn;
}


- (instancetype) init
{
    if (self = [super init]) {
        
    }
    return self;
}

- (void)dismissself:(UIButton *)btn {
    //    [super dismissself:btn];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (TT_IS_IOS7_AND_UP) {
        self.title = @"新用户注册";
    }else{
        [self.navigationItem setTitleView:[MGUtility naviTitle:@"新用户注册"]];
        
        if ([[self.navigationController.viewControllers firstObject] isKindOfClass:[MGLoginViewController class]]) {  // 从登录界面过来
            
            [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:[MGUtility newBackItemButtonIos6Target:self action:@selector(backToLoginVC:)]]];
        }
        
    }
    
    [self initUI];
    
}




- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.tfAccount.delegate = self;
    self.tfSecret.delegate = self;
    self.tfVerificationCode.delegate = self;
//    self.tfSecret.delegate = self;
    
    
}



- (void) viewWillDisappear:(BOOL)animated
{
    self.tfAccount.delegate = nil;
    self.tfSecret.delegate = nil;
    self.tfVerificationCode.delegate = nil;
//    self.tfSecret.delegate = nil;
    [self.tfSecret resignFirstResponder];
    [self.tfVerificationCode resignFirstResponder];
    [self.tfAccount resignFirstResponder];
//    [self.tfSecret resignFirstResponder];
    [self.view endEditing:YES];
    
    [self removeNotificationObserver];
    [super viewWillDisappear:animated];
}

- (void)removeNotificationObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}


- (void) dealloc
{
    self.tfAccount.delegate = nil;
//    self.tfSecret.delegate = nil;
}

- (void) backToLoginVC:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


- (void) initUI
{
    
    _scrollView = [[MGScrollView alloc] initWithFrame:self.view.bounds];
    
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    [_scrollView setBackgroundColor:[UIColor whiteColor]];
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.delaysContentTouches = NO;
    [self.view addSubview:_scrollView];
    
    
    self.loginbcImage = [[UIImageView alloc]initWithFrame:_scrollView.bounds];
    if (I_PHONE) {
        self.loginbcImage.image = [MGUtility MGImageName:@"MG_login_bg.png"];
    }else{
        self.loginbcImage.image = [MGUtility MGImageName:@"MG_login_ipad_bg.png"];
    }
    [_scrollView addSubview:self.loginbcImage];
    
    CGFloat w = 320;   // 固定320
    _bgView = [[UIView alloc] initWithFrame:CGRectMake(ceilf((self.view.bounds.size.width-w)/2), 0, w, self.view.bounds.size.height)];
    [self.scrollView addSubview:_bgView];
    
    self.bgView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    
    
    float originY =   15.0f;
    
    [self makeInputViewWithFrame:CGRectMake(15.0f, originY, _bgView.bounds.size.width - 15.0f * 2, 100.0f)];
    
    //    [self.bgView addSubview:[self makeInputViewWithFrame:CGRectMake(15.0f, originY, _bgView.bounds.size.width-15.0f*2, 85.0)]];
    
    originY += 85.0;
    _registerAgreement = [[MGPhoneRegisterAgreement alloc] initWithFrame:CGRectMake(0, originY, _bgView.bounds.size.width, 100.f) fromCon:fromControllerIphoneRegister];
    _registerAgreement.userInteractionEnabled = YES;
   
    [_registerAgreement.agreementButton addTarget:self
                                           action:@selector(agreementButtonClicked:)
                                 forControlEvents:UIControlEventTouchUpInside];
    [_registerAgreement.privacyButton addTarget:self
                                               action:@selector(privacyButtonClicked:)
                                     forControlEvents:UIControlEventTouchUpInside];
    [self.bgView insertSubview:_registerAgreement belowSubview:self.tfAccount];
}

- (void) makeInputViewWithFrame:(CGRect) frame
{
    CGFloat x = frame.origin.x;
    CGFloat y = frame.origin.y;
    _tfAccount = [[UITextField alloc] initWithFrame:CGRectMake(x, y, frame.size.width,  35.0)]; // frame.size.height/2)];
    _tfAccount.placeholder = @"请输入您的手机号";
    [_tfAccount setBackground:[[MGUtility MGImageName:@"MG_tf_gray.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(4, 4, 4, 4)]];
    _tfAccount.autocorrectionType = UITextAutocorrectionTypeNo;
    [MGUtility setTextField:_tfAccount leftTitle:@"     账 号：" leftWidth: I_PAD ? 75.0 : 65.0];
    [self.bgView addSubview:_tfAccount];
    _tfAccount.font =  I_FONT_13_16;
    _tfAccount.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _tfAccount.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _tfAccount.keyboardType = UIKeyboardTypeNumberPad;
    _tfAccount.delegate = self;
    _tfAccount.returnKeyType = UIReturnKeyNext;
    
    self.registerBtn.frame = CGRectMake(CGRectGetMaxX(_tfAccount.frame) + 10, CGRectGetMinY(_tfAccount.frame), 290, 40);
    
    
    [self.bgView addSubview: self.registerBtn];
    
    y += 35 + 15.0;
    
    _tfSecret = [[UITextField alloc] initWithFrame:CGRectMake(x, y, frame.size.width, 35.0)];
    _tfSecret.placeholder = @"6-20位字母和数字的组合";
    _tfSecret.secureTextEntry = YES;
    [_tfSecret setBackground:[[MGUtility MGImageName:@"MG_tf_gray.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(4, 4, 4, 4)]];
    _tfSecret.font = I_FONT_13_16;
    _tfSecret.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _tfSecret.delegate = self;
    _tfSecret.keyboardType = UIKeyboardTypeDefault;
    _tfSecret.returnKeyType = UIReturnKeyDone;
    
    
    [MGUtility setTextField:_tfSecret leftTitle:@"     密 码：" leftWidth: I_PAD ? 75.0 : 65.0];
    [self.bgView addSubview:self.tfSecret];
    
    
    y += 35 + 15.0;
    
    
    _tfVerificationCode = [[UITextField alloc] initWithFrame:CGRectMake(x, y, frame.size.width, 35.0)];
    _tfVerificationCode.placeholder = @"请输入验证码";
//    _tfVerificationCode.secureTextEntry = YES;
    [_tfVerificationCode setBackground:[[MGUtility MGImageName:@"MG_tf_gray.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(4, 4, 4, 4)]];
    _tfVerificationCode.font = I_FONT_13_16;
    _tfVerificationCode.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _tfVerificationCode.delegate = self;
    _tfVerificationCode.returnKeyType = UIReturnKeyDone;
    
    
    [MGUtility setTextField:_tfVerificationCode leftTitle:@"  验证码：" leftWidth: I_PAD ? 75.0 : 65.0];
    [self.bgView addSubview:self.tfVerificationCode];
    
    
    self.getVerificationCodeBtn.frame = CGRectMake(CGRectGetMaxX(_tfVerificationCode.frame) + 10, CGRectGetMinY(_tfVerificationCode.frame), 290, 40);
   
    
    [self.bgView addSubview: self.getVerificationCodeBtn];
    
    
    y += 35 + 15.0;
    
    
//    _tfSecret = [[UITextField alloc] initWithFrame:CGRectMake(x, y, frame.size.width, 35.0)];
//    _tfSecret.placeholder = @"6-16位字符组合";
//    _tfSecret.secureTextEntry = YES;
//    [_tfSecret setBackground:[[MGUtility MGImageName:@"MG_tf_gray.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(4, 4, 4, 4)]];
//    _tfSecret.font = I_FONT_13_16;
//    _tfSecret.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
//    _tfSecret.delegate = self;
//    _tfSecret.returnKeyType = UIReturnKeyDone;
//    
//    
//    [MGUtility setTextField:_tfSecret leftTitle:@"     密 码：" leftWidth: I_PAD ? 75.0 : 65.0];
//    [self.bgView addSubview:self.tfSecret];
    
    
    
    
    
    
    //    return inputView;
}


- (void)agreementButtonClicked:(UIButton*)button
{
    MGRegisterAgreementController* agreementController = [[MGRegisterAgreementController alloc] init];
    agreementController.MGAction = self.MGAction;
    [MGManager defaultManager].Private_URL = @"";
    [self.navigationController pushViewController:agreementController
                                         animated:YES];
}

- (void)privacyButtonClicked:(UIButton*)button
{
    int privacy_version = [MGConfiguration shareConfiguration].privacy_version;
    if (privacy_version>0) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:@(privacy_version) forKey:GDSaveDidPrivacyVersion];
        [userDefaults synchronize];
        [MGConfiguration shareConfiguration].showPrivacyNew = NO;
    }
    
    MGRegisterAgreementController* agreementController = [[MGRegisterAgreementController alloc] init];
    agreementController.MGAction = self.MGAction;
    [MGManager defaultManager].Private_URL = [NSString stringWithFormat:@"https://adapi.mg3721.com/inapi/privacy?appid=%@", [MGManager defaultManager].MG_APPID];
//    [MGManager defaultManager].Private_URL = [NSString stringWithFormat:@"https://dev.mg3721.com/inapi/privacy?appid=%@", [MGManager defaultManager].MG_APPID];
    [self.navigationController pushViewController:agreementController
                                         animated:YES];
}

- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
    [self.view endEditing:YES];
    [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
}

- (void)showAlertViewString:(NSString*)alertString
{
    [UIAlertView showWithTitle:nil
                       message:alertString
             cancelButtonTitle:@"确定"
             otherButtonTitles:nil
                      tapBlock:^(UIAlertView* alertView, NSInteger buttonIndex) {
                          TTDEBUGLOG(@"clicked index %ld", (long)buttonIndex);
                          TTDEBUGLOG(@"");
                      }];
}

- (void)getVerificatCode:(UIButton *)btn {
    if (![MGUtility validatePhoneNumber:self.tfAccount.text andErrorMsg:^(NSString *errorMsg) {
//        [self showAlertViewString:errorMsg];
        MGAlertCustomView *alerView = [[MGAlertCustomView alloc]alerViewWithMessige:errorMsg withType:AlertTypeWithSure];
        __weak typeof(alerView) weakalert = alerView;
        alerView.handler = ^(NSInteger index){
            if (index == 1) {
                [weakalert dissmiss];
            }
        };
        [alerView show];
    
    }]) {
        TTDEBUGLOG(@"手机号错误");
        return;
    }else{
        //如果是发送验证码
        [self doRegistVerificationCode:self.getVerificationCodeBtn];
    }
    
    
}

- (void) doRegisterAction:(id)sender
{
    [self.view endEditing:YES];
    
    if (![MGUtility validatePhoneNumber:self.tfAccount.text andErrorMsg:^(NSString *errorMsg) {
        //        [self showAlertViewString:errorMsg];
        MGAlertCustomView *alerView = [[MGAlertCustomView alloc]alerViewWithMessige:errorMsg withType:AlertTypeWithSure];
        __weak typeof(alerView) weakalert = alerView;
        alerView.handler = ^(NSInteger index){
            if (index == 1) {
                [weakalert dissmiss];
            }
        };
        [alerView show];
    }]) {
        TTDEBUGLOG(@"手机号错误");
        return;
    }
    if (![MGUtility validatePassword:self.tfSecret.text andErrorMsg:^(NSString *errorMsg) {
        //        [self showAlertViewString:errorMsg];
        MGAlertCustomView *alerView = [[MGAlertCustomView alloc]alerViewWithMessige:errorMsg withType:AlertTypeWithSure];
        __weak typeof(alerView) weakalert = alerView;
        alerView.handler = ^(NSInteger index){
            if (index == 1) {
                [weakalert dissmiss];
            }
        };
        [alerView show];
    }]) {
        TTDEBUGLOG(@"密码填入不正确");
        return;
    }
    
    if ([self.tfVerificationCode.text length] == 0) {
        
        //        [self showAlertViewString:@"验证码不能为空"];
        MGAlertCustomView *alerView = [[MGAlertCustomView alloc]alerViewWithMessige:@"验证码不能为空" withType:AlertTypeWithSure];
        __weak typeof(alerView) weakalert = alerView;
        alerView.handler = ^(NSInteger index){
            if (index == 1) {
                [weakalert dissmiss];
            }
        };
        [alerView show];
        
        return;
    }
    
    
    if (![self.registerAgreement.protocolCheckbox checked]) {
        //        [self showAlertViewString:@"请确定已阅读过协议"];
        MGAlertCustomView *alerView = [[MGAlertCustomView alloc]alerViewWithMessige:@"请确定已阅读并同意协议" withType:AlertTypeWithSure];
        __weak typeof(alerView) weakalert = alerView;
        alerView.handler = ^(NSInteger index){
            if (index == 1) {
                [weakalert dissmiss];
            }
        };
        [alerView show];
        return;
    }
    
    [self doRegistNext];
   
}

- (void)doRegistVerificationCode:(UIButton *)sender {
    if (![MGUtility validatePhoneNumber:self.tfAccount.text andErrorMsg:^(NSString *errorMsg) {
        //        [self showAlertViewString:errorMsg];
        MGAlertCustomView *alerView = [[MGAlertCustomView alloc]alerViewWithMessige:errorMsg withType:AlertTypeWithSure];
        __weak typeof(alerView) weakalert = alerView;
        alerView.handler = ^(NSInteger index){
            if (index == 1) {
                [weakalert dissmiss];
            }
        };
        [alerView show];
    }]) {
        TTDEBUGLOG(@"手机号错误");
        return;
    }
    
    
    
    [timer invalidate];
    timer = nil;
    
    
    [sender removeTarget:self action:@selector(doRegistVerificationCode:) forControlEvents:UIControlEventTouchUpInside];
    
    
    __block NSTimer *weaktimer = timer;
    iTick = 60;
    
    [sender setTitle:@"发送中..." forState:UIControlStateNormal];
    
     [sender setBackgroundImage:[[MGUtility MGImageName:@"MG_btn_gray.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(8, 8, 8, 8)] forState:UIControlStateNormal];
    
    MGUserRegister *registerInfo = [[MGUserRegister alloc] init];
    registerInfo.account = self.tfAccount.text;
//    registerInfo.password1 = self.tfSecret.text;
//    registerInfo.password2 = self.tfSecret.text;
    registerInfo.type = @"Phone";
    registerInfo.source = @"MG";
//    registerInfo.code = self.tfVerificationCode.text;  
    
    
    
    __weak MGPhoneRegisterController * weakself = self;
    [[MGHttpClient shareMGHttpClient] getRegister:registerInfo completion:^(NSDictionary *responseDic) {
        
        [sender setTitle:@"60秒后重发" forState:UIControlStateNormal];

        weaktimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(waitingAfterSendCode:) userInfo:nil repeats:YES];
        [weaktimer fire];

        
    } failed:^(NSInteger ret, NSString *errMsg) {
        
        [weakself.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
        
        [sender setTitle:@"获取验证码" forState:UIControlStateNormal];
        [sender addTarget:self action:@selector(doRegistVerificationCode:) forControlEvents:UIControlEventTouchUpInside];
        
       
        
        [sender setBackgroundImage:[[MGUtility MGImageName:@"MG_login_button_sel.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(8, 8, 8, 8)] forState:UIControlStateNormal];
        
        
        [MGSVProgressHUD dismiss];
        if (weakself) {
//           [MGSVProgressHUD showErrorWithStatus:errMsg];
            MGAlertCustomView *alerView = [[MGAlertCustomView alloc]alerViewWithMessige:errMsg withType:AlertTypeWithSure];
            __weak typeof(alerView) weakalert = alerView;
            alerView.handler = ^(NSInteger index){
                if (index == 1) {
                    [weakalert dissmiss];
                }
            };
            [alerView show];
        }
        
    }];
}


- (void) waitingAfterSendCode:(NSTimer *) aTimer
{
    if (iTick == 0) {
        [aTimer invalidate];
        timer = nil;
        [self.getVerificationCodeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
        [self.getVerificationCodeBtn setBackgroundImage:[[MGUtility MGImageName:@"MG_login_button_sel.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(8, 8, 8, 8)] forState:UIControlStateNormal];
        
        [self.getVerificationCodeBtn addTarget:self action:@selector(doRegistVerificationCode:) forControlEvents:UIControlEventTouchUpInside];
        return;
    }
    [self.getVerificationCodeBtn setTitle:[NSString stringWithFormat:@"%d秒后重发", iTick] forState:UIControlStateNormal];
    --iTick;
}

- (void)doRegistNext {
    [MGSVProgressHUD showWithStatus:@"正在注册，请稍后" maskType:MGSVProgressHUDMaskTypeClear];
    
    MGUserRegister *registerInfo = [[MGUserRegister alloc] init];
    registerInfo.account = self.tfAccount.text;
    registerInfo.password1 = self.tfSecret.text;
//    registerInfo.password2 = self.tfSecret.text;
    registerInfo.source = @"MG";
    registerInfo.type = @"Phone";
    registerInfo.code = self.tfVerificationCode.text;
    
    [self userRegistServer:registerInfo];
}

- (void)userRegistServer:(MGUserRegister *)registerInfo {
    __weak MGPhoneRegisterController * weakself = self;
    [[MGHttpClient shareMGHttpClient] phoneRegister:registerInfo completion:^(NSDictionary *responseDic) {
        
        [MGSVProgressHUD dismiss];
        
        NSDictionary *data = responseDic[@"data"];
        if (weakself && data != nil) {
            NSString *uid = [NSString stringWithFormat:@"%@", data[@"uid"]];
            NSString *token = [NSString stringWithFormat:@"%@", data[@"token"]];
            NSString *phonestatus = [NSString stringWithFormat:@"%@", data[@"isbind"]];
            //支付资源id
            //            NSString *resourceid = [NSString stringWithFormat:@"%@", data[@"resource_id"]];
            //
            //            [[MGPlatform defaultPlatform]setMG_RESOURCE_ID:resourceid];
            
            
            MGAccountSettingInfo *info = [MGStorage accountSettingInfoByAccount:weakself.tfAccount.text];
            if (info != nil) {
                info.secret = [MGStorage AES256Encrypt:weakself.tfSecret.text];
                info.uid = uid;
                info.token = token;
                info.phoneStatus = phonestatus;
                info.idCardBindStatus = @"0";
                info.is_adult = @"2";

                [MGStorage setOneAccountSettingInfo:info isCurrentAccount:YES];
                
                
                [weakself performSelector:@selector(registerSuccess) withObject:nil afterDelay:0];
                [weakself performSelector:@selector(sendRegisterNotification:) withObject:@{
                                                                                            kMGPlatformErrorKey: responseDic[@"ret"],
                                                                                            @"status" : data[@"status"],
                                                                                            @"idcard" : @"0",
                                                                                            @"isbind" : data[@"isbind"]                                                     } afterDelay:0];
                [[MGHttpClient shareMGHttpClient].statistics registerStatistics:weakself.tfAccount.text andUserId:data[@"uid"]];
            }
            MG_LOG(@"注册成功：\nuid:%@ \ntoken:%@", uid, token);
            
        }
        
        
        
    } failed:^(NSInteger ret, NSString *errMsg) {
        
        //        [weakself registFailError:errMsg];
        [MGSVProgressHUD dismiss];
        MGAlertCustomView *alerView = [[MGAlertCustomView alloc]alerViewWithMessige:errMsg withType:AlertTypeWithSure];
        __weak typeof(alerView) weakalert = alerView;
        alerView.handler = ^(NSInteger index){
            if (index == 1) {
                [weakalert dissmiss];
            }
        };
        [alerView show];
    }];
}

- (void)registFailError:(NSString *)errMsg {
    [MGSVProgressHUD dismiss];
    
    [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    
    MGAlertViewX *alertView = [[MGAlertViewX alloc] initWithTitle:@"注册失败" message:errMsg callback:nil cancelButtonTitle:nil otherButtonTitles:@"好的", nil];
    if (I_PAD) {
        alertView.width =   850.0/2;
    }
    alertView.alertType = MGAlertTypeRedTitle;
    [alertView show];
    //        [self performSelector:@selector(sendRegisterNotification:) withObject:@{kMGPlatformErrorKey: [NSNumber numberWithInteger:ret], kMGPlatformErrorMsg: errMsg} afterDelay:0];
}


- (void) sendRegisterNotification:(NSDictionary *) userInfo
{
    //    [[NSNotificationCenter defaultCenter] postNotificationName:kMGPlatformRegisterNotification object:nil userInfo:userInfo];
    [[NSNotificationCenter defaultCenter] postNotificationName:kMGPlatformLoginNotification object:nil userInfo:userInfo];
}

- (void)registerSuccess
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kMGPlatformReloadUserInfoNitifaication object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kMGPlatform_Dismiss_Noti object:[NSNumber numberWithInt:MGActionNothing] userInfo:@{@"action": @"ShowGreet"}];
}



#pragma mark-- UITextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isEqual:self.tfSecret]) {
        [self.tfVerificationCode becomeFirstResponder];
    }
    /*
    else if ([textField isEqual:self.tfVerificationCode]){
        [self.tfSecret becomeFirstResponder];
    }
     
    else if ([textField isEqual:self.tfSecret]){
     */
    else if ([textField isEqual:self.tfVerificationCode]){
        [self.view endEditing:YES];
        [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
        
         [self doRegisterAction:nil];
        
    }
    return YES;
}

- (BOOL) textFieldShouldBeginEditing:(UITextField *)textField
{
    if (iPhone_L) {
        if ([textField isEqual:self.tfVerificationCode]) {
            [self.scrollView setContentOffset:CGPointMake(0, 30) animated:YES];
        }
        /*
        else if ([textField isEqual:self.tfSecret]){
            [self.scrollView setContentOffset:CGPointMake(0, 90) animated:YES];
        }
         */
    }
    return YES;
}






- (void) viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    [self resizeUI];
    
}

- (void) resizeUI
{
    if (iPhone_L) {  //iPhone横屏
        
        CGFloat w = 846.0/2, w1 = 578.0/2;
        CGFloat imageW = self.loginbcImage.image.size.width;
        CGFloat imageH = self.loginbcImage.image.size.height;
        [self.loginbcImage setHeight:self.view.frame.size.width * imageH / imageW] ;
        self.bgView.frame = CGRectMake(ceilf((self.view.bounds.size.width -w)/2), 0,w, self.view.bounds.size.height);
        
        CGFloat x = ceilf((self.bgView.bounds.size.width - w1)/2);
        CGFloat y = 15.0f;
        self.tfAccount.frame = CGRectMake(x, y, w1, 35.0f);
        y += 35.0 + 15.0;
        self.tfSecret.frame = CGRectMake(x, y, w1, 35.0f);
        
        y += 35.0 + 15.0;
        self.tfVerificationCode.frame = CGRectMake(x, y, w1 - 132.5, 35.0f);
        self.getVerificationCodeBtn.titleLabel.font = TTSystemFont(16);
        self.getVerificationCodeBtn.frame = CGRectMake(CGRectGetMaxX(self.tfVerificationCode.frame) + 10, CGRectGetMinY(self.tfVerificationCode.frame), 122.5, 35.0f);
        y += 35.0 + 15.0;
        //        self.tfSecret.frame = CGRectMake(x, y, w1, 35.0f);
        self.registerAgreement.frame = CGRectMake(x, y, w, 70.0f);
        [self.registerAgreement resizeForiPhoneLandscape];
         y += 25.0;
        self.registerBtn.frame = CGRectMake(CGRectGetMinX(self.tfAccount.frame) + 10,y+20, w1 - 50, 35.0f);
        
    }else if (iPhone_P){
        
        CGFloat width = 320.0;
        self.bgView.frame = CGRectMake(ceilf((self.view.bounds.size.width - width)/2), 0, width, self.view.bounds.size.height);
        
        CGFloat x = 15.0f;
        CGFloat y = 15.0f;
        CGFloat w = self.bgView.bounds.size.width - 15.0f * 2;
        self.tfAccount.frame = CGRectMake(x, y, w - 80, 35.0);
        self.registerBtn.frame = CGRectMake(CGRectGetMaxX(self.tfAccount.frame) + 10, CGRectGetMinY(self.tfAccount.frame), 70, 35.0f);
        y += 35.0 + 15.0;
        self.tfSecret.frame = CGRectMake(x, y, w - 80, 35.0f);
      
        y += 35.0 + 15.0;
        self.tfVerificationCode.frame = CGRectMake(x, y, w - 80 , 35.0f);
        self.getVerificationCodeBtn.titleLabel.font = TTSystemFont(12);
        self.getVerificationCodeBtn.frame = CGRectMake(CGRectGetMaxX(self.tfVerificationCode.frame) + 10, CGRectGetMinY(self.tfVerificationCode.frame), 70, 35.0f);
        y += 35.0 + 15.0;
        //        self.tfSecret.frame = CGRectMake(x, y, w, 35.0);
        y += 35.0 + 20.0f;
        self.registerAgreement.frame = CGRectMake(0, y, self.bgView.bounds.size.width , 100.0f);
        [self.registerAgreement resizeForiPhonePortrait];
        
    }else if ((iPad_L) || (iPad_P)){
        
        
        CGFloat bgw = 540.0;
        
        CGFloat w = 540.0 - 110;
        CGFloat y = 50;
        
        CGFloat imageW = self.loginbcImage.image.size.width;
        CGFloat imageH = self.loginbcImage.image.size.height;
        [self.loginbcImage setHeight:self.view.frame.size.width * imageH / imageW] ;
        self.bgView.frame = CGRectMake(ceilf((self.view.bounds.size.width - w)/2), 0, w, self.view.bounds.size.height);
        
        CGFloat x = (self.bgView.frame.size.width - w) /2;
        
        self.tfAccount.frame = CGRectMake(x, y, w, 45.0);

        y += 45.0 + 15.0;
        self.tfSecret.frame = CGRectMake(x, y, w, 45.0);
        
        y += 45.0 + 15.0;
        self.tfVerificationCode.frame = CGRectMake(x, y, w - 110, 45.0);
        self.getVerificationCodeBtn.frame = CGRectMake(CGRectGetMaxX(self.tfVerificationCode.frame) + 10, CGRectGetMinY(self.tfVerificationCode.frame), 100, 45.0);
        
        y += 45.0 + 30.0;
        
        self.registerAgreement.frame = CGRectMake(x, y, w, 80.0);
        
        [self.registerAgreement resizeForiPad];
        y += 60.0 ;
        self.registerBtn.frame = CGRectMake((w - 250) /2, y, 250, 45.0);
    }
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
