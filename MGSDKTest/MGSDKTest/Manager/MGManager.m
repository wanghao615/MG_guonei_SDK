
//
//  MGManager.m
//  MYGameManagerTest
//
//  Created by Eason on 21/04/2014.
//  Copyright (c) 2014 MG. All rights reserved.
//

#import "MGManager.h"
#import "MGLoginViewController.h"
#import "MGRegisterController.h"
#import "MGBaseNavController.h"
#import "MGAlertView.h"
#import "MGHttpClient.h"
#import "MGStorage.h"
#import "MGUtility.h"
#import "MGToolBar.h"
#import "MGStatistics.h"
#import "MGToolBarParent.h"
#import "MGToolBarLeftView.h"


#import "MGKeyWindow.h"

#import "MGManager+MGUserInfo.h"
#import "MGAlertViewX.h"
#import <objc/runtime.h>

#import "MGClearVC.h"
#import "MGUserDefault.h"
#import "MGShowTipsView.h"
#import "MGBind.h"
#import "MGInAppPurchaseTool.h"
#import "MGConfiguration.h"
#import "MGBindAlertView.h"
#import "MGIdentityVerificationAlertView.h"
#import "XYProtectionController.h"
#import <WebKit/WKWebView.h>
#import "MGKeyChain.h"


static NSString* const MGSDKVersion = @"4.0.0";

const NSUInteger k_AutoLogin = 999;

NSString* const kMGPlatformLogoutNotification = @"kMGPlatformLogoutNotification";

NSString* const kMGPlatformInitDidFinishedNotification = @"MGPlatformInitDidFinishedNotification";


NSString* const kMGPlatformErrorKey = @"ret";
NSString* const kMGPlatformErrorMsg = @"errMsg";


NSString* const RESOURCE_ID = @"1359135";

BOOL MG_DEBUG_LOG = NO;


@interface MGManager ()<UINavigationControllerDelegate, MGDialogAlertViewDelegate, UIAlertViewDelegate,MGToolBarLeftViewDelegate,MGIdentityVerificationAlertViewDelegate>
{
//    NSString *_MG_APPID;
//    NSString *_MG_APPKEY;
    NSString *_MG_RESOURCE_ID;
    BOOL _MGUserLogined;
    BOOL _MGGuestLogined;
    BOOL _bAccpetWhenCheckUpdateFaild;
    BOOL _bNeedInitPlatform;
   
    BOOL _bCustomGameWindow;
    UIWindow *customeGameWindow;
    
    CGRect _appWindowFrame;
    
    MGToolBar *_MGToolBar;
    MGStatistics *_statistics;
    
}

@property (nonatomic, strong, readwrite) NSString *MG_APPID;
@property (nonatomic, strong, readwrite) NSString *MG_APPKEY;
@property (nonatomic, strong, readwrite) NSString *Private_URL;
@property (nonatomic, assign, readwrite) UIInterfaceOrientation mInterfaceOrientation;
@property (nonatomic, strong, readwrite) NSString *currentLoginAccount;
@property (nonatomic, assign, readwrite) BOOL isDebugModel;
@property (nonatomic, strong) MGIdentityVerificationAlertView *IdentityVerificationAlert;

@property (nonatomic, strong) MGToolBarParent *toolBarParent;

@property (nonatomic, strong) MGKeyWindow *clearWindow;  // window
@property (nonatomic, weak) UIWindow *appWindow;

- (BOOL) MGUserLogined;

- (void) openMGViewController:(UIViewController *) vc;

@property (nonatomic, strong) MGClearVC *clearVC;

@property (nonatomic, strong) MGShowTipsView *dialogAlert;

//记录防沉迷状态
@property(nonatomic,strong)NSString *idCardStats;

@end



@implementation MGManager


+ (MGManager *)defaultManager
{
    static MGManager* defaultManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultManager = [[MGManager alloc] init];
    });
    
    return defaultManager;
}




// 备用
- (void) setValue:(id)value forKeyPath:(NSString *)keyPath
{
    if ([keyPath isEqualToString:@"gamewindow"]) {
        
        _bCustomGameWindow = YES;
        customeGameWindow = value;
        
    }else
        [super setValue:value forKeyPath:keyPath];
}

- (NSString *)Private_URL {
    return _Private_URL;
}

- (UIWindow *) appWindow
{
    if (_bCustomGameWindow && customeGameWindow != nil) {
        
        if (CGRectIsEmpty(_appWindowFrame)) {
            _appWindowFrame = customeGameWindow.frame;
        }
        return customeGameWindow;
    }
    
    UIWindow *window;
    NSArray *windows = [[UIApplication sharedApplication] windows];
    for (UIWindow *w in windows) {
        
        if (TT_IS_IOS6_AND_UP) {
            if (![w isKindOfClass:[MGKeyWindow class]] && w.windowLevel == UIWindowLevelNormal  && !w.isHidden) {
                window = w;
                break;
            }
        }else{
            if (![w isKindOfClass:[MGKeyWindow class]] && w.windowLevel == UIWindowLevelNormal) {
                window = w;
                break;
            }
        }
        
    }
    
    if (window != nil && CGRectIsEmpty(_appWindowFrame)) {
        _appWindowFrame = window.frame;
    }
    
    return window;
}

- (MGClearVC *)clearVC
{
    if (!_clearVC) {
        _clearVC = [[MGClearVC alloc] init];
    }
    return _clearVC;
}



