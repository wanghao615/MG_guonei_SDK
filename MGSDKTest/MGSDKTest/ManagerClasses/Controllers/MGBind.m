//
//  MGBindPhone.m
//  MGPlatformTest
//
//  Created by caosq on 14-7-3.
//  Copyright (c) 2014年 qmqj. All rights reserved.
//

#import "MGBind.h"
#import "MGHttpClient.h"
#import "MGPullDown.h"
#import "MGScrollView.h"
#import "MGAlertViewX.h"
#import "MGWebViewController.h"
#import "MGResetPasswordVC.h"
#import "UIView+MGHandleFrame.h"
@interface MGBind ()<UITextFieldDelegate,UIScrollViewDelegate>
{
    MGBindType _bindType;
 
    //新密码
    UITextField *_tf_new_pwd;
    
    MGScrollView *scrollView;
    
    UITextField *_tf_current;
    
    NSTimer *timer;
    
    
}

@property (nonatomic, strong) UITextField *tfPhone;
@property (nonatomic, strong) UITextField *tfVcode;
@property (nonatomic, strong) UIButton *btnVcode;
@property (nonatomic, strong) UIButton *btnDoBind;

@property (nonatomic, strong) UIButton *btnBindQ;

@property (nonatomic, strong) MGPullDown *pullDown;

//新的密码框
@property (nonatomic, strong) UITextField *tfNewPassword;
@property (nonatomic, strong) UIImageView *loginbcImage;
@end

@implementation MGBind


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (instancetype) initWithBindType:(MGBindType)bindType
{
    if (self = [super init]) {
        _bindType = bindType;
    }
    return self;
}

- (void) sendDelegate
{
    if (_delegate && [_delegate respondsToSelector:@selector(MGBind:bNeedReloadUserInfos:)]) {
        [_delegate MGBind:self bNeedReloadUserInfos:YES];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *title = [self titleForBindType:_bindType];
    
    if (TT_IS_IOS7_AND_UP) {
        self.title = title;
    }else{
        [self.navigationItem setTitleView:[MGUtility naviTitle:title]];
        [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:[MGUtility newBackItemButtonIos6Target:self action:@selector(back:)]]];
    }
    
    
}

- (NSString *)titleForBindType:(MGBindType)bindType {
    NSString *title = @"绑定手机";
    switch (bindType) {
        case MGBindTypePhone:
            title = @"绑定手机";
            break;
        case MGFindTypePhone:
            title = @"手机找回";
            break;
       
        default:
            break;
    }
    return title;
}

