//
//  LoginViewController.m
//  MGPlatformTest
//
//  Created by caosq on 14-6-11.
//  Copyright (c) 2014年 Eason. All rights reserved.
//

#import "MGLoginViewController.h"
#import "MGUITextField_XLine.h"
#import "MGLoginMenuView.h"
#import "MGModelObj.h"
#import "MGHttpClient.h"
#import "MGRegisterController.h"
#import "MGScrollView.h"
#import "MGStorage.h"
#import "MGMacros.h"
#import "MGUtility.h"
#import "MGLoginFooterView.h"
#import "MGResetPasswordVC.h"
#import "MGPullDown.h"
#import "NSData+MGCryptUtil.h"
#import "MGShowTipsView.h"
#import "MGAlertView.h"
#import "MGLoginPhoneRegistView.h"
#import "MGPhoneRegisterController.h"
#import "UIView+MGHandleFrame.h"
#import "MGBind.h"
#import "MGPhoneRegisterAgreement.h"
#import "MGRegisterAgreementController.h"
#import "MGConfiguration.h"

@interface MGLoginViewController ()<UITextFieldDelegate, MGPullDownDelegate,MGDialogAlertViewDelegate>
{
    MGLoginType _MGLoginType;
    BOOL bLoginActionWhenAppear;
}


@property (nonatomic, strong) MGScrollView *scrollView;
@property (nonatomic, strong) UIView *pageView;

@property (nonatomic, strong) MGUITextField_XLine *tfAccount;
@property (nonatomic, strong) UITextField *tfSecret;
@property (nonatomic, strong) MGLoginMenuView *menuView;

@property (nonatomic, strong) MGLoginFooterView *footerView;



@property (nonatomic, strong) UIImageView *iconIv;
@property (nonatomic, strong) UIView *inputView;
@property (nonatomic, strong) MGPullDown *pullDownUsers;

@property(nonatomic,strong)UIImageView *loginbcImage;

@property (nonatomic, strong) MGPhoneRegisterAgreement *registerAgreement;


@end

@implementation MGLoginViewController

- (instancetype) initWithLoginType:(MGLoginType)loginType
{
    self = [super init];
    if (self) {
        _MGLoginType = loginType;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = nil;
    if (TT_IS_IOS7_AND_UP) {
        self.title = @"登录";
    }else
        [self.navigationItem setTitleView:[MGUtility naviTitle:@"登录"]];
    
    
    [self initUI];
    
    bLoginActionWhenAppear = NO;
    [self getAccountsFromRemote];
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        //sdk激活
        [[MGHttpClient shareMGHttpClient].statistics sdkActiveation];
    });
    
    
}

- (void)loadInputView
{
    NSString *loginAccount, *secret;
    
    if ([self.tfAccount.text length] > 0 || [self.tfSecret.text length] > 0 ) {
        return;
    }
    
    MGAccountSettingInfo *info = [MGStorage currentAccountSettingInfo];
    BOOL bhasCurrent = YES;
    if (info == nil || info.isGuestAccount) {
        info = [MGStorage findNotGuestAccountSettingInfo];
        bhasCurrent = NO;
    }
    if ( info != nil){
        
        if (!info.isGuestAccount) {
            
            loginAccount = info.account;
            secret = [NSString AES256Decrypt:info.secret withKey:KMG_S];
        
            MGAccount *shareAccount = [MGStorage MGAccountByAccount:loginAccount];
            NSString *sharesecret = [NSString AES256Decrypt:shareAccount.pwData withKey:@"MGzs00@!*&#^*@(ksk"];
            if (![secret isEqualToString:sharesecret] && [sharesecret length] > 0) {
                secret = sharesecret;
            }
        
            if (!bhasCurrent) {
                if (_MGLoginType == MGLoginTypeAutoLogin) {  // 若是第一次登录游戏，从粘贴板获取账号，不进行自动登录
                    _MGLoginType = MGLoginTypeNormal;
                }
            }
        }
    }
    
    self.pullDownUsers.realAccountStr = loginAccount;
    if (loginAccount.length == 11 && [[loginAccount substringToIndex:1] intValue] == 1) {
        self.tfAccount.text = [loginAccount stringByReplacingCharactersInRange:NSMakeRange(3, 4) withString:@"****"];
    }else {
        self.tfAccount.text = loginAccount;
    }
    BOOL bRem =  info ? info.bRememberSecret : YES;
    if (bRem) {
        [self.menuView.passwordCheckbox setChecked:YES];
        self.tfSecret.text = secret;
    }else{
        [self.menuView.passwordCheckbox setChecked:NO];
        self.tfSecret.text = @"";
    }
    
    BOOL bLoginNum = info ? info.bAutoLogin : YES;
    if (bLoginNum == NO) {
        [self.menuView.autologinCheckbox setChecked:NO];
    }else
        [self.menuView.autologinCheckbox setChecked:YES];
}


- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.tfAccount.delegate = self;
    self.tfSecret.delegate = self;
    [self addNotificationObserver];

    if (bLoginActionWhenAppear) {
        bLoginActionWhenAppear = NO;
        [self doAutoLoginAsynic];
    }
}



- (void) viewWillDisappear:(BOOL)animated
{
    self.tfAccount.delegate = nil;
    self.tfSecret.delegate = nil;
    [self.tfAccount resignFirstResponder];
    [self.tfSecret resignFirstResponder];
    [self.view endEditing:YES];
    
    [self removeNotificationObserver];
    
    [super viewWillDisappear:animated];
}


- (void)addNotificationObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)removeNotificationObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void) doAutoLoginAsynic
{
    
    if (_MGLoginType == MGLoginTypeAutoLogin && self.menuView.autologinCheckbox.checked) {  //自动登录
        
        _MGLoginType = MGLoginTypeNormal;  // 判断一次
        if ([self.tfAccount.text length] > 0 && [self.tfSecret.text length] > 0) {
//            [MGSVProgressHUD showWithStatus:@"正在登录中..." maskType:MGSVProgressHUDMaskTypeClear];
            [self performSelector:@selector(doLoginAction:) withObject:nil afterDelay:0.5];
        }
        
    }else if(_MGLoginType == MGLoginTypeGuest){
        
        [self guestLogin];
        
    }else if (_MGLoginType == MGLoginTypeNormal){  //普通登录
        
        [self normalLogin];
    }
}

- (void)guestLogin {
    NSString *title;
    NSString *uid = [MGStorage getGuestUid];
    if ([uid length] > 0) {
        title = [NSString stringWithFormat:@"游客登录(游客%@)", uid];
    }else
        title = @"游客登录";
    [self.footerView.buttonVisitor setTitle:title forState:UIControlStateNormal];
}

- (void)normalLogin {
    NSString *title;                            // 普通登录 如果有游客账号 依然显示出来
    NSString *uid = [MGStorage getGuestUid];
    if ([uid length] > 0) {
        title = [NSString stringWithFormat:@"游客登录(游客%@)", uid];
    }else
        title = @"游客登录";
    [self.footerView.buttonVisitor setTitle:title forState:UIControlStateNormal];
}