- (MGKeyWindow *) clearWindow
{
    if (!_clearWindow) {
        _clearWindow = [[MGKeyWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        [_clearWindow setBackgroundColor:[UIColor clearColor]];
        _clearWindow.rootViewController = self.clearVC;
    }
    return _clearWindow;
}

- (instancetype) init
{
    if (self = [super init]) {
        
        _appWindowFrame = CGRectZero;
        
        
         __block WKWebView * webView = [[WKWebView alloc] init];
         [webView evaluateJavaScript:@"navigator.userAgent" completionHandler:^(id _Nullable result, NSError * _Nullable error) {
             
             [MGKeyChain mgKeyChainSave:KEY_UA data:result?result:@""];
             [webView removeFromSuperview];
             webView = nil;
         }];
        webView.hidden = YES;
        [[UIApplication sharedApplication].delegate.window addSubview:webView];
        
        
        _statistics = [MGHttpClient shareMGHttpClient].statistics;
        
        BOOL bFL = [[MGUserDefault defaultUserDefaults] boolValueForKey:@"MG_firstlauch"];
        if (!bFL) {  // 第一次登录，清除keychain
            [[MGUserDefault defaultUserDefaults] setBoolValue:YES forKey:@"MG_firstlauch"];
        }

        self.mInterfaceOrientation = UIInterfaceOrientationMaskAll;
        
        [self initClearWindow];
        
        [self addNotificationObserver];
        
    }
    return self;
}

- (void)addNotificationObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivePlatformDismissNoti:) name:kMGPlatform_Dismiss_Noti object:nil];
    
    /*登录通知*/
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(MGplatformLoginNoti:)
                                                 name:kMGPlatformLoginNotification
                                               object:nil];
}



#pragma mark-- initClearWindow importent

- (void) initClearWindow
{
    self.clearWindow = [[MGKeyWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.clearWindow setBackgroundColor:[UIColor clearColor]];

}

- (void) openMGViewController:(UIViewController *) vc
{
    
//    MG_LOG(@"即将进入平台界面，当前keywindow ：%@", [[UIApplication sharedApplication] keyWindow]);
    
    BOOL bFL = [[MGUserDefault defaultUserDefaults] boolValueForKey:@"Protocol_firstlauch"];
    if (!bFL) {  // 第一次登录，清除keychain
        self.clearWindow.rootViewController = nil;
        XYProtectionController *protectionView = [[XYProtectionController alloc]init];
        __weak typeof(self) weakself = self;
        [protectionView setAgreeStatus:^(BOOL agreeStatus) {
            [[MGUserDefault defaultUserDefaults] setBoolValue:YES forKey:@"Protocol_firstlauch"];
            weakself.clearWindow.rootViewController = nil;
            weakself.clearWindow.rootViewController = vc;
        }];
        MGBaseNavController *proNav = [[MGBaseNavController alloc]initWithRootViewController:protectionView];
        self.clearWindow.rootViewController = proNav;
    }else{

        self.clearWindow.rootViewController = nil;
        self.clearWindow.rootViewController = vc;

    }
    

    [self.clearWindow makeKeyAndVisible];
    
    
//    MG_LOG(@"已经进入平台界面，当前keywindow ：%@", [[UIApplication sharedApplication] keyWindow]);
}

- (MGBaseNavController *) newMGNavigationControllerWithAction:(MGAction) action rootVc:(UIViewController *) rootVc
{
    MGBaseNavController *navi = [[MGBaseNavController alloc] initWithRootViewController:rootVc];
    navi.navigationBar.translucent = NO;
    navi.navigationBar.clipsToBounds = YES;
    UIImage *iv = [[MGUtility MGImageName:@"MG_navi_bg.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:40];
    [navi.navigationBar setBackgroundImage:iv forBarMetrics:UIBarMetricsDefault];
    navi.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    return navi;
}


- (MGPlatformLeavedType)leavedTypeForTag:(int)tag {
    MGPlatformLeavedType levelType = -1;
    if (tag == MGActionLogin) {
        levelType = MGPlatformLeavedFromLogin;
    }else if (tag == MGActionRegister){
        levelType = MGPlatformLeavedFromRegister;
    }else if (tag == MGActioncoshow){
        levelType = MGPlatformLeavedFromcoshow;
    }else if (tag == MGActionSNSCenter){
        levelType = MGPlatformLeavedFromSNSCenter;
    }else if (tag == MGActionNoAction){
        levelType = MGPlatformLeavedDefault;
    }else if (tag == MGActionNothing){
        
    }
    return levelType;
}

- (void) receivePlatformDismissNoti:(NSNotification *) noti
{
    __block int tag = [noti.object intValue];
    __block MGPlatformLeavedType levelType = [self leavedTypeForTag:tag];
    
    [MGSVProgressHUD dismiss];
    
    NSDictionary *notiUserInfo = noti.userInfo;
    
    if (notiUserInfo != nil && [[notiUserInfo objectForKey:@"action"] isEqualToString:@"ShowGreet"]) {
        _MGUserLogined = YES;
        _MGGuestLogined = [[notiUserInfo objectForKey:@"isGuest"] boolValue];
    }

    
    [UIView animateWithDuration:0.2 delay:0.1 options:UIViewAnimationOptionCurveLinear animations:^{
        self.clearWindow.alpha = 0.0;
    } completion:^(BOOL finished) {
        
        [self compleWithDismissNoti:noti tag:tag levelType:levelType];

    }];
}

- (void)compleWithDismissNoti:(NSNotification *) noti tag:(int)tag levelType:(MGPlatformLeavedType)levelType {
    NSDictionary *notiUserInfo = noti.userInfo;
    //        MG_LOG(@"即将离开平台界面，当前keywindow ：%@", [[UIApplication sharedApplication] keyWindow]);
    
    self.clearWindow.alpha = 1.0;
    self.clearWindow.rootViewController = nil;
    self.clearWindow.rootViewController = self.clearVC;
    [self.clearWindow setHidden:YES];
    
    [self.appWindow makeKeyAndVisible];
    
    
    //        MG_LOG(@"已经离开平台界面，当前keywindow ：%@", [[UIApplication sharedApplication] keyWindow]);
    
//    if (notiUserInfo != nil && [[notiUserInfo objectForKey:@"action"] isEqualToString:@"ShowGreet"]) {
//        [self performSelector:@selector(receiveShowGreetViewNoti:) withObject:nil afterDelay:0.2];
//    }
    
    if (tag == MGActionInitPlatform) {
        
        [MGStorage initializationMGStorage];  // 初始化存储系统
        [[NSNotificationCenter defaultCenter] postNotificationName:kMGPlatformInitDidFinishedNotification object:nil userInfo:nil];
        [self addObservers];
        
    }
    
    if (tag != MGActionInitPlatform && tag != MGActionNothing) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kMGPlatformLeavedNotification object:[NSNumber numberWithInt:levelType] userInfo:nil];
    }
    
}


- (void) receivePlatformGuestTurnOfficalNoti:(NSNotification *) noti
{
    _MGGuestLogined = NO;
}

#pragma mark-- GreetView

//- (void) receiveShowGreetViewNoti:(id)sender
//{
////    MGGreetView *greetView = [[MGGreetView alloc] init];
////    [greetView performSelector:@selector(showGreetViewNow) withObject:nil afterDelay:0.4];
//}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


//*********************************************************************************************
#pragma mark-- 消息


- (MGToolBarParent *) toolBarParent
{
    if (!_toolBarParent) {
        if (I_PHONE_X) {
            _toolBarParent = [[MGToolBarParent alloc] initWithFrame:CGRectMake(30, 0, [UIScreen mainScreen].bounds.size.width - 60, [UIScreen mainScreen].bounds.size.height)];
        }else{
            _toolBarParent = [[MGToolBarParent alloc] initWithFrame:[UIScreen mainScreen].bounds];
        }
    }
    return _toolBarParent;
}

- (UIWindow *) currentKeyWindow
{
    return [[UIApplication sharedApplication] keyWindow];
}


+ (NSString*)sdkVersion
{
    return MGSDKVersion;
}

- (UIViewController *) topViewController
{
    UIViewController *vc = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (vc.presentedViewController) {
        vc = vc.presentedViewController;
    }
    return vc;
}

- (void) initializeWithAppId:(NSString *) appId appKey:(NSString *) appKey isContinueWhenCheckUpdateFailed:(BOOL)isAccept
{
    _MG_APPID = appId;
    _MG_APPKEY = appKey;
    _bAccpetWhenCheckUpdateFaild = isAccept;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];


    _bNeedInitPlatform = YES;
    
   
    
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        
        [_statistics userEncript];
        
        
        [self openInitViewController];
       
    }  // 否则等待becomactive
}



