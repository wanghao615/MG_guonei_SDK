//
//  MGRegisterController.m
//  MGPlatformDemo
//
//  Created by Eason on 21/04/2014.
//  Copyright (c) 2014 Eason. All rights reserved.
//

#import "MGRegisterController.h"
#import "MGRegisterAgreement.h"
#import "MGRegisterAgreementController.h"
#import "MGModelObj.h"
#import "MGHttpClient.h"
#import "MGUITextField_XLine.h"
#import "MGLoginViewController.h"
#import "MGAlertViewX.h"
#import "UIView+MGHandleFrame.h"
#import "MGImageSaveTool.h"
#import "MGConfiguration.h"

//NSString* const kMGPlatformRegisterNotification = @"kMGPlatformRegisterNotification";

@interface MGRegisterController ()<UITextFieldDelegate>

@property (nonatomic, strong) UITextField *tfAccount;
@property (nonatomic, strong) UITextField *tfSecret;
@property (nonatomic, strong) UIView *bgView;

@property (nonatomic, strong) UILabel *lbHint;

@property (nonatomic, strong) MGRegisterAgreement* registerAgreement;
@property (nonatomic, strong) UIImageView *loginbcImage;
@end

@implementation MGRegisterController


- (instancetype) init
{
    if (self = [super init]) {

    }
    return self;
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
    [self performSelector:@selector(getAutoAccount) withObject:nil afterDelay:0.250];
}

- (void)getAutoAccount {
    [MGSVProgressHUD show];
    [[MGHttpClient shareMGHttpClient] getAutoAccountWithCompletion:^(NSDictionary *responseDic) {
        [MGSVProgressHUD dismiss];
        self.tfAccount.text = (responseDic[@"data"])[@"username"];
    } failed:^(NSInteger ret, NSString *errMsg) {
        [MGSVProgressHUD showErrorWithStatus:errMsg];
    }];
    //放入空照片询问相机权限
    if ([MGImageSaveTool isCanUsePhotos] == false) {
        [MGImageSaveTool saveImageWithPhotoKit:[UIImage new] completion:^(BOOL success, PHAsset *asset) {
            
        }];
    }
}

- (void) dealloc
{
    self.tfAccount.delegate = nil;
    self.tfSecret.delegate = nil;
}