- (void) initUI
{
    
    TTDEBUGLOG(@"**** %@", NSStringFromCGRect(self.view.frame));
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
    
    CGFloat w = 320.0;
    _pageView = [[UIView alloc] initWithFrame:CGRectMake(ceilf((self.view.bounds.size.width - w)/2), 0, w, self.view.bounds.size.height)];   // 固定320
    [_pageView setBackgroundColor:[UIColor clearColor]];
    [self.scrollView addSubview:self.pageView];
    
    self.pageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    float iconWidth = 114.f;
    float originY =   25.5f;
    _iconIv = [[UIImageView alloc] initWithFrame:CGRectMake((self.pageView.bounds.size.width - iconWidth) / 2, originY, 205, 138)];
    _iconIv.image = [MGUtility MGImageName:@"MG_login_logo.png"];
    [self.pageView addSubview:_iconIv];
    
    originY += 138 + 25.0;
    
    _inputView = [self makeInputViewWithFrame:CGRectMake(15, originY, self.pageView.bounds.size.width-15*2, 70.0)];
    [self.pageView addSubview:_inputView];
    
    originY += 70.0 + 20.0f;
    
    CGFloat x = ceilf((self.pageView.bounds.size.width-320.0)/2);

    [self makeMenuViewWithFrame:CGRectMake(x, originY, self.pageView.bounds.size.width-x*2, 160.0)];
    [self.pageView insertSubview:self.menuView belowSubview:self.inputView];
    
    self.scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, originY + 160.0);
    self.scrollView.userInteractionEnabled = YES;
    self.pageView.userInteractionEnabled = YES;
    
    
    // 用户协议和隐私协议
    
    CGFloat registerAgreement_X = self.pageView.bounds.size.width/2.0;
    CGFloat registerAgreement_Y = originY ;
    if ((iPad_P) || (iPad_L)) {
        registerAgreement_X = 0;
        registerAgreement_Y = _inputView.frame.origin.y + 200;
    }
    if ((iPhone_L)) {
        registerAgreement_X = 0;
        registerAgreement_Y = registerAgreement_Y-50;
    }
    if ((iPhone_P)) {
        registerAgreement_X = 0;
        registerAgreement_Y = registerAgreement_Y+100;
    }
    _registerAgreement = [[MGPhoneRegisterAgreement alloc] initWithFrame:CGRectMake(registerAgreement_X-20, registerAgreement_Y, self.pageView.bounds.size.width, 150.f) fromCon:fromControllerLogin];
    _registerAgreement.userInteractionEnabled = YES;
    
    [_registerAgreement.agreementButton addTarget:self
                                           action:@selector(agreementButtonClicked:)
                                 forControlEvents:UIControlEventTouchUpInside];
    [_registerAgreement.privacyButton addTarget:self
                                            action:@selector(privacyButtonClicked:)
                                  forControlEvents:UIControlEventTouchUpInside];
    [self.pageView addSubview:_registerAgreement];
    
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
        [userDefaults setObject:[NSString stringWithFormat:@"%d",privacy_version] forKey:GDSaveDidPrivacyVersion];
        [userDefaults synchronize];
        [[MGConfiguration shareConfiguration] setShowPrivacyNew:YES];

    }
   
    MGRegisterAgreementController* agreementController = [[MGRegisterAgreementController alloc] init];
    agreementController.MGAction = self.MGAction;
    [MGManager defaultManager].Private_URL = [NSString stringWithFormat:@"https://adapi.mg3721.com/inapi/privacy?appid=%@", [MGManager defaultManager].MG_APPID];
//    [MGManager defaultManager].Private_URL = [NSString stringWithFormat:@"https://dev.mg3721.com/inapi/privacy?appid=%@", [MGManager defaultManager].MG_APPID];
    [self.navigationController pushViewController:agreementController
                                         animated:YES];
}

- (UIView *) makeInputViewWithFrame:(CGRect) frame
{
    UIView *inputView = [[UIView alloc] initWithFrame:frame];
    inputView.layer.borderWidth = TT_IS_RETINA ? 0.6f : 1.0f;
    inputView.layer.borderColor = TTHexColor(0xd5d5db).CGColor;
    inputView.layer.cornerRadius = 7.0;
    inputView.clipsToBounds = YES;
    inputView.backgroundColor = TTWhiteColor;
    CGFloat x = 6.0;
    _tfAccount = [[MGUITextField_XLine alloc] initWithFrame:CGRectMake(x, 0, frame.size.width-2*x , frame.size.height/2)];
    _tfAccount.placeholder = @"游戏账号";
    [MGUtility setTextField:_tfAccount leftTitle:@"   账号 :" leftWidth:I_PAD ? 60.0 : 50.0];
    _tfAccount.font =  I_PAD ? iPad_Font16 : iPhone_Font13;
    
    _tfAccount.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _tfAccount.keyboardType = UIKeyboardTypeDefault;
    _tfAccount.autocorrectionType = UITextAutocorrectionTypeNo;
    _tfAccount.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _tfAccount.returnKeyType = UIReturnKeyNext;
    _tfAccount.delegate = self;
    _tfAccount.rightView = [self newRightView];
    _tfAccount.rightViewMode = UITextFieldViewModeAlways;
    _tfAccount.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight;
    [inputView addSubview:_tfAccount];
    
    _tfSecret = [[UITextField alloc] initWithFrame:CGRectMake(x, frame.size.height/2, frame.size.width - 2*x, frame.size.height/2)];
    _tfSecret.placeholder = @"请输入密码";
    _tfSecret.secureTextEntry = YES;
    _tfSecret.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _tfSecret.returnKeyType = UIReturnKeyDone;
    _tfSecret.delegate = self;
    _tfSecret.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleHeight;
    _tfSecret.font = I_PAD ? iPad_Font16 : iPhone_Font13;
    
    [MGUtility setTextField:_tfSecret leftTitle:@"   密码 :" leftWidth:I_PAD ? 60.0 : 50.0];
    [inputView addSubview:self.tfSecret];
    
    return inputView;
}