- (void) openInitViewController
{
    MG_LOG(@"qmqj 打开初始化界面");
    
//    MGInit *MGInit = [[MGInit alloc] initWithAccpetWhenCheckUpdateFaild:_bAccpetWhenCheckUpdateFaild];
//    [self openMGViewController:MGInit];
    
    _bNeedInitPlatform = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:kMGPlatform_Dismiss_Noti object:[NSNumber numberWithInteger:MGActionInitPlatform]];
//    [self MGShowToolBar:MGToolBarAtMiddleRight isUseOldPlace:false];

}

- (NSString *) transOrientation:(UIInterfaceOrientation) orientation
{
    if (orientation == UIInterfaceOrientationLandscapeLeft) {
        return @"UIInterfaceOrientationLandscapeLeft";
    }else if (orientation == UIInterfaceOrientationLandscapeRight){
        return @"UIInterfaceOrientationLandscapeRight";
    }else if (orientation == UIInterfaceOrientationPortrait){
        return @"UIInterfaceOrientationPortrait";
    }else if (orientation == UIInterfaceOrientationPortraitUpsideDown){
        return @"UIInterfaceOrientationPortraitUpsideDown";
    }else
        return @"invalid orientation";
}


- (void)MGSetScreenOrientation:(UIInterfaceOrientation)orientation
{
    self.mInterfaceOrientation = orientation;
    NSArray *oriens = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"UISupportedInterfaceOrientations"];
    NSAssert([oriens containsObject:[self transOrientation:orientation]],  @"设置 mInterfaceOrientation 错误，和app系统设置不匹配");
}

- (void)MGSetDebugModel:(BOOL)debug
{
    self.isDebugModel = debug;
}

- (void) MGSetShowSDKLog:(BOOL)isShow
{
    MG_DEBUG_LOG = isShow;
}

#pragma mark-- WillBecomeActive DidEnterBackground

- (void) appDidBecomeActive:(NSNotification *) noti
{
    if (_bNeedInitPlatform) {
        
        
        [_statistics userEncript];
       
        [self openInitViewController];
    }
}


- (void) willBecomeActive:(NSNotification *) noti  //UIApplicationWillEnterForegroundNotification
{
    NSString *uid = [self MGOpenUID];
    NSString *appid = [self MG_APPID];
    NSString *token = [self MGToken];
    __weak MGManager *weakself = self;
    
    [[MGHttpClient shareMGHttpClient] checkLoginState:uid appId:appid token:token completion:^(NSDictionary *responseDic) {
        TTDEBUGLOG(@"用户已经登录");
        _MGUserLogined = YES;
        
        id obj = responseDic[@"ret"];
        if (obj != nil) {
        }else
            NSLog(@"登录验证异常 res = %@", responseDic);
        
    } failed:^(NSInteger ret, NSString *errMsg) {
        
        _MGUserLogined = NO;

        [weakself performSelector:@selector(MGUserLoginX:) withObject:[NSNumber numberWithInt:k_AutoLogin] afterDelay:0.6];   // 没有登录，首先登录
        if (ret == MG_PLATFORM_ERROR_NETWORK) {   // 若是无网络
            [self performSelector:@selector(showNetworkErrorMsg) withObject:nil afterDelay:1.0];
        }
    }];
}


- (void) didEnterBackground:(NSNotification *) noti
{
    UIApplication *application = noti.object;
    __block UIBackgroundTaskIdentifier backgroundTaskIdentifier =
    [application beginBackgroundTaskWithExpirationHandler:^(void) {
        TTDEBUGLOG(@"endBackgroundTask");
        [application endBackgroundTask:backgroundTaskIdentifier];
    }];

}


- (void) sendAfterVertifyLoginNotification:(NSDictionary *) userInfo
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kMGPlatformLoginNotification object:nil userInfo:userInfo];
}