- (void) backToLoginVC:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dismissself:(UIButton *)btn {
    //    [super dismissself:btn];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) initUI
{
    self.loginbcImage = [[UIImageView alloc]initWithFrame:self.view.bounds];
    if (I_PHONE) {
        self.loginbcImage.image = [MGUtility MGImageName:@"MG_login_bg.png"];
    }else{
        self.loginbcImage.image = [MGUtility MGImageName:@"MG_login_ipad_bg.png"];
    }
    [self.view addSubview:self.loginbcImage];
    CGFloat w = 320;   // 固定320
     _bgView = [[UIView alloc] initWithFrame:CGRectMake(ceilf((self.view.bounds.size.width-w)/2), 0, w, self.view.bounds.size.height)];
    [self.view addSubview:_bgView];
    
    self.bgView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;

    
    
    
    float originY =   15.0f;
    
    [self newInputView:CGRectMake(15.0f, originY, _bgView.bounds.size.width - 15.0f * 2, 100.0f)];
    
//    [self.bgView addSubview:[self newInputView:CGRectMake(15.0f, originY, _bgView.bounds.size.width-15.0f*2, 85.0)]];
    
    originY += 85.0 + 20.0f;
    _registerAgreement = [[MGRegisterAgreement alloc] initWithFrame:CGRectMake(0, originY, _bgView.bounds.size.width, 150.f)];
    _registerAgreement.userInteractionEnabled = YES;
    [_registerAgreement.registerButton addTarget:self
                                          action:@selector(doRegisterAction:)
                                forControlEvents:UIControlEventTouchUpInside];
    
    [_registerAgreement.agreementButton addTarget:self
                                           action:@selector(agreementButtonClicked:)
                                 forControlEvents:UIControlEventTouchUpInside];
    [_registerAgreement.privacyButton addTarget:self
              action:@selector(privacyButtonClicked:)
    forControlEvents:UIControlEventTouchUpInside];
    [self.bgView insertSubview:_registerAgreement belowSubview:self.tfSecret];
    
}

- (void) newInputView:(CGRect) frame
{
    CGFloat x = frame.origin.x;
    CGFloat y = frame.origin.y;
    _tfAccount = [[UITextField alloc] initWithFrame:CGRectMake(x, y, frame.size.width,  35.0)]; // frame.size.height/2)];
    _tfAccount.placeholder = @"6-16位字母或与数字组合";
    [_tfAccount setBackground:[[MGUtility MGImageName:@"MG_tf_gray.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(4, 4, 4, 4)]];
    _tfAccount.autocorrectionType = UITextAutocorrectionTypeNo;
    [MGUtility setTextField:_tfAccount leftTitle:@"     账 号：" leftWidth: I_PAD ? 75.0 : 65.0];
    [self.bgView addSubview:_tfAccount];
    _tfAccount.font =  I_FONT_13_16;
    _tfAccount.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _tfAccount.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _tfAccount.delegate = self;
    [_tfAccount addTarget:self action:@selector(accountInputChanging:) forControlEvents:UIControlEventEditingChanged];
    _tfAccount.returnKeyType = UIReturnKeyNext;
    
    
    _lbHint = [[UILabel alloc] initWithFrame:CGRectMake(32.0, y + 35.0 + 8.0, 270.0, 16)];
    [_lbHint setBackgroundColor:[UIColor clearColor]];
    _lbHint.font =  I_FONT_13_16;
    _lbHint.textColor = [UIColor colorWithRed:252.0/255.0 green:14.0/255.0 blue:28.0/255.0 alpha:1.0];
    [self.bgView addSubview:_lbHint];
    _lbHint.adjustsFontSizeToFitWidth = YES;
    [_lbHint setHidden:YES];
    
    y += 35 + 15.0;
    _tfSecret = [[UITextField alloc] initWithFrame:CGRectMake(x, y, frame.size.width, 35.0)];
    _tfSecret.placeholder = @"6-20位字母和数字的组合";
    [_tfSecret setBackground:[[MGUtility MGImageName:@"MG_tf_gray.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(4, 4, 4, 4)]];
    _tfSecret.font = I_FONT_13_16;
    _tfSecret.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _tfSecret.delegate = self;
    _tfSecret.returnKeyType = UIReturnKeyDone;

    
    [MGUtility setTextField:_tfSecret leftTitle:@"     密 码：" leftWidth: I_PAD ? 75.0 : 65.0];
    [self.bgView addSubview:self.tfSecret];
    
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
//     [MGManager defaultManager].Private_URL = [NSString stringWithFormat:@"https://dev.mg3721.com/inapi/privacy?appid=%@", [MGManager defaultManager].MG_APPID];
    [self.navigationController pushViewController:agreementController
                                         animated:YES];
}

- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
    [self.view endEditing:YES];
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






- (void) doRegisterAction:(id)sender
{
    [self.view endEditing:YES];

   
    if (![MGUtility validateAccount:self.tfAccount.text andErrorMsg:^(NSString *errorMsg) {
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
        TTDEBUGLOG(@"账户错误");
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
    
    
    [MGSVProgressHUD showWithStatus:@"正在注册，请稍后" maskType:MGSVProgressHUDMaskTypeClear];
    
    MGUserRegister *registerInfo = [[MGUserRegister alloc] init];
    registerInfo.account = self.tfAccount.text;
    registerInfo.password1 = self.tfSecret.text;
    registerInfo.password2 = self.tfSecret.text;
    registerInfo.source = @"MG";
    registerInfo.type = @"account";
    
    __weak MGRegisterController * weakself = self;
    [[MGHttpClient shareMGHttpClient] userRegister:registerInfo completion:^(NSDictionary *responseDic) {
        
        [MGSVProgressHUD dismiss];
        
        NSDictionary *data = responseDic[@"data"];
        if (weakself && data != nil) {
            NSString *uid = [NSString stringWithFormat:@"%@", data[@"uid"]];
            NSString *token = [NSString stringWithFormat:@"%@", data[@"token"]];
            
            //支付资源id
//            NSString *resourceid = [NSString stringWithFormat:@"%@", data[@"resource_id"]];
//            
//            [[MGPlatform defaultPlatform]setMG_RESOURCE_ID:resourceid];
            
            MGAccountSettingInfo *info = [MGStorage accountSettingInfoByAccount:weakself.tfAccount.text];
            if (info != nil) {
                info.secret = [MGStorage AES256Encrypt:weakself.tfSecret.text];
                info.uid = uid;
                info.token = token;
                info.phoneStatus = @"0";
                info.idCardBindStatus = @"0";
                info.is_adult = @"2";

                [MGStorage setOneAccountSettingInfo:info isCurrentAccount:YES];
                
                
                [weakself performSelector:@selector(sendRegisterNotification:) withObject:@{
                                                                                            kMGPlatformErrorKey: responseDic[@"ret"],
                                                                                            @"status" : data[@"status"],
                                                                                            @"idcard" : @"0",
                                                                                            @"isbind" : @"0"
                                                                                            } afterDelay:0];
                
                [[MGHttpClient shareMGHttpClient].statistics registerStatistics:weakself.tfAccount.text andUserId:data[@"uid"]];
                
                
            }
            MG_LOG(@"注册成功：\nuid:%@ \ntoken:%@", uid, token);
        }
        
       

//        [weakself performSelector:@selector(registerSuccess) withObject:nil afterDelay:0];
       
        
    } failed:^(NSInteger ret, NSString *errMsg) {
    
        [MGSVProgressHUD dismiss];
        //        if (weakself) {
        //            MGAlertViewX *alertView = [[MGAlertViewX alloc] initWithTitle:@"注册失败" message:errMsg callback:nil cancelButtonTitle:nil otherButtonTitles:@"好的", nil];
        //            if (I_PAD) {
        //                alertView.width =   850.0/2;
        //            }
        //            alertView.alertType = MGAlertTypeRedTitle;
        //            [alertView show];
        //        }
        MGAlertCustomView *alerView = [[MGAlertCustomView alloc]alerViewWithMessige:errMsg withType:AlertTypeWithSure];
        __weak typeof(alerView) weakalert = alerView;
        alerView.handler = ^(NSInteger index){
            if (index == 1) {
                [weakalert dissmiss];
            }
        };
        [alerView show];
        //        [weakself performSelector:@selector(sendRegisterNotification:) withObject:@{kMGPlatformErrorKey: [NSNumber numberWithInteger:ret], kMGPlatformErrorMsg: errMsg} afterDelay:0];
    }];
    
}

#pragma mark 用来监听图片保存到相册的状况




- (void)snapViewUserInfo:(NSDictionary *) userInfo {
    
    
    UIGraphicsBeginImageContextWithOptions(self.navigationController.view.frame.size, NO, [[UIScreen mainScreen] scale]);
    [self.navigationController.view drawViewHierarchyInRect:self.navigationController.view.bounds afterScreenUpdates:YES];
    UIImage *snapshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    //    2.写入相册
    if ([MGImageSaveTool isCanUsePhotos]) {
       
        [MGImageSaveTool saveImageWithPhotoKit:snapshot completion:^(BOOL success, PHAsset *asset) {
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (success) {
                    [MGSVProgressHUD showSuccessWithStatus:@"账号截图保存成功"];
                }else{
                    [MGSVProgressHUD showErrorWithStatus:@"账号截图保存失败"];
                }
            });
            
            __weak typeof(self) weakSelf = self;
           
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
               
                [weakSelf blackAnimate:snapshot userInfo:userInfo];
            });
        }];
    }else{
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"%@相册权限未打开",MGAPPDisplayName] message:@"账号密码保存失败，请及时保存" preferredStyle:(UIAlertControllerStyleAlert)];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            NSURL *appSettings = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            
            if ([[UIApplication sharedApplication]canOpenURL:appSettings]) {
                [[UIApplication sharedApplication] openURL:appSettings options:@{} completionHandler:^(BOOL success) {
                    __weak typeof(self) weakSelf = self;
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [weakSelf blackAnimate:snapshot userInfo:userInfo];
                    });
                }];
            }else{
                [MGSVProgressHUD showErrorWithStatus:@"无法打开设置"];
            }
            
        }];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"不允许" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            __weak typeof(self) weakSelf = self;
            [MGSVProgressHUD showWithStatus:@"登录中..."];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [MGSVProgressHUD dismiss];
                [weakSelf blackAnimate:snapshot userInfo:userInfo];
            });
        }];
        [alertVC addAction:cancel];
        [alertVC addAction:action];
        
        [self presentViewController:alertVC animated:YES completion:nil];
    }
   
    
    
}