- (UIButton *) newRightView
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:[MGUtility MGImageName:@"MG_mark_down@2x.png"] forState:UIControlStateNormal];
    btn.frame = CGRectMake(0, 0, 35.0, 35.0);
    [btn addTarget:self action:@selector(onClickMoreUser:) forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

- (void) onClickMoreUser:(UIButton *)sender
{
    NSArray *allAccount = [MGStorage allAccountSettingsExceptGuest];
    
    __block NSMutableArray *Marray = [NSMutableArray new];
    [allAccount enumerateObjectsUsingBlock:^(MGAccountSettingInfo *info, NSUInteger idx, BOOL *stop) {
        [Marray addObject:info.account];
    }];
    if ([Marray count] == 0) {
        return;
    }
    self.pullDownUsers.pulldownLists = Marray;
    [self.pullDownUsers presentPullDownToRect:[self getPullDownRect] inView:_pageView];
}

- (CGRect) getPullDownRect {
    CGRect frame = CGRectZero;
    frame.origin.x = _inputView.frame.origin.x;
    frame.origin.y = _inputView.frame.origin.y + _tfAccount.frame.size.height;
    frame.size.width = _inputView.frame.size.width;
    frame.size.height = _pageView.frame.size.height - frame.origin.y;
    return frame;
}


//获取远程数据，和accontsetting数据比较
- (void) getAccountsFromRemote
{
    if ([MGStorage allAccountSettings].count > 0) {

        [self loadInputView];
        bLoginActionWhenAppear = YES;

    }else{
        [MGSVProgressHUD showWithStatus:@"正在加载用户列表" maskType:MGSVProgressHUDMaskTypeClear];
        __weak MGLoginViewController *weakself = self;
        [[MGHttpClient shareMGHttpClient]getAccountArraycompletion:^(NSDictionary *responseDic) {
                   NSArray *data = responseDic[@"data"];
                    [weakself performSelector:@selector(dealwithRemoteAccount:) withObject:data afterDelay:0];
                    [MGSVProgressHUD dismiss];
        } failed:^(NSInteger ret, NSString *errMsg) {
                    [MGSVProgressHUD dismiss];
                    [weakself dealwithRemoteAccount:nil];
        }];
    }
    
}

- (void) dealwithRemoteAccount:(NSArray *) data
{
    if (data != nil && [data isKindOfClass:[NSArray class]]) {
        [MGStorage setAccountSettingsWithRemoteData:data];
    }
    [self loadInputView];
    [self  doAutoLoginAsynic];
}


- (MGPullDown *)pullDownUsers {
    
    if (_pullDownUsers == nil) {
        _pullDownUsers = [[MGPullDown alloc] initWithStyle:UITableViewStylePlain];
        _pullDownUsers.delegate = self;
        UIImageView *bg = [[UIImageView alloc] initWithImage:[[MGUtility MGImageName:@"MG_list_bg@2x.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(4, 8, 10, 8)]];
        [_pullDownUsers.tableView setBackgroundView:bg];
        _pullDownUsers.bShowCancelActionButton = YES;
        _pullDownUsers.tableView.layer.borderWidth = 0.0;
        _pullDownUsers.tableView.layer.cornerRadius = 0.0;
        _pullDownUsers.rowHeight =  I_PHONE ? 38.0 : 48.0;
    }
    return _pullDownUsers;
}

#pragma mark - MGPullDownDelegate

- (void) MGPullDown:(MGPullDown *) pulldown selectedItem:(id) item {
    
    self.tfAccount.text = item;
    item = pulldown.realAccountStr;
    MGAccountSettingInfo *info = [MGStorage accountSettingInfoByAccount:item];
    NSString *secret = [NSString AES256Decrypt:info.secret withKey:KMG_S];
    MGAccount *theAccount = [MGStorage MGAccountByAccount:item];
    if (theAccount.pwData != nil) {
        NSString *shareSecret = [NSString AES256Decrypt:theAccount.pwData withKey:@"MGzs00@!*&#^*@(ksk"];
        if (![secret isEqualToString:shareSecret]) {
            secret = shareSecret;
        }
    }
    
    [self.menuView.passwordCheckbox setChecked:info.bRememberSecret];
    if (self.menuView.passwordCheckbox.checked) {
        self.tfSecret.text = secret;
    }else
        self.tfSecret.text = @"";
    
    [self.menuView.autologinCheckbox setChecked:info.bAutoLogin];
 
    
}

- (void) MGPullDown:(MGPullDown *)pulldown removeItem:(id)item
{
    item = pulldown.realAccountStr;
    NSMutableArray *MArray = [NSMutableArray arrayWithArray:self.pullDownUsers.pulldownLists];
    [MArray removeObject:item];
    self.pullDownUsers.pulldownLists = MArray;
    
    [MGStorage removeAccountSettingInfoByAccount:item];
}


#pragma mark -- Menu Action

- (MGLoginMenuView *) makeMenuViewWithFrame:(CGRect) frame
{
    _menuView = [[MGLoginMenuView alloc] initWithFrame:frame];
    [_menuView.forgotButton addTarget:self
                              action:@selector(getPasswordAction:)
                            forControlEvents:UIControlEventTouchUpInside];
    [_menuView.loginButton addTarget:self
                             action:@selector(doLoginAction:)
                           forControlEvents:UIControlEventTouchUpInside];
    [_menuView.registerButton addTarget:self
                                action:@selector(doPhoneRegister:)
                              forControlEvents:UIControlEventTouchUpInside];
    [_menuView.fastButton addTarget:self
                                 action:@selector(doRegisterAction:)
                       forControlEvents:UIControlEventTouchUpInside];
    return _menuView;
}



- (void) getPasswordAction:(UIButton *) btn {

    MGBind *bind = [[MGBind alloc]initWithBindType:MGFindTypePhone];
    
    [self.navigationController pushViewController:bind animated:YES];
}

- (void) doLoginAction:(UIButton *) btn
{
    [self.view endEditing:YES];
    [self.pullDownUsers dismissPullDown];
    
    if (self.pullDownUsers.realAccountStr.length <= 0 && [self.tfAccount.text rangeOfString:@"****"].location == NSNotFound) {
        self.pullDownUsers.realAccountStr = self.tfAccount.text;
    }
    
    if (![MGUtility validateAccount:self.pullDownUsers.realAccountStr andErrorMsg:^(NSString *errorMsg) {
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
    if ([self.tfSecret.text length] == 0) {
        MGAlertCustomView *alerView = [[MGAlertCustomView alloc]alerViewWithMessige:@"请输入密码" withType:AlertTypeWithSure];
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
    
    [MGSVProgressHUD showWithStatus:@"正在登录中..." maskType:MGSVProgressHUDMaskTypeClear];
    MGLoginInfo *userInfo =  [[MGLoginInfo alloc] init];
       if ([self.tfAccount.text rangeOfString:@"****"].location == NSNotFound) {
        userInfo.account = self.tfAccount.text;
    }else {
        userInfo.account = self.pullDownUsers.realAccountStr;
    }
    userInfo.password = self.tfSecret.text;
    _menuView.loginButton.userInteractionEnabled = false;
    [self userLoginServer:userInfo btn:btn];
}

- (void)userLoginServer:(MGLoginInfo *)userInfo btn:(UIButton *)btn {
    __weak MGLoginViewController * weakself = self;
    
    NSLog(@"loginaa");
    [[MGHttpClient shareMGHttpClient] userLogin:userInfo completion:^(NSDictionary *responseDic) {
        
        [MGSVProgressHUD dismiss];
        if (weakself != nil) {
            
            MGAccountSettingInfo *info = [MGStorage accountSettingInfoByAccount:userInfo.account];
            info.bRememberSecret = weakself.menuView.passwordCheckbox.checked;
            info.bAutoLogin = weakself.menuView.autologinCheckbox.checked;
            if (weakself.menuView.passwordCheckbox.checked || weakself.menuView.autologinCheckbox.checked) {
                info.secret = [MGStorage  AES256Encrypt:weakself.tfSecret.text];
                
            }else {  //不记住密码，只记住用户名
                
                info.secret = nil;
            }
            
            NSDictionary *rDic = responseDic[@"data"];
            if (rDic != nil) {
                NSString *uid = [NSString stringWithFormat:@"%@", rDic[@"uid"]];
                NSString *token = [NSString stringWithFormat:@"%@", rDic[@"token"]];
                NSString *phonestatus = [NSString stringWithFormat:@"%@", rDic[@"isbind"]];
                NSString *idCardBindStatus = [NSString stringWithFormat:@"%@", rDic[@"idcard"]];
                NSString *is_adultStr = [NSString stringWithFormat:@"%@", rDic[@"is_adult"]];

                //支付资源id
                //                NSString *resourceid = [NSString stringWithFormat:@"%@", rDic[@"resource_id"]];
                //
                //                [[MGPlatform defaultPlatform]setMG_RESOURCE_ID:resourceid];
                
                info.uid = uid;
                info.token = token;
                info.phoneStatus = phonestatus;
                info.idCardBindStatus = idCardBindStatus;
                info.is_adult = is_adultStr;

                [MGStorage setOneAccountSettingInfo:info isCurrentAccount:YES];
                
                MG_LOG(@"登录成功：\nuid:%@ \ntoken:%@", uid, token);
                if ([is_adultStr integerValue] <= 0) {
                    NSMutableDictionary *tempDic = [NSMutableDictionary dictionaryWithDictionary:rDic];
                    [tempDic addEntriesFromDictionary:@{@"is_adult" : @"0"}];
                    rDic = tempDic;
                }
                [weakself performSelector:@selector(afterLoginSuccess:) withObject:@{
                                                                                     kMGPlatformErrorKey: responseDic[@"ret"],
                                                                                     @"status" : rDic[@"status"],
                                                                                     @"idcard" : rDic[@"idcard"],
                                                                                     @"isbind" : rDic[@"isbind"],
                                                                                     @"is_adult" : rDic[@"is_adult"]
                                                                                     } afterDelay:0.3];
                
                [[MGHttpClient shareMGHttpClient].statistics MG_LoginStatistics:rDic[@"uid"]];
                
            }
            
            
        }
        
    } failed:^(NSInteger ret, NSString *errMsg) {
        [MGSVProgressHUD dismiss];
        _menuView.loginButton.userInteractionEnabled = YES;

        
        NSString *err = [NSString stringWithFormat:@"登录失败，%@", errMsg];
        //        [MGSVProgressHUD showErrorWithStatus:err];
        MGAlertCustomView *alerView = [[MGAlertCustomView alloc]alerViewWithMessige:err withType:AlertTypeWithSure];
        __weak typeof(alerView) weakalert = alerView;
        alerView.handler = ^(NSInteger index){
            if (index == 1) {
                [weakalert dissmiss];
                [weakself performSelector:@selector(sendLoginNotification:) withObject:@{kMGPlatformErrorKey: [NSNumber numberWithInteger:ret], kMGPlatformErrorMsg: errMsg} afterDelay:0];
            }
        };
        [alerView show];
        
    }];
}

- (void) sendLoginNotification:(NSDictionary *) userInfo
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kMGPlatformLoginNotification object:nil userInfo:userInfo];
}

- (void) afterLoginSuccess:(NSDictionary *) userInfo
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kMGPlatformReloadUserInfoNitifaication object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kMGPlatform_Dismiss_Noti object:[NSNumber numberWithInt:MGActionNothing] userInfo:@{@"action": @"ShowGreet"}];
    [[NSNotificationCenter defaultCenter] postNotificationName:kMGPlatformLoginNotification object:nil userInfo:userInfo];
    _menuView.loginButton.userInteractionEnabled = YES;
}

- (void) afterGestureLoginSuccess:(NSDictionary *) userInfo
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kMGPlatformReloadUserInfoNitifaication object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kMGPlatform_Dismiss_Noti object:[NSNumber numberWithInt:MGActionNothing] userInfo:@{@"action": @"ShowGreet", @"isGuest": [NSNumber numberWithBool:YES]}];
    [[NSNotificationCenter defaultCenter] postNotificationName:kMGPlatformLoginNotification object:nil userInfo:userInfo];
}




- (void) doRegisterAction:(UIButton *) btn
{
    MGRegisterController* registerController = [[MGRegisterController alloc] init];
    registerController.MGAction = MGActionRegister;
    [self.navigationController pushViewController:registerController
                                         animated:YES];
}


#pragma mark Keyboard Notification
- (void)keyboardWillShow:(NSNotification*)notification
{
    if (iPhone_L) {
        const float yoffset = TT_IS_IOS7_AND_UP ? 94.0f : 94.0f;
        [self.scrollView setContentOffset:CGPointMake(0, yoffset) animated:YES];
    }else if (iPhone_P){
        const float yoffset = TT_IS_IOS7_AND_UP ? 150.0 : 150.0;
        [self.scrollView setContentOffset:CGPointMake(0, yoffset) animated:YES];
    }
}

- (void)keyboardWillHide:(NSNotification*)notification
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    }
}

- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
    [self.view endEditing:YES];
    [self.pullDownUsers dismissPullDown];
}


#pragma mark -- ---------------------------------------游客登录--------------------------------------------------------
#pragma mark - 游客登录



- (void)doPhoneRegister:(UIButton *)sender {
    
    MGPhoneRegisterController* registerController = [[MGPhoneRegisterController alloc] init];
    registerController.MGAction = MGActionRegister;
    [self.navigationController pushViewController:registerController
                                         animated:YES];
}






- (void) loginNeedUseAccount:(NSString *) account
{
    NSString *account_s = [NSString stringWithFormat:@"您已经注册游戏账号[%@]，请使用账号登录", account];
    
    [[[MGAlertView alloc] initWithTitle:@"登录提示" message:account_s callback:^(int index, NSString *title) {
        
        MGAccountSettingInfo *info = [MGStorage accountSettingInfoByAccount:account];
        if (info != nil) {
            
            self.tfAccount.text = info.account;
            self.tfSecret.text =  [NSString AES256Decrypt:info.secret withKey:KMG_S];
            self.menuView.autologinCheckbox.checked = info.bAutoLogin;
            self.menuView.passwordCheckbox.checked = info.bRememberSecret;
            
        }else{
            self.tfAccount.text = account;
            self.tfSecret.text = @"";
        }
        
    } cancelButtonTitle:@"好的" otherButtonTitles:nil, nil] show];
    
}