#pragma mark -- MGPlatform (MGUserCenter)

- (void) addObservers
{
    // 增加监听， 在 游戏app 初始化完毕检查登录时做监听，不能在初始化时做监听， 避免初始化时间长，app回到后台再回到前台还未初始化完出现登录界面
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willBecomeActive:) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadUserInfo:) name:kMGPlatformReloadUserInfoNitifaication object:nil];
}

- (void)MGIsLogined:(void (^)(BOOL isLogined)) bLogined
{
    NSString *uid = [self MGOpenUID];
    NSString *appid = [self MG_APPID];
    NSString *token = [self MGToken];
    [[MGHttpClient shareMGHttpClient] checkLoginState:uid appId:appid token:token completion:^(NSDictionary *responseDic) {
        
        id obj = responseDic[@"ret"];
        if (obj != nil) {
            
            BOOL bGuestLogin = NO;
            NSString *guestUid = [MGStorage getGuestUid];
            if ([guestUid length] > 0 && [guestUid isEqualToString:uid]) {
                bGuestLogin = YES;
            }
            if (bGuestLogin && ![self MGIsGuestLogined]) {  //游客的话 必须手动登录之后才会返回 YES
                if (bLogined) {
                    bLogined(NO);
                }
            }else{
                if (bLogined && _MGUserLogined)
                    bLogined(YES);
                else
                    bLogined(NO);
            }
        }
        
    } failed:^(NSInteger ret, NSString *errMsg) {
        if (bLogined) bLogined(NO);
    }];
}

#pragma mark -- MGPlatform (IAP)



- (void)MGIAPStartRequestProductsArray:(NSArray *)array WithDelegate:(id <MGIAPDelegate>)delegate {
    
    //获取单例
    MGInAppPurchaseTool *tool = [MGInAppPurchaseTool defaultTool];
    
    
    //向苹果询问哪些商品能够购买 //设置代理
    
    [tool getProductArray:array WithDelegate:delegate];
    
}

-(void)MGBuyProduct:(MGIAPModel *)product withBuyModel:(MGIAPBuyModel *)model buyStatus:(IAPBuyStatusBlock)buyStatus  {
    
    [[MGHttpClient shareMGHttpClient] rechargeVerificationOfAgeWithParams:@{ @"amount" : model.amount } completion:^(NSDictionary *responseDic) {
        
        [[MGInAppPurchaseTool defaultTool] orderForProduct:product.productIdentifier  sid:model.SID rmb:model.amount product_id:model.productId product_name:model.productName openuid:model.openUID app_name:model.appName app_order_id:model.appOrderID app_user_name:model.appUserName resource_id:RESOURCE_ID package_name:model.packageName device_type:model.deviceType app_key:model.appkey callback_url:model.callback_url appuser_id:model.appUserID real_price:model.real_price];
        if (buyStatus) {
            buyStatus(10000);
        }
        
    } failed:^(NSInteger ret, NSString *errMsg) {
        
        UIAlertView *alertDialog;
        alertDialog = [[UIAlertView alloc]
                       initWithTitle:@"温馨提示"
                       message:errMsg
                       delegate:nil
                       cancelButtonTitle:@"OK"
                       otherButtonTitles: nil];
        [alertDialog show];
        
    }];
    if (buyStatus) {
        buyStatus(10001);
    }
}


-(void)restoreProduct{
    
    [[MGInAppPurchaseTool defaultTool]restorePurchase];
}



#pragma mark-- ------------- 自动登录 began--------------------------------------------------
// 检查用户登录状态， 可设置若没登录弹出登录界面， 和 上 willBecomeActive 方法检查一样

- (int) MGAutoLogin:(int) iflag
{
    
    MGAccountSettingInfo *info = [MGStorage currentAccountSettingInfo];
    if (info != nil) {
        if (info.isGuestAccount) {
            return [self MGUserGuestLogin:0];
        }else
            return [self MGUserLoginType:MGLoginTypeAutoLogin];
    }else
        return [self MGUserLoginType:MGLoginTypeAutoLogin];
    
    
/*
    [self MGCheckUserLoginStatus:^(BOOL isLogined) {
        
    } displayLoginViewWhenNotInLoginStatus:YES bSendNotification:YES];
    
    return YES;
*/
}