- (void) back:(id)sender
{
    [self.view endEditing:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dismissself:(UIButton *)btn {
    
    if (_bindType == MGFindTypePhone) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [super dismissself:btn];
    }
    
}

- (void) initializeView
{
    if (_bindType == MGBindTypePhone || _bindType == MGFindTypePhone) {
        [self initializeViewForBindPhone];
    }
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (_bindType == MGBindTypePhone && [self.tfPhone.text length] == 0) {
        
        [self.tfPhone becomeFirstResponder];
        
    }
}

-(void) viewWillDisappear:(BOOL)animated
{
    [self.view endEditing:YES];
    [super viewWillDisappear:animated];
}

- (void) viewDidDisappear:(BOOL)animated
{
    [timer invalidate];
    timer = nil;
    [super viewDidDisappear:animated];
}


#pragma mark-- BindPhone

- (void) initializeViewForBindPhone
{
    
    
    scrollView = [[MGScrollView alloc] initWithFrame:self.view.bounds];
    
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    [scrollView setBackgroundColor:[UIColor whiteColor]];
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.delaysContentTouches = NO;
    scrollView.delegate = self;
    [self.view addSubview:scrollView];
    
    
    self.loginbcImage = [[UIImageView alloc]initWithFrame:self.view.bounds];
    if (I_PHONE) {
        self.loginbcImage.image = [MGUtility MGImageName:@"MG_login_bg.png"];
    }else{
        self.loginbcImage.image = [MGUtility MGImageName:@"MG_login_ipad_bg.png"];
    }
    [scrollView addSubview:self.loginbcImage];

    
    CGFloat x, h, w;
    CGFloat y = 15.0;
    if (I_PHONE) {
        x = 15.0; h = 35.0; w = self.view.bounds.size.width-30.0;
    }else{
        w = 440.0; x = ceilf((self.view.bounds.size.width - w)/2); h = 45.0;
    }
    _tfPhone = [[UITextField alloc] initWithFrame:CGRectMake(x, y, w, h)];
    _tfPhone.placeholder = @"请输入您的手机号";
    [_tfPhone setBackground:[[MGUtility MGImageName:@"MG_tf_blue.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(4, 4, 4, 4)]];
    [scrollView addSubview:_tfPhone];
    
    
    CGFloat left_w = I_PHONE ? 82.0 : 100.0;
    
    _tfPhone.keyboardType = UIKeyboardTypeNumberPad;
    _tfPhone.leftView = [self newLeftViewWithTitle:@"绑定手机" width: left_w];
    _tfPhone.leftViewMode = UITextFieldViewModeAlways;
    _tfPhone.delegate = self;
    
    if (_phone.length > 0) {
        _tfPhone.text = _phone;
    }
    
    y += h + 15.0;
    h = I_PHONE ? 44.0 : 50.0;
    _btnVcode = [UIButton buttonWithType:UIButtonTypeCustom];
   
    UIImage* strechedImage = [[MGUtility MGImageName:@"MG_login_button_sel.png"] stretchableImageWithLeftCapWidth:8 topCapHeight:8];
    
    [_btnVcode setBackgroundImage:strechedImage
                         forState:UIControlStateNormal];
    
    _btnVcode.frame = CGRectMake(x, y, w, h);
    [_btnVcode setTitle:@"获取验证码" forState:UIControlStateNormal];
    [_btnVcode setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _btnVcode.titleLabel.font = [UIFont systemFontOfSize:15];
    [scrollView addSubview:_btnVcode];
    [self.btnVcode addTarget:self action:@selector(getVcode:) forControlEvents:UIControlEventTouchUpInside];

    
    y += h + (I_PHONE ? 30.0: 35.0);
    h = I_PHONE ? 35.0 : 45.0;
    _tfVcode = [[UITextField alloc] initWithFrame:CGRectMake(x, y, w, h)];
    [_tfVcode setBackground:[[MGUtility MGImageName:@"MG_tf_gray.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(4, 4, 4, 4)]];
    [scrollView addSubview:_tfVcode];
    _tfVcode.keyboardType = UIKeyboardTypeNumberPad;
    _tfVcode.leftView = [self newLeftViewWithTitle:@"验证码" width:left_w];
    _tfVcode.leftViewMode = UITextFieldViewModeAlways;
    _tfVcode.placeholder = @"输入获取到的验证码";
    _tfVcode.delegate = self;
    
    y += h + 15.0;
    h = I_PHONE ? 35.0 : 45.0;

    if (_bindType == MGFindTypePhone) {
        //新密码框
        self.tfNewPassword = [[UITextField alloc] initWithFrame:CGRectMake(x, y, w, h)];
       [self.tfNewPassword setBackground:[[MGUtility MGImageName:@"MG_tf_gray.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(4, 4, 4, 4)]];
        [scrollView addSubview:self.tfNewPassword];
        
        self.tfNewPassword.leftView = [self newLeftViewWithTitle:@"新密码" width: left_w];
        self.tfNewPassword.leftViewMode = UITextFieldViewModeAlways;
        self.tfNewPassword.delegate = self;
        self.tfNewPassword.placeholder = @"6-20位字母和数字的组合";
        self.tfNewPassword.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.tfNewPassword.keyboardType = UIKeyboardTypeASCIICapable;
        self.tfNewPassword.secureTextEntry = YES;
        
        if (I_PHONE) {
            self.tfNewPassword.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            
        }else{
            self.tfNewPassword.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
        }
        
        y += h + 15.0;
        h = I_PHONE ? 44.0 : 50.0;
        
        self.btnDoBind = [MGUtility newBlueButton:CGRectMake(x, y, w, h) withTitle:@"确定" target:self action:@selector(doFindPasswordByPhoneAction:)];
    } else if (_bindType == MGBindTypePhone) {
        self.btnDoBind = [MGUtility newBlueButton:CGRectMake(x, y, w, h) withTitle:@"验证绑定手机" target:self action:@selector(doBindingPhoneAction:)];
    }
    [scrollView addSubview:self.btnDoBind];
    
    _tfPhone.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;

    _tfVcode.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    
    if (I_PHONE) {
        _tfPhone.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _btnVcode.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _tfVcode.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    }else{
        _tfPhone.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
        _btnVcode.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
        _tfVcode.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
        _btnVcode.titleLabel.font = [UIFont systemFontOfSize:17];
        _btnDoBind.titleLabel.font =[UIFont systemFontOfSize:17];
        self.btnDoBind.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    }
}


- (UIView *) newLeftViewWithTitle:(NSString *) title width:(CGFloat) w  //82.0
{
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, w, 35.0)];
    UILabel *lb = [MGUtility newLabel:CGRectMake(0, 0, w-10, 35.0) title:title font:I_FONT_13_16 textColor:TTHexColor(0x676974)];
    lb.textAlignment = NSTextAlignmentCenter;
    [leftView addSubview:lb];
    UIImageView *yLine = [[UIImageView alloc] initWithImage:[MGUtility MGImageName:@"MG_yline.png"]];
    yLine.frame = CGRectMake(w-10, 7, 1, 20.0);
    [leftView addSubview:yLine];
    return leftView;
}


static int iTick = 60;

- (void) getVcode:(id)sender
{
     [self.view endEditing:YES];
    if ([self.tfPhone.text length] == 0) {
//        [MGSVProgressHUD showErrorWithStatus:@"请输入手机号码"];
        MGAlertCustomView *alerView = [[MGAlertCustomView alloc]alerViewWithMessige:@"请输入手机号码" withType:AlertTypeWithSure];
        __weak typeof(alerView) weakalert = alerView;
        alerView.handler = ^(NSInteger index){
            if (index == 1) {
                [weakalert dissmiss];
            }
        };
        [alerView show];
         return;
    }
    
    [timer invalidate];
    timer = nil;

    
    [self.btnVcode removeTarget:self action:@selector(getVcode:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.btnVcode setTitle:@"正在发送..." forState:UIControlStateNormal];
    
    [sender setBackgroundImage:[[MGUtility MGImageName:@"MG_btn_gray.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(8, 8, 8, 8)] forState:UIControlStateNormal];
    
    if (_bindType == MGBindTypePhone) {
        
        [_tfPhone resignFirstResponder];
        [_tfVcode resignFirstResponder];
        
        MGVerifyCode *code = [[MGVerifyCode alloc] init];
        code.uid = [[MGManager defaultManager] MGOpenUID];
        code.number = self.tfPhone.text;
        code.token = [[MGManager defaultManager] MGToken];
        
        
        __weak MGBind *weakself = self;
        __block NSTimer *weaktimer = timer;
        iTick = 60;
        [[MGHttpClient shareMGHttpClient] genPhoneVerifyCode:code completion:^(NSDictionary *responseDic) {
            
            [weakself.btnVcode setTitle:@"60秒后重发" forState:UIControlStateNormal];
            
            weaktimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(waitingAfterSendCode:) userInfo:nil repeats:YES];
            [weaktimer fire];
            
        } failed:^(NSInteger ret, NSString *errMsg) {
//            [MGSVProgressHUD showErrorWithStatus:errMsg];
            [MGSVProgressHUD dismiss];
            MGAlertCustomView *alerView = [[MGAlertCustomView alloc]alerViewWithMessige:errMsg withType:AlertTypeWithSure];
            __weak typeof(alerView) weakalert = alerView;
            alerView.handler = ^(NSInteger index){
                if (index == 1) {
                    [weakalert dissmiss];
                }
            };
            [alerView show];
            [weakself.btnVcode setTitle:@"获取验证码" forState:UIControlStateNormal];
            [weakself.btnVcode addTarget:self action:@selector(getVcode:) forControlEvents:UIControlEventTouchUpInside];
             [sender setBackgroundImage:[[MGUtility MGImageName:@"MG_login_button_sel.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(8, 8, 8, 8)] forState:UIControlStateNormal];
            
        }];
    } else if (_bindType == MGFindTypePhone) {
        
        __weak MGBind *weakself = self;
        __block NSTimer *weaktimer = timer;
        iTick = 60;
        
        MGBoundMobile *bindModel = [[MGBoundMobile alloc]init];
        bindModel.number = self.tfPhone.text;

        [[MGHttpClient shareMGHttpClient] getPhoneFindPasswordVerifyCodeWithParams:bindModel completion:^(NSDictionary *responseDic) {
            [MGSVProgressHUD showSuccessWithStatus:responseDic[@"msg"]];
            
            __strong MGBind *strongSelf = weakself;
            [strongSelf.btnVcode setTitle:@"60秒后重发" forState:UIControlStateNormal];
            weaktimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(waitingAfterSendCode:) userInfo:nil repeats:YES];
            [weaktimer fire];
            
        } failed:^(NSInteger ret, NSString *errMsg) {
            __strong MGBind *strongSelf = weakself;
            //            [MGSVProgressHUD showErrorWithStatus:errMsg];
            [MGSVProgressHUD dismiss];
            MGAlertCustomView *alerView = [[MGAlertCustomView alloc]alerViewWithMessige:errMsg withType:AlertTypeWithSure];
            __weak typeof(alerView) weakalert = alerView;
            alerView.handler = ^(NSInteger index){
                if (index == 1) {
                    [weakalert dissmiss];
                }
            };
            [alerView show];
            [strongSelf.btnVcode setTitle:@"获取验证码" forState:UIControlStateNormal];
            [strongSelf.btnVcode addTarget:self action:@selector(getVcode:) forControlEvents:UIControlEventTouchUpInside];
            [sender setBackgroundImage:[[MGUtility MGImageName:@"MG_login_button_sel.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(8, 8, 8, 8)] forState:UIControlStateNormal];
            
        }];
    } else {
        [MGSVProgressHUD dismiss];
    }


}

- (void) waitingAfterSendCode:(NSTimer *) aTimer
{
    if (iTick == 0) {
        [aTimer invalidate];
        timer = nil;
        [self.btnVcode setTitle:@"获取验证码" forState:UIControlStateNormal];
        [self.btnVcode addTarget:self action:@selector(getVcode:) forControlEvents:UIControlEventTouchUpInside];
        [self.btnVcode setBackgroundImage:[[MGUtility MGImageName:@"MG_login_button_sel.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(8, 8, 8, 8)] forState:UIControlStateNormal];
        return;
    }
    [self.btnVcode setTitle:[NSString stringWithFormat:@"%d秒后重发", iTick] forState:UIControlStateNormal];
    --iTick;
}

- (void) doBindingPhoneAction:(id)sender
{
    
    if ([self.tfPhone.text length] == 0) {
        //        [MGSVProgressHUD showErrorWithStatus:@"请输入绑定手机号码"];
        MGAlertCustomView *alerView = [[MGAlertCustomView alloc]alerViewWithMessige:@"请输入绑定手机号码" withType:AlertTypeWithSure];
        __weak typeof(alerView) weakalert = alerView;
        alerView.handler = ^(NSInteger index){
            if (index == 1) {
                [weakalert dissmiss];
            }
        };
        [alerView show];
        return;
    }
    
    if ([self.tfVcode.text length] == 0) {
        //        [MGSVProgressHUD showErrorWithStatus:@"请输入验证码"];
        MGAlertCustomView *alerView = [[MGAlertCustomView alloc]alerViewWithMessige:@"请输入验证码" withType:AlertTypeWithSure];
        __weak typeof(alerView) weakalert = alerView;
        alerView.handler = ^(NSInteger index){
            if (index == 1) {
                [weakalert dissmiss];
            }
        };
        [alerView show];
        return;
    }
    
    MGBoundMobile *mobile = [[MGBoundMobile alloc] init];
    mobile.uid = [[MGManager defaultManager] MGOpenUID];
    mobile.number = self.tfPhone.text;
    //    mobile.type = @"mobile";
    mobile.code = self.tfVcode.text;
    mobile.token = [[MGManager defaultManager] MGToken];
    
    __weak MGBind *weakself = self;
    [MGSVProgressHUD showWithStatus:@"正在提交，请稍后" maskType:MGSVProgressHUDMaskTypeClear];
    [[MGHttpClient shareMGHttpClient] boundMobile:mobile completion:^(NSDictionary *responseDic) {
        MG_LOG(@"手机号码绑定成功");
        MGAccountSettingInfo *info = [MGStorage currentAccountSettingInfo];
        info.phoneNum = self.tfPhone.text;
        info.phoneStatus = @"1";
        [MGStorage setOneAccountSettingInfo:info isCurrentAccount:YES];
        
        
        //        [MGSVProgressHUD showSuccessWithStatus:@"手机号码绑定成功"];
        [MGSVProgressHUD dismiss];
        MGAlertCustomView *alerView = [[MGAlertCustomView alloc]alerViewWithMessige:@"手机号码绑定成功" withType:AlertTypeWithSure];
        __weak typeof(alerView) weakalert = alerView;
        alerView.handler = ^(NSInteger index){
            if (index == 1) {
                [weakalert dissmiss];
                
                if (weakself.tabBarController != nil) {
                    [weakself performSelector:@selector(back:) withObject:nil afterDelay:1.2];
                }else {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:kMGPlatform_Dismiss_Noti object:[NSNumber numberWithInt:weakself.MGAction] userInfo:nil];
                    });
                    
                }
            }
        };
        [alerView show];
        [weakself sendDelegate];
        [weakself resultCompletion:YES];
        
        
    } failed:^(NSInteger ret, NSString *errMsg) {
        
        //                [MGSVProgressHUD showErrorWithStatus:errMsg];
        [MGSVProgressHUD dismiss];
        MGAlertCustomView *alerView = [[MGAlertCustomView alloc]alerViewWithMessige:errMsg withType:AlertTypeWithSure];
        __weak typeof(alerView) weakalert = alerView;
        alerView.handler = ^(NSInteger index){
            if (index == 1) {
                [weakalert dissmiss];
                
            }
        };
        [alerView show];
        [weakself resultCompletion:false];
    }];
}

- (void)resultCompletion:(BOOL)status {
    if (self.Completion) {
        if (status == YES) {
            self.Completion(self.tfPhone.text,status);
        }else{
            self.Completion(@"0",status);
        }
        
    }
}

- (void)doFindPasswordByPhoneAction:(UIButton *)sender {
    
    [self.view endEditing:YES];
    [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    
    
    if (![MGUtility validatePhoneNumber:self.tfPhone.text andErrorMsg:^(NSString *errorMsg) {
        
        //        [MGSVProgressHUD showErrorWithStatus:errorMsg];
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
    if ([self.tfVcode.text length] == 0) {
        //        [MGSVProgressHUD showErrorWithStatus:@"验证码不能为空"];
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
    if (![MGUtility validatePassword:self.tfNewPassword.text andErrorMsg:^(NSString *errorMsg) {
        //         [MGSVProgressHUD showErrorWithStatus:errorMsg];
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
    
    //    __weak typeof(&*self) weakSelf = self;
    [MGSVProgressHUD showWithStatus:@"正在提交，请稍后" maskType:MGSVProgressHUDMaskTypeClear];
    NSDictionary *dict = @{@"type": @"mob",
                           @"mobile" : self.tfPhone.text,
                           @"code" : self.tfVcode.text,
                           @"pwd" : self.tfNewPassword.text
                           };
    
    [[MGHttpClient shareMGHttpClient] findPasswordWithParams:dict completion:^(NSDictionary *responseDic) {
        
        [MGSVProgressHUD dismiss];
        
        //        [MGSVProgressHUD showSuccessWithStatus:@"修改密码成功"];
        [MGSVProgressHUD dismiss];
        MGAlertCustomView *alerView = [[MGAlertCustomView alloc]alerViewWithMessige:@"修改密码成功" withType:AlertTypeWithSure];
        __weak typeof(alerView) weakalert = alerView;
        __weak typeof(self) weakSelf = self;
        alerView.handler = ^(NSInteger index){
            if (index == 1) {
                [weakalert dissmiss];
                //        [weakSelf performSelector:@selector(doFindPasswordByPhoneActionX:) withObject:responseDic afterDelay:0];
                
                //注销 跳转登录界面
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [[MGManager defaultManager] performSelector:@selector(MGSwitchAccount) withObject:nil afterDelay:0.6];
                    
                    [weakSelf.navigationController popToRootViewControllerAnimated:YES];
                });
            }
        };
        [alerView show];
        
        
        
        
        
    } failed:^(NSInteger ret, NSString *errMsg) {
        //        [MGSVProgressHUD showErrorWithStatus:errMsg];
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

- (void) doFindPasswordByPhoneActionX:(NSDictionary *)responseDic
{
    MGResetPasswordVC *resetPSW = [[MGResetPasswordVC alloc] init];
    resetPSW.MGAction = MGActionNoAction;
    resetPSW.account = self.account;
    [resetPSW setTokenFlag:responseDic[@"token"]];
    [self.navigationController pushViewController:resetPSW animated:YES];
}



- (void) textFieldSetting:(UITextField *) tf
{
    tf.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    tf.autocorrectionType = UITextAutocorrectionTypeNo;
    tf.autocapitalizationType = UITextAutocapitalizationTypeNone;
}



- (void) pop:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}



- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
    
    [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    
 
}




@end