- (void) viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        self.scrollView.contentSize =  self.view.bounds.size; // CGSizeMake(self.view.bounds.size.width, 500.0);
    }else
        self.scrollView.contentSize = self.view.bounds.size;
    
    [self resizeUI];
    
//        self.scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, 700);
}


- (void) resizeUI
{
    
    if (iPhone_L) {
        [self resizeWhenLandscape];
        [self resizeForScrollView];
        [self.registerAgreement resizeForiPhoneLandscape];
    }else if (iPhone_P){
        [self resizeWhenPortrait];
        [self resizeForScrollView];
        [self.registerAgreement resizeForiPhonePortrait];
        
    }else if ((iPad_P) || (iPad_L)){
        [self resizeWhenIpad];
         [self.registerAgreement resizeForiPad];
    }
}

- (void) resizeForScrollView
{
    //解决IOS8上转屏问题造成scrollview高度不够。
    CGRect scrollviewRect = self.scrollView.frame;
    scrollviewRect.size.height = CGRectGetHeight(self.view.frame);
    self.scrollView.frame = scrollviewRect;
    
    if (([self.tfAccount isFirstResponder] || [self.tfSecret isFirstResponder]) && self.scrollView.contentOffset.y == 0) {
            [self keyboardWillShow:nil];
    }
}