// autoLogin 专用，其他用小心，设置判断较多
- (void) MGCheckUserLoginStatus:(void (^)(BOOL isLogined)) loginStatus displayLoginViewWhenNotInLoginStatus:(BOOL)bDisplayLoginView bSendNotification:(BOOL) bSendNoti
{
    
    NSString *uid = [self MGOpenUID];
    NSString *appid = [self MG_APPID];
    NSString *token = [self MGToken];
    __block BOOL bDisplay_ = bDisplayLoginView;
    __block BOOL bSendNoti_ = bSendNoti;
    __weak MGManager *weakself = self;
    [[MGHttpClient shareMGHttpClient] checkLoginState:uid appId:appid token:token completion:^(NSDictionary *responseDic) {

        id obj = responseDic[@"ret"];
        if (obj != nil) {
            
            BOOL bGuestLogin = NO;
            NSString *guestUid = [MGStorage getGuestUid];
            if ([guestUid length] > 0 && [guestUid isEqualToString:uid]) {
                bGuestLogin = YES;
            }
            
            if (bGuestLogin) {  //检查用户登录状态时候，若是游客 不执行任何操作，跳转到登录界面
                [weakself performSelector:@selector(MGUserGuestLogin:) withObject:nil afterDelay:0];
            }else{
                _MGUserLogined = YES;
                if (loginStatus) {
                    loginStatus(YES);
                }
            
                if (bSendNoti_) {
                    [weakself performSelector:@selector(sendAfterVertifyLoginNotification:) withObject:@{kMGPlatformErrorKey: obj} afterDelay:0];
                    MG_LOG(@"登录验证成功：\n当前登录Account:%@ \nuid:%@ \ntoken:%@", [self MGLoginUserAccount], uid, token);
                }else
                    MG_LOG(@"已经登录状态 不发送通知：\n当前登录Account:%@ \nuid:%@ \ntoken:%@", [self MGLoginUserAccount], uid, token);
            }
            
        }else{
            NSLog(@"登录验证异常 check res = %@", responseDic);
        }
        
    } failed:^(NSInteger ret, NSString *errMsg) {
        
        
        BOOL bGuestLogin = NO;
        NSString *guestUid = [MGStorage getGuestUid];
        if ([guestUid length] > 0 && [guestUid isEqualToString:uid]) {
            bGuestLogin = YES;
        }
        if (bGuestLogin) {
            
            [weakself performSelector:@selector(MGUserGuestLogin:) withObject:nil afterDelay:0];
            
        }else{
            _MGUserLogined = NO;
            if (bSendNoti_) {
                [weakself performSelector:@selector(sendAfterVertifyLoginNotification:) withObject:@{kMGPlatformErrorKey: [NSNumber numberWithInteger:ret], kMGPlatformErrorMsg:errMsg} afterDelay:0];
            }
            if (loginStatus) {
                loginStatus(NO);
            }
        
            if (bDisplay_) {

                MG_LOG(@"不在登录状态，自动登录：\n当前登录Account:%@ \nuid:%@ \ntoken:%@", [self MGLoginUserAccount], uid, token);

                [weakself performSelector:@selector(MGUserLoginX:) withObject:[NSNumber numberWithInt:k_AutoLogin] afterDelay:0.8];    // 自动登录
                if (ret == MG_PLATFORM_ERROR_NETWORK) {   // 若是无
                    [self performSelector:@selector(showNetworkErrorMsg) withObject:nil afterDelay:1.2];
                }
            }else
                MG_LOG(@"不在登录状态 \n当前登录Account:%@ \nuid:%@ \ntoken:%@", [self MGLoginUserAccount], uid, token);
        }
    }];
}






#pragma mark-- ------------- 自动登录 end--------------------------------------------------


- (void) showNetworkErrorMsg
{
    [MGSVProgressHUD showErrorWithStatus:@"网络错误，请检查网路"];
}


- (BOOL) MGUserLogined
{
    MGAccountSettingInfo *info = [MGStorage currentAccountSettingInfo];
    BOOL bLogin = _MGUserLogined || (info != nil && [info.account length] > 0 && [info.uid length] > 0 && [info.token length] > 0);
    return bLogin;
}


- (int) MGUserLoginX:(NSNumber *)lFlag  //自动登录
{
    return [self MGUserLoginType:MGLoginTypeAutoLogin];
}


- (int)MGUserLogin:(int)lFlag
{
    return [self MGUserLoginType:MGLoginTypeNormal];
}

- (int) MGUserGuestLogin:(int) lFalg
{
    return [self MGUserLoginType:MGLoginTypeGuest];
}

- (int) MGUserLoginType:(MGLoginType) type
{
    if ([[self topViewController] isKindOfClass:[MGBaseNavController class]]) {
        return -1;
    }
    
    if ([self checkIsInitialized]) {
        
        [self openloginVCWithType:type];
    }
    
    return 0;
}
- (void)openloginVCWithType:(MGLoginType) type {
    MGLoginViewController *loginVc = [[MGLoginViewController alloc] initWithLoginType:type];
    loginVc.MGAction = MGActionLogin;
    [self openMGViewController:[self newMGNavigationControllerWithAction:MGActionLogin rootVc:loginVc]];
}


- (int)MGUserRegister:(int)rFlag
{
    if ([[self topViewController] isKindOfClass:[MGBaseNavController class]]) {
        return -1;
    }

    if ([self checkIsInitialized]) {
       
    }

    return 0;
}

- (void)openRegisterVC {
    MGRegisterController* registerController = [[MGRegisterController alloc] init];
    registerController.MGAction = MGActionRegister;
    [self openMGViewController:[self newMGNavigationControllerWithAction:MGActionRegister rootVc:registerController]];
}

- (NSString *) MGToken
{
    MGAccountSettingInfo *info = [MGStorage currentAccountSettingInfo];
    if (info.token == nil) {
        return @"";
    }

    return info.token;
}

- (NSString *) MGOpenUID
{
    MGAccountSettingInfo *info = [MGStorage currentAccountSettingInfo];
    if (info.uid == nil) {
        return @"";
    }

    return info.uid;
}

- (void)MGPhoneStatus:(resultCompletion)Completion {
    
    MGAccountSettingInfo *info = [MGStorage currentAccountSettingInfo];
    if ([info.phoneStatus isEqualToString:@"0"]) {
        
        Completion(@"0",false);
        
    }else if (info.phoneNum.length == 11&&[info.phoneStatus isEqualToString:@"1"]) {
        Completion(info.phoneNum,YES);
    }else {
        
        if ([info.uid length] == 0 || [info.token length] == 0) {
            return;
        }
        
        [[MGHttpClient shareMGHttpClient] getUserInfoByuser:info completion:^(NSDictionary *responseDic) {
            
            id obj = responseDic[@"data"];
            if ([obj isKindOfClass:[NSDictionary class]]) {
                
                info.phoneNum = [NSString stringWithFormat:@"%@", obj[@"phone"]];
                [MGStorage setOneAccountSettingInfo:info isCurrentAccount:YES];
                
                Completion(info.phoneNum,YES);
                
            }
            
        } failed:^(NSInteger ret, NSString *errMsg) {
            
            Completion(@"0",false);
            
        }];
    }
    
}
- (BOOL) MGidCardStatus
{
    MGAccountSettingInfo *info = [MGStorage currentAccountSettingInfo];
    if ([info.idCardBindStatus isEqualToString:@"1"]) {
        return YES;
    }else{
        return false;
    }
}

- (NSString *)MGIDCardAdult {
    MGAccountSettingInfo *info = [MGStorage currentAccountSettingInfo];
    return info.is_adult;
}

- (NSString *) MGLoginUserAccount
{
    if ([self MGUserLogined]) {
        MGAccountSettingInfo *info =  [MGStorage currentAccountSettingInfo];
        return info.account;
    }else
        return nil;
}