- (void)blackAnimate:(UIImage *)image userInfo:(NSDictionary *) userInfo{
    
    //动画完成后发出通知
    [[NSNotificationCenter defaultCenter] postNotificationName:kMGPlatformLoginNotification object:nil userInfo:userInfo];
    
    [self registerSuccess];
    
}

- (void) sendRegisterNotification:(NSDictionary *) userInfo
{
    //截图和截图动画 动画完成后发出通知
    [self snapViewUserInfo:userInfo];
}

- (void)registerSuccess
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kMGPlatformReloadUserInfoNitifaication object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kMGPlatform_Dismiss_Noti object:[NSNumber numberWithInt:MGActionNothing] userInfo:@{@"action": @"ShowGreet"}];
}



#pragma mark-- UITextField Delegate

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isEqual:self.tfAccount]) {
        [self.tfSecret becomeFirstResponder];
    }else if ([textField isEqual:self.tfSecret]){
        [self.view endEditing:YES];
//        [self doRegisterAction:nil];
    }
    return YES;
}

- (void) textFieldDidEndEditing:(UITextField *)textField
{
    if ([textField isEqual:self.tfAccount]) {

    }
}

- (void) accountInputChanging:(UITextField *) tf   //正在输入的过程中不去做验证
{
    [self refreshViewWithMsg:nil];
}