- (void) resizeWhenLandscape
{
    CGFloat y = 10.0;
    CGFloat w =120;
    
    CGFloat imageW = self.loginbcImage.image.size.width;
    CGFloat imageH = self.loginbcImage.image.size.height;
    [self.loginbcImage setHeight:self.view.frame.size.width * imageH / imageW==0?960.00:imageW] ;
    self.pageView.frame = self.view.bounds;
    self.iconIv.frame = CGRectMake(ceilf((self.view.bounds.size.width - w)/2), y, w, 80);
    y += 80 + 10.0;
    w = 846.0/2;
    self.inputView.frame = CGRectMake(ceilf((self.view.bounds.size.width - w)/2), y, 580.0/2, 70.0);
    self.menuView.frame = CGRectMake(ceilf((self.view.bounds.size.width - w)/2), y, w, 200.0);
    self.registerAgreement.frame = CGRectMake(ceilf((self.view.bounds.size.width - w)/2),CGRectGetMaxY(self.inputView.frame)+80, self.pageView.bounds.size.width, 150);
//    self.footerView.frame = CGRectMake(ceilf((self.view.bounds.size.width - w)/ 2), self.pageView.frame.size.height - 30 - 10, w, 30);
    if(I_PHONE_X){
      
    }else{
        
    }
    
    
    [self.menuView resizeForLandscape];
//    [self.footerView resizeForLandscape];
    
    [self.pullDownUsers.view setFrame:[self.pullDownUsers calculateRectWith:[self getPullDownRect] inView:_pageView]];
}