- (void) MGSwitchAccount;
{
    [self MGLogout:0];
    [self MGUserLogin:0];
}

- (BOOL)MGIsGuestLogined {
    return _MGGuestLogined;
}



#pragma mark - 登录成功身份验证

- (void)MGplatformLoginNoti:(NSNotification*)notification
{
    // 登录完成, 提供token 以及 openuid 给游戏校验
    NSDictionary *userInfo = notification.userInfo;
    if ([userInfo[kMGPlatformErrorKey] intValue] == MG_PLATFORM_NO_ERROR) {
        
        //登录成功
        [self MGShowToolBar:MGToolBarAtMiddleRight isUseOldPlace:false];
        
        //清除cookie
        [self clearCookie];
        
        //获取app信息
        [self ewruioznemnybhjzbhcx];
        
        //弹框
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self alertBindView];
         
        });
  
    }
}

- (void)ewruioznemnybhjzbhcx {
    
    [[MGHttpClient shareMGHttpClient]getAppinfoCompletion:^(NSDictionary *responseDic) {
        NSDictionary *dict = responseDic[@"data"];
        if (dict != nil) {
//            1.审核后 中国用户可以购买，国外用户弹出温馨提示
//            2.审核中 中国 美国 可以购买成功 并且发货 其它地区弹出温馨提示
 //         0 审核中           1审核后
            if ([[dict objectForKey:@"limit"] isEqualToString:@"0"]) {
                [MGInAppPurchaseTool defaultTool].priceLocaleInCheck = @"en_CN@currency=CNY";
            }else {
                [MGInAppPurchaseTool defaultTool].priceLocaleInCheck = nil;
            }
        }
        
    } failed:^(NSInteger ret, NSString *errMsg) {
        
    }];
}

- (void)clearCookie {
    NSURL *url = [NSURL URLWithString:@"https://adapi.mg3721.com"];
//    NSURL *url = [NSURL URLWithString:@"https://dev.mg3721.com"];
    if (url) {
        NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:url];
        for (int i = 0; i < [cookies count]; i++) {
            NSHTTPCookie *cookie = (NSHTTPCookie *)[cookies objectAtIndex:i];
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
            
        }
    }
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}


#pragma mark - 防沉迷验证 began ------------------------------------------
- (BOOL)isShowAlertView {
    MGAccountSettingInfo *info = [MGStorage currentAccountSettingInfo];
    /*
      1.auth_login  0开启(非强制) 1开启(强制) 2关闭
      2.isAll 0 需要全部用户弹 1只弹未绑定手机的用户
     */
    if ([[MGConfiguration shareConfiguration].auth_login isEqualToString:@"2"]) {
        return false;
    }else{
        if ([info.idCardBindStatus isEqualToString:@"0"]) {
            return YES;
        }else{
            return false;
        }
    }
}
- (void)alertBindView {
    if ([self isShowAlertView] == YES) {
        
        [self.IdentityVerificationAlert show];
        return ;
    }
}