#pragma mark -- Refresh TextField

- (void) refreshViewWithMsg:(NSString *) msg
{
    self.lbHint.text = msg;
    if (!TT_IS_IOS7_AND_UP) {  // ios6 adjustsFontSizeToFitWidth 不管用
        if (iPhone_L) {
            self.lbHint.font = [UIFont systemFontOfSize:[msg length] > 10 ? 11 : 13];
        }else
            self.lbHint.font = [UIFont systemFontOfSize:13];
    }
    
    [self.lbHint setHidden:[msg length] == 0];
    
    if ((iPhone_P) || (iPad_P) || (iPad_L)) {
    
    __weak MGRegisterController *weakself = self;
//    self.lbHint.alpha = 0.0;
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        
        if (!self.lbHint.isHidden) {  // 无错误
            
            CGFloat y = self.tfAccount.frame.size.height + self.tfAccount.frame.origin.y;
            weakself.lbHint.frame = CGRectMake(32.0, y + 8.0, 270.0, 16);
//            weakself.lbHint.alpha = 1.0;
            CGRect frame = self.tfSecret.frame;
            frame.origin.y = y + 33.0;
            weakself.tfSecret.frame = frame;
            
            frame = self.registerAgreement.frame;
            frame.origin.y = self.tfSecret.frame.origin.y + self.tfSecret.frame.size.height + 20.0;
            weakself.registerAgreement.frame = frame;

        }else{
            
            CGFloat y = self.tfAccount.frame.size.height + self.tfAccount.frame.origin.y;
            CGRect frame = self.tfSecret.frame;
            frame.origin.y = y + 15.0;
            weakself.tfSecret.frame = frame;
            
            frame = self.registerAgreement.frame;
            frame.origin.y = self.tfSecret.frame.origin.y + self.tfSecret.frame.size.height + 20.0;
            weakself.registerAgreement.frame = frame;
        }
        
    } completion:nil];
    
    }
}