- (void) resizeWhenPortrait
{
    CGFloat w = 320.0;
  
    self.pageView.frame = CGRectMake(ceilf((self.view.bounds.size.width - w)/2), 0, w, self.view.bounds.size.height);
    float iconWidth = 120.0f, originY = 25.5f;
    self.iconIv.frame = CGRectMake(ceilf((self.pageView.bounds.size.width - 205)/2), originY, iconWidth, 80);
    originY += 80 + 25.0;
    self.inputView.frame = CGRectMake(15.0, originY, self.pageView.bounds.size.width - 15*2, 70.0);
    originY += 70.0 + 20.0f;
    CGFloat x = ceilf((self.pageView.bounds.size.width-320.0)/2);
    self.menuView.frame = CGRectMake(x, originY, self.pageView.bounds.size.width-x*2, 160.0f);
    if ([UIScreen mainScreen].bounds.size.height < 568.0f) {
//        self.footerView.frame = CGRectMake(x, self.pageView.frame.size.height - 30 - 5, self.pageView.bounds.size.width-x*2, 30);
        
    } else {
//        self.footerView.frame = CGRectMake(x, self.pageView.frame.size.height - 30 - 15, self.pageView.bounds.size.width-x*2, 30);
        
    }
    
    [self.menuView resizeForPortrait];
//    [self.footerView resizeForPortrait];
   
    [self.pullDownUsers.view setFrame:[self.pullDownUsers calculateRectWith:[self getPullDownRect] inView:_pageView]];
}

- (void) resizeWhenIpad
{
    CGFloat y = 30.0;
    CGFloat w = 440.0;
//    CGFloat imageW = self.loginbcImage.image.size.width;
//    CGFloat imageH = self.loginbcImage.image.size.height;
//    [self.loginbcImage setHeight:self.view.frame.size.width * imageH / imageW] ;
//    self.pageView.frame = CGRectMake(ceilf((self.view.bounds.size.width - w)/2), 0, w, self.view.bounds.size.height);
//    float iconWidth = 120.0f;
//    self.iconIv.frame = CGRectMake(ceilf((self.pageView.bounds.size.width-iconWidth)/2), y, iconWidth, 80);
//    y += 80 + 30.0;
//    self.inputView.frame = CGRectMake(0.0, y, self.pageView.bounds.size.width, 90.0);
//    y += 90.0 + 12.0;
//    self.menuView.frame = CGRectMake(0, y, self.pageView.bounds.size.width, 150.0);
//    self.tfAccount.font = [UIFont systemFontOfSize:16];
//    [self.menuView resizeForiPad];
////    self.footerView.frame = CGRectMake(0, self.pageView.frame.size.height - 20 - 40, self.pageView.bounds.size.width, 40);
//
////    [self.footerView resizeForiPad];
//
//    [self.pullDownUsers.view setFrame:[self.pullDownUsers calculateRectWith:[self getPullDownRect] inView:_pageView]];
    
    self.pageView.frame = CGRectMake(ceilf((self.view.bounds.size.width - w)/2), 0, w, self.view.bounds.size.height);
   
  
    float iconWidth = 120.0f;
    self.iconIv.frame = CGRectMake(ceilf((self.pageView.bounds.size.width-iconWidth)/2), y, iconWidth, 80);
    y += iconWidth + 30.0;
    self.inputView.frame = CGRectMake(0, y, w-142.0, 90.0);
    self.menuView.frame = CGRectMake(0, y, w, 200.0);
    //    self.footerView.frame = CGRectMake(ceilf((self.view.bounds.size.width - w)/ 2), self.pageView.frame.size.height - 30 - 10, w, 30);
    
    [self.menuView resizeForiPad];
    //    [self.footerView resizeForLandscape];
    
    CGFloat registerAgreement_X = 0.0f;
    CGFloat registerAgreement_Y = 0.0f;
    if ((iPad_P) || (iPad_L)) {
        registerAgreement_X = -20;
        registerAgreement_Y = _inputView.frame.origin.y + 200;
    }
    
    self.registerAgreement.frame = CGRectMake(registerAgreement_X, registerAgreement_Y, self.pageView.bounds.size.width, 150);
    
    [self.pullDownUsers.view setFrame:[self.pullDownUsers calculateRectWith:[self getPullDownRect] inView:_pageView]];
}


#pragma mark- UITextField Delegate

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isEqual:self.tfAccount]) {

        [self.tfSecret becomeFirstResponder];
        [self.pullDownUsers dismissPullDown];
        
    }else if ([textField isEqual:self.tfSecret]){
        [self.view endEditing:YES];
        [self doLoginAction:nil];
    }
    return YES;
}


@end