- (MGIdentityVerificationAlertView *)IdentityVerificationAlert {
    
    if (_IdentityVerificationAlert == nil) {
        NSString *title = @"填写身份证认证信息";
        NSString *msgStr = @"根据《国家新闻出版署关于防止未成年人沉迷网络游戏工作的通知》要求，网络游戏用户需进行实名认证，请先实名认证后再进入游戏。";
        CGFloat w = TT_IS_IPAD ? 420 : 290;
        _IdentityVerificationAlert = [[MGIdentityVerificationAlertView alloc] initWithCancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        
        MGIdentityVerificationContainerView *view = [[MGIdentityVerificationContainerView alloc] initWithWidth:w title:title message:msgStr];
        [view setMessageAlignment:NSTextAlignmentLeft];
//        [view setMessageColor:[UIColor blackColor]];
        [view addVerifyIdentidyView];
        view.alertVC = _IdentityVerificationAlert.rootVC;
        
        _IdentityVerificationAlert.shouldUpdateButtonsUIWhenLandscape = YES;
        [_IdentityVerificationAlert setContainerView:view];
        _IdentityVerificationAlert.alertDelegate = self;
    }
    
    return _IdentityVerificationAlert;
}

#pragma mark - MGIdentityVerificationAlertViewDelegate

- (void)MGIdentityVerificationAlertView:(MGIdentityVerificationAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0) {
        
        [self IdentityVerificationSubmitCompleteInfo:alertView];
    } else {
        [alertView dismiss];
        
        [_IdentityVerificationAlert.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        _IdentityVerificationAlert = nil;
        //auth_login  0开启(非强制) 1开启(强制) 2关闭
        if ([[MGConfiguration shareConfiguration].auth_login isEqualToString:@"1"]) {
            [self MGUserLogin:0];
        }
    }
}


- (void)MGIdentityVerificationAlertViewEndTextFieldsEditing:(MGIdentityVerificationAlertView *)alertView {
    [self IdentityVerificationSubmitCompleteInfo:alertView];
}


- (void)showIdentityVerificationAlertViewString:(NSString*)alertString
{
    if (IPHONE_8_UP) {
        
        [UIAlertView showWithTitle:nil
                           message:alertString
                 cancelButtonTitle:@"确定"
                 otherButtonTitles:nil
                          tapBlock:^(UIAlertView* alertView, NSInteger buttonIndex) {
                          }];
    }else
        [MGSVProgressHUD showErrorWithStatus:alertString];
}


- (void)IdentityVerificationSubmitCompleteInfo:(MGIdentityVerificationAlertView *)alertView {
    
    NSString *name = alertView.inputStrings[0];
    NSString *idCardNum = alertView.inputStrings[1];
    
    if (![MGUtility validateName:name andErrorMsg:^(NSString *errorMsg) {
        MGAlertCustomView *alerView = [[MGAlertCustomView alloc]alerViewWithMessige:errorMsg withType:AlertTypeWithSure];
        __weak typeof(alerView) weakalert = alerView;
        alerView.handler = ^(NSInteger index){
            if (index == 1) {
                [weakalert dissmiss];
            }
        };
        [alerView show];
        
    }])
    {
        return;
    }
    
    if (![MGUtility validateIdCardNum:idCardNum andErrorMsg:^(NSString *errorMsg) {
        MGAlertCustomView *alerView = [[MGAlertCustomView alloc]alerViewWithMessige:errorMsg withType:AlertTypeWithSure];
        __weak typeof(alerView) weakalert = alerView;
        alerView.handler = ^(NSInteger index){
            if (index == 1) {
                [weakalert dissmiss];
            }
        };
        [alerView show];
        
    }])
    {
        return;
    }
    
    __block MGIdentityVerificationAlertView *alert = alertView;
    
    MGUserIdCard *userInfo = [[MGUserIdCard alloc]init];
    userInfo.name = name;
    userInfo.idCard = idCardNum;
    __weak typeof(self) weakSelf = self;
    [self bindIdCard:userInfo completion:^(BOOL success) {
        if (success) {
            [alert dismiss];
        }
    }];
}

- (void)bindIdCard:(MGUserIdCard *)userInfo completion:(void (^)(BOOL success))block {
    [MGSVProgressHUD showWithStatus:@"身份认证中..." maskType:MGSVProgressHUDMaskTypeClear];
    __weak typeof(&*self) weakSelf = self;
    [[MGHttpClient shareMGHttpClient] bindIdCard:userInfo completion:^(NSDictionary *responseDic) {
        
        MGAccountSettingInfo *info = [MGStorage currentAccountSettingInfo];
        info.idCardBindStatus = @"1";
        
        info.is_adult = @"2";
        NSString *borthDateStr = [userInfo.idCard substringWithRange:NSMakeRange(6, 8)];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"YYYYMMdd"];
        NSDate *borthDate = [dateFormatter dateFromString:borthDateStr];
        //获得当前系统时间
        NSDate *currentDate = [NSDate date];
        //获得当前系统时间与出生日期之间的时间间隔
        NSTimeInterval time = [currentDate timeIntervalSinceDate:borthDate];
        //时间间隔以秒作为单位,求年的话除以60*60*24*356
        int age = ((int)time)/(3600*24*365);
        if (age >= 18) {
            info.is_adult = @"1";
        }else {
            info.is_adult = @"0";
        }
        
        [MGStorage setOneAccountSettingInfo:info isCurrentAccount:YES];
        
        if (block) {
            block(YES);
        }
        weakSelf.IdentityVerificationAlert = nil;
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"认证成功" delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
        [alertView show];
        double delayInSeconds = 1.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            
            
            [alertView dismissWithClickedButtonIndex:0 animated:YES];
        });
        
        
    } failed:^(NSInteger ret, NSString *errMsg) {
        [MGSVProgressHUD dismiss];
        MGAlertCustomView *alerView = [[MGAlertCustomView alloc]alerViewWithMessige:errMsg withType:AlertTypeWithSure];
        __weak typeof(alerView) weakalert = alerView;
        alerView.handler = ^(NSInteger index){
            if (index == 1) {
                [weakalert dissmiss];
            }
        };
        [alerView show];
        //        [MGSVProgressHUD showErrorWithStatus:errMsg];
        
    }];
}






#pragma mark - 防沉迷验证 end --------------------------------------------


- (int) MGGuestRegister:(int) rFlag
{
    if ([self MGIsGuestLogined] && _MGUserLogined) {
        
        [self.dialogAlert show];
        return 0;
    }else
        return 1;
}

- (int)MGLogout:(int)lFlag
{
    // 0: 表示注销但保存本地信息;   1:表示注销, 并清除自动登录
    
    _MGUserLogined = NO;
    _MGGuestLogined = NO;
    
    MGAccountSettingInfo *info = [MGStorage currentAccountSettingInfo];
    if (lFlag == 1) {
        info.bAutoLogin = NO;
        [MGStorage setOneAccountSettingInfo:info isCurrentAccount:NO];
    }else if (lFlag == 0){
        [MGStorage setOneAccountSettingInfo:info isCurrentAccount:YES];
    }
    
    [self sendLogoutNotification];
//    [self MGHideToolBar];
    
    return 0;
}

- (void) sendLogoutNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kMGPlatformLogoutNotification object:nil userInfo:nil];
}

/** =========== discarded code=========== */

- (void) sendLogoutFailNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kMGPlatformLogoutNotification object:nil userInfo:nil];
}

- (void) sendLogoutSuccessNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kMGPlatformLogoutNotification object:nil userInfo:nil];
}

- (void) sendLogoutErrorNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kMGPlatformLogoutNotification object:nil userInfo:nil];
}

/** =========== discarded code=========== */





#pragma mark -
#pragma mark Life Cycle
- (BOOL)checkIsInitialized
{
    if ([self.MG_APPKEY length] == 0 || [self.MG_APPID length] == 0) {
        [[[MGAlertView alloc] initWithTitle:@"提示" message:@"MGPlatform 未初始化" callback:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] show];
        return NO;
    }else
        return YES;
}

- (void) sendNotificationInitFinished
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kMGPlatformInitDidFinishedNotification object:nil userInfo:nil];
}


#pragma mark-- Center