- (void) viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    [self resizeUI];
    [self refreshViewWithMsg:self.lbHint.text];
}

- (void) resizeUI
{
    if (iPhone_L) {  //iPhone横屏
        
        CGFloat w = 846.0/2, w1 = 578.0/2;
        CGFloat imageW = self.loginbcImage.image.size.width;
        CGFloat imageH = self.loginbcImage.image.size.height;
        [self.loginbcImage setHeight:self.view.frame.size.width * imageH / imageW] ;
        self.bgView.frame = CGRectMake(ceilf((self.view.bounds.size.width -w)/2), 0,w, self.view.bounds.size.height);
        
        CGFloat x = ceilf((self.bgView.bounds.size.width - w)/2);
        CGFloat y = 15.0f;
        self.tfAccount.frame = CGRectMake(x, y, w1, 35.0f);
        self.lbHint.frame = CGRectMake(x + 300.0f, y, 245.0/2, 35.0f);
        self.lbHint.numberOfLines = 0;
        y += 35.0 + 15.0;
        self.tfSecret.frame = CGRectMake(x, y, w1, 35.0f);
        self.registerAgreement.frame = CGRectMake(x, y, w, 100.0f);
        [self.registerAgreement resizeForiPhoneLandscape];
        
    }else if (iPhone_P){
        
        CGFloat width = 320.0;
        self.bgView.frame = CGRectMake(ceilf((self.view.bounds.size.width - width)/2), 0, width, self.view.bounds.size.height);
        
        CGFloat x = 15.0f;
        CGFloat y = 15.0f;
        CGFloat w = self.bgView.bounds.size.width - 15.0f * 2;
        self.tfAccount.frame = CGRectMake(x, y, w, 35.0);
        self.lbHint.frame = CGRectMake(32.0, y + 35.0 + 8.0, 270.0, 16);
        self.lbHint.numberOfLines = 1;
        y += 35.0 + 15.0;
        self.tfSecret.frame = CGRectMake(x, y, w, 35.0);
        y += 35.0 + 20.0f;
        self.registerAgreement.frame = CGRectMake(0, y, self.bgView.bounds.size.width , 150.0f);
        [self.registerAgreement resizeForiPhonePortrait];

    }else if ((iPad_L) || (iPad_P)){
        CGFloat imageW = self.loginbcImage.image.size.width;
        CGFloat imageH = self.loginbcImage.image.size.height;
        [self.loginbcImage setHeight:self.view.frame.size.width * imageH / imageW] ;
        
        CGFloat w = 440.0;
        CGFloat y = 15.0;
        self.bgView.frame = CGRectMake(ceilf((self.view.bounds.size.width - w)/2), 0, w, self.view.bounds.size.height);
        self.tfAccount.frame = CGRectMake(0, y, w, 45.0);
        y += 45.0 + 15.0;
        self.tfSecret.frame = CGRectMake(0, y, w, 45.0);
        y += 45.0 + 20.0;
        self.registerAgreement.frame = CGRectMake(0, y, w, 120.0);
        
        [self.registerAgreement resizeForiPad];
    }
    
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