- (void) MGEnterBindPhoneCompletion:(resultBlock)Completion {
    if (![self MGUserLogined] || !_MGUserLogined) { //// 没有登录
        [self MGUserLogin:0];
        return;
    }
    
    MGBind *bindPhone = [[MGBind alloc] initWithBindType:MGBindTypePhone];
    bindPhone.MGAction = MGActionNothing;
    bindPhone.Completion = Completion;
    
    MGBaseNavController *userCenterNavi = [[MGBaseNavController alloc] initWithRootViewController:bindPhone];
    userCenterNavi.navigationBar.translucent = NO;
    userCenterNavi.navigationBar.clipsToBounds = YES;
    UIImage *iv1 = [[MGUtility MGImageName:@"MG_navi_bg.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:40];
    [userCenterNavi.navigationBar setBackgroundImage:iv1 forBarMetrics:UIBarMetricsDefault];
    
    
    [self openMGViewController:userCenterNavi];
    
    
}



#pragma mark-- 数据统计 创角+充值

- (void)MGGameHotStart {
    [_statistics gameHotStart];
}

- (void)MGGameHotEnd {
    [_statistics gameHotEnd];
}

- (void) MGCreateRole:(NSString *)role roleName:(NSString *)roleName gameServer:(NSString *)server
{
    [_statistics createRole:role roleName:roleName gameServer:server];
    
}

- (void) MGRoleLogin:(NSString *)role roleName:(NSString *)roleName gameServer:(NSString *)server level:(NSString *)level occupation:(NSString *)occupation {
    
    [_statistics roleLogin:role roleName:roleName gameServer:server level:(NSString *)level occupation:occupation];
}

- (void) MGOrderNumber:(int)money gameServer:(int)server
{
    
    [_statistics orderNumber:money gameServer:server];
    
    
}

#pragma mark-- ToolBar


- (void)MGShowToolBar:(MGToolBarPlace)place isUseOldPlace:(BOOL)isUseOldPlace
{
    [self MGHideToolBar];
    BOOL bNew = NO;
    if (!_MGToolBar) {
        _MGToolBar = [[MGToolBar alloc] init];
        _MGToolBar.delegate = self.toolBarParent;
        bNew = YES;
    }
    
    if (isUseOldPlace) {
        
        CGRect frame = [MGStorage getToolBarFrame];
        if (CGRectEqualToRect(frame, CGRectZero)) {  // 没有
            
            if (bNew) {
                _MGToolBar.tbPlace = place;
                [self.toolBarParent addSubview:_MGToolBar];
                
                if (self.toolBarParent.superview == nil) {
                    [self.appWindow addSubview:self.toolBarParent];
                }
            }

        }else{
            
            if (CGRectContainsRect(self.toolBarParent.bounds, frame)){
                
                if (bNew) {
                    _MGToolBar.frame = frame;
                    [self.toolBarParent addSubview:_MGToolBar];
                }
                
            }else{
                _MGToolBar.tbPlace = place;
                [self.toolBarParent addSubview:_MGToolBar];
                [MGStorage storeToolBarFrame:_MGToolBar.frame];  //frame 不再对了
            }
            
            if (self.toolBarParent.superview == nil) {
                [self.appWindow addSubview:self.toolBarParent];
            }
            
        }
        
    }else{
        
        _MGToolBar.tbPlace = place;
        [self.toolBarParent addSubview:_MGToolBar];
        
        if (self.toolBarParent.superview == nil) {
            [self.appWindow addSubview:self.toolBarParent];
        }
        
    }
    
    if (bNew) {
        [_MGToolBar resetToolBarDirection];
    }

}
#pragma mark-- MGToolBarDelegate




- (void) MGHideToolBar
{
    [MGStorage storeToolBarFrame:_MGToolBar.frame];
    [_MGToolBar removeFromSuperview];
    _MGToolBar.delegate = nil;
    _MGToolBar = nil;
    [_toolBarParent.leftView removeFromSuperview];
    _toolBarParent.leftView = nil;

}




#pragma mark--  Reload UserInfo

- (void) reloadUserInfo:(NSNotification *) noti
{
    [self MGClearUserInfos];
    [self MGGetUserInfos];
}


#pragma mark-- 


- (NSUInteger) application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    UIInterfaceOrientationMask mask = [self interfaceOrientations];
    
    if (TT_IS_IPHONE) {
    
//        原代码没有执行
        if (NO && ([window isKindOfClass:[MGKeyWindow class]] || window == nil)) {  //
        
            if (![self bIncludeUIInterfaceOrientationMaskPortrait]) {
                mask |= UIInterfaceOrientationMaskPortrait;
            }
        }
        
        if (IPHONE_8_UP) {
            self.appWindow.frame = _appWindowFrame;
        }
    }
    
    return mask;
}

- (BOOL) bIncludeUIInterfaceOrientationMaskPortrait
{
    BOOL bInclude = NO;
    NSArray *oriens = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"UISupportedInterfaceOrientations"];
    for (int i = 0; i < [oriens count]; i++) {
        UIInterfaceOrientationMask mask = [self transformFromUIInterfaceOrientation:[oriens objectAtIndex:i]];
        if (mask == UIInterfaceOrientationMaskPortrait) {
            bInclude = YES;
            break;
        }
    }
    return bInclude;
}

- (NSUInteger) interfaceOrientations
{
    UIInterfaceOrientationMask mask;
    NSArray *oriens = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"UISupportedInterfaceOrientations"];
    mask = [self transformFromUIInterfaceOrientation:[oriens firstObject]];
    
    for (int i = 1; i < [oriens count]; i++) {
        mask |= [self transformFromUIInterfaceOrientation:[oriens objectAtIndex:i]];
    }
    return mask;
}

- (UIInterfaceOrientationMask) transformFromUIInterfaceOrientation:(NSString *) uiInterfaceOrientation
{
    if ([uiInterfaceOrientation isEqualToString:@"UIInterfaceOrientationPortrait"]) {
        return 1 << UIInterfaceOrientationPortrait;
    }else if ([uiInterfaceOrientation isEqualToString:@"UIInterfaceOrientationPortraitUpsideDown"]){
        return 1 << UIInterfaceOrientationPortraitUpsideDown;
    }else if ([uiInterfaceOrientation isEqualToString:@"UIInterfaceOrientationLandscapeLeft"]){
        return 1 << UIInterfaceOrientationLandscapeLeft;
    }else if ([uiInterfaceOrientation isEqualToString:@"UIInterfaceOrientationLandscapeRight"]){
        return 1 << UIInterfaceOrientationLandscapeRight;
    }else
        return 1;
}


@end

@implementation  MGIAPModel



@end
@implementation MGIAPBuyModel


@end

