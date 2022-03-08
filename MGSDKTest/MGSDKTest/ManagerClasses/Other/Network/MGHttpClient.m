//
//  MGHttpClient.m
//  MGPlatformTest
//
//  Created by caosq on 14-6-11.
//  Copyright (c) 2014年 Eason. All rights reserved.
//

#import "MGHttpClient.h"
#import "MGModelObj.h"
#import "MGHttpTransfer.h"
#import "MGUtility.h"
#import "MGImageDownLoader.h"
#import <objc/runtime.h>
#import "UIDevice+MGAbout.h"
#import <AdSupport/AdSupport.h>
#import "MGSimulateIDFA.h"
#import "MGXXTEA.h"

#define K_SIGN @"sign"

const int errorParamsCode = -999;


#pragma mark-- Config





static NSString * const MGPlatformSafeBaseURL =  @"https://adapi.mg3721.com/";
//static NSString * const MGPlatformSafeBaseURL =  @"https://test.mg3721.com/";
//static NSString * const MGPlatformSafeBaseURL =  @"https://dev.mg3721.com/";
//static NSString * const MG_APP_VERSION_URL = @"http://interface.MGzs.com/v2/sdk/mobile/appupgrade";


@interface MGHttpClient ()<MGHttpTransferDelegate>
{
    NSMutableDictionary *cblock_dic;
    NSMutableDictionary *fblock_dic;
    NSMutableDictionary *status_dic;
}

@property (nonatomic, strong) MGHttpTransfer *httpTransfer;
@property (nonatomic, strong) MGImageDownLoader *imageDownder;

//- (NSString*)serializeURL:(NSString *)baseUrl params:(NSDictionary *)params;

@end


@implementation MGHttpClient

+ (instancetype) shareMGHttpClient
{
    static MGHttpClient *_shareHttpClient = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _shareHttpClient = [[self alloc] init];
    });
    return _shareHttpClient;
}




- (NSString *) MGAppKey
{
    //    return @"QFmzX4zfzRcOT8jLk3T0Q31zrLx1kPxX";
    
    static NSString *appkey = nil;
    if (appkey == nil) {
        appkey =  [MGManager defaultManager].MG_APPKEY;
    }
    return appkey;
}

- (NSString *) MG_APP_ID
{
    static NSString *appid = nil;
    if (appid ==nil) {
        appid = [[MGManager defaultManager] MG_APPID];
    }
    return appid;
}



- (instancetype) init
{
    self = [super init];
    if (self) {
        _httpTransfer = [[MGHttpTransfer alloc] init];
        _imageDownder = [[MGImageDownLoader alloc] init];
        cblock_dic = [NSMutableDictionary new];
        fblock_dic = [NSMutableDictionary new];
        status_dic = [NSMutableDictionary new];
        _statistics = [[MGStatistics alloc] init];
        _isEncrypt = YES;

    }
    return self;
}


#pragma mark-- 登录 注册 游客登录 检查登录状态， 这几个接口加入统计字段  began --------------------------------------------

- (void) userLogin:(MGLoginInfo *) userInfo completion:(MGHttpCompletion) cBlock failed:(MGHttpError) fBlock
{
    if ([self checkParamsWithObj:userInfo maybeNilsProperties:nil failedBlock:fBlock]) {
        
//        NSString *macaddress = [[UIDevice currentDevice] macaddress];
        
        NSDictionary *params1 = @{@"account": userInfo.account,
                                  @"pwd": userInfo.password,
                                  @"sid" : @"1",
                                  @"appid": [self MG_APP_ID],
                                  @"macaddr" : [NSString IDFAORSimulateIDFA],
                                  @"eq" : [NSString IDFAORSimulateIDFA],
                                  @"device_type":@"iOS"
                                  };
        
        
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:[[UIDevice currentDevice] deviceDict]];
        [params addEntriesFromDictionary:params1];
        
        [self isUseHttpsAndXXTEParams:params andAaction:@"account/login" Completion:cBlock failed:fBlock];

        
    }
}

//注册
- (void) userRegister:(MGUserRegister *) registerInfo completion:(MGHttpCompletion) cblock failed:(MGHttpError) fBlock
{
    if ([self checkParamsWithObj:registerInfo maybeNilsProperties:@[@"code",@"password1",@"password2"] failedBlock:fBlock]) {
        
        
        NSDictionary *params1 = @{@"type" : @"account",
                                  @"eq":[NSString IDFAORSimulateIDFA],
                                  @"source": registerInfo.source,
                                  @"appid": [self MG_APP_ID],
                                  @"macaddr" : [NSString IDFAORSimulateIDFA],
                                  @"ts": [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]],
                                  @"username": registerInfo.account,
                                  @"pwd": registerInfo.password1,
                                  @"device_type" : @"iOS"
                                  };
        
        
        //用户名注册
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:[[UIDevice currentDevice] deviceDict]];
        [params addEntriesFromDictionary:params1];
        
        [self isUseHttpsAndXXTEParams:params andAaction:@"account/reg" Completion:cblock failed:fBlock];

        
    }
}

//手机注册获取验证码
- (void) getRegister:(MGUserRegister *) registerInfo completion:(MGHttpCompletion) cblock failed:(MGHttpError) fBlock
{
    if ([self checkParamsWithObj:registerInfo maybeNilsProperties:@[@"code",@"password1",@"password2"] failedBlock:fBlock]) {
        
        NSDictionary *params1 = @{@"type" : @"mob",
                                  @"phone" : registerInfo.account,
                                  @"eq":[NSString IDFAORSimulateIDFA],
                                  @"source": registerInfo.source,
                                  @"appid": [self MG_APP_ID],
                                  @"macaddr" : [NSString IDFAORSimulateIDFA],
                                  @"ts": [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]],
                                  @"device_type" : @"iOS"
                                  };
        
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:[[UIDevice currentDevice] deviceDict]];
        
        //发送验证码
        
        [params addEntriesFromDictionary:params1];
        
        [self beganSendPostWithParams:params andAction:@"account/reg" completionBlock:cblock failed:fBlock];

        
    }
}
//手机注册
- (void) phoneRegister:(MGUserRegister *) registerInfo completion:(MGHttpCompletion) cblock failed:(MGHttpError) fBlock
{
    if ([self checkParamsWithObj:registerInfo maybeNilsProperties:@[@"code",@"password1",@"password2"] failedBlock:fBlock]) {
        
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:[[UIDevice currentDevice] deviceDict]];
        
        NSDictionary *params1 = @{@"type" : @"mob",
                                  @"eq":[NSString IDFAORSimulateIDFA],
                                  @"source": registerInfo.source,
                                  @"appid": [self MG_APP_ID],
                                  @"macaddr" : [NSString IDFAORSimulateIDFA],
                                  @"ts": [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]],
                                  @"phone": registerInfo.account,
                                  @"pwd": registerInfo.password1,
                                  @"device_type" : @"iOS",
                                  @"code" : registerInfo.code,
                                  @"en_pwd" : @"pwd"
                                  };
        
        
        //手机注册
        [params addEntriesFromDictionary:params1];
        
        [self isUseHttpsAndXXTEParams:params andAaction:@"account/reg" Completion:cblock failed:fBlock];

    }
}


- (void) checkLoginState:(NSString *) uid appId:(NSString *) appid token:(NSString *) token completion:(MGHttpCompletion) cBlock failed:(MGHttpError) fBlock
{
    int ret = 0;
    NSString *msg = nil;
    if (uid == nil) {
        ret = MG_PLATFORM_ERROR_UID_INVALID;
        msg = @"uid 为空";
    }else if (appid == nil){
        ret = MG_PLATFORM_ERROR_NO_APPID;
        msg = @"appid 为空";
    }else if (token == nil){
        ret = -1;
        msg = @"token 为空";
    }
    if (msg != nil) {
        if (fBlock) {
            fBlock(ret, msg);
        }
        return;
    }
    NSDictionary *params1 = @{@"uid": uid,
                              @"appid": appid,
                              @"token": token,
                              @"device_type":@"iOS"};
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:[[UIDevice currentDevice] deviceDict]];    // 检查登录加入设备统计信息
    [params addEntriesFromDictionary:params1];
    
    [self beganSendPostWithParams:params andAction:@"account/checkLogin" completionBlock:cBlock failed:fBlock];

    
}
//根据idfa获取账号
- (void)getAccountArraycompletion:(MGHttpCompletion) cBlock failed:(MGHttpError) fBlock {
    NSDictionary *params1 = @{
                              @"equip" :[NSString IDFAORSimulateIDFA],
                              @"appid" : [self MG_APP_ID],
                              @"device_type":@"iOS"
                              };
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:[[UIDevice currentDevice] deviceDict]];    // 检查登录加入设备统计信息
    [params addEntriesFromDictionary:params1];
    [self beganSendPostWithParams:params andAction:@"account/getUnameByEquip" completionBlock:cBlock failed:fBlock];
}


#pragma mark-- 登录 注册 游客登录 检查登录状态， 这几个接口加入统计字段  end --------------------------------------------

//绑定身份证
- (void)bindIdCard:(MGUserIdCard *) userInfo completion:(MGHttpCompletion) cBlock failed:(MGHttpError) fBlock
{
    if ([self checkParamsWithObj:userInfo maybeNilsProperties:nil failedBlock:fBlock]) {
        
        NSDictionary *params1 = @{
                                  @"uid" :[MGManager defaultManager].MGOpenUID,
                                  @"token":[MGManager defaultManager].MGToken,
                                  @"eq" : [NSString IDFAORSimulateIDFA],
                                  @"idcard":userInfo.idCard,
                                  @"realname":userInfo.name,
                                  @"device_type":@"iOS",
                                  @"appid": [self MG_APP_ID]
                                  };
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:[[UIDevice currentDevice] deviceDict]];    // 检查登录加入设备统计信息
        [params addEntriesFromDictionary:params1];
        [self beganSendPostWithParams:params andAction:@"account/bindIdcard" completionBlock:cBlock failed:fBlock];

    }
}


- (void)cancellationAccountCompletion:(MGHttpCompletion) cBlock failed:(MGHttpError) fBlock {
    NSDictionary *params1 = @{@"appid": [MGManager defaultManager].MG_APPID,
                              @"uid": [MGManager defaultManager].MGOpenUID,
                              @"token":[MGManager defaultManager].MGToken,
                              @"device_type":@"iOS"
    };
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:[[UIDevice currentDevice] deviceDict]];
    [params addEntriesFromDictionary:params1];
    
    [self beganSendPostWithParams:params andAction:@"account/logoutAccount" completionBlock:cBlock failed:fBlock];
}


//手机找回密码 发送验证码
- (void)getPhoneFindPasswordVerifyCodeWithParams:(MGBoundMobile *)mobile  completion:(MGHttpCompletion) cblock failed:(MGHttpError) fBlock {
   
   
    NSDictionary *dict = @{
                           @"type" : @"mob",
                           @"device_type":@"iOS",
                           @"appid": [self MG_APP_ID],
                           @"mobile":mobile.number
                           };
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:[[UIDevice currentDevice] deviceDict]];
    [params addEntriesFromDictionary:dict];
    [self beganSendPostWithParams:params andAction:@"account/findPassword" completionBlock:cblock failed:fBlock];

}
//手机找回密码
- (void)findPasswordWithParams:(NSDictionary *)findParams completion:(MGHttpCompletion) cblock failed:(MGHttpError) fBlock {

    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:findParams];
    NSDictionary *dict = @{
                           @"device_type":@"iOS",
                           @"appid": [self MG_APP_ID]
                           };
    [params addEntriesFromDictionary:dict];
    [params addEntriesFromDictionary:[[UIDevice currentDevice] deviceDict]];
    [self beganSendPostWithParams:params andAction:@"account/findPassword" completionBlock:cblock failed:fBlock];

    
}



- (void)getAutoAccountWithCompletion:(MGHttpCompletion) cblock failed:(MGHttpError) fBlock {
    
    NSDictionary *dict = @{@"appid": [self MG_APP_ID],
                           @"ts": [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]],
                           @"device_type":@"iOS"};
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:[[UIDevice currentDevice] deviceDict]];
    
    [params addEntriesFromDictionary:dict];
    
    [self beganSendPostWithParams:params andAction:@"account/getRandomLogin" completionBlock:cblock failed:fBlock];

    
}






//手机绑定验证码
- (void) genPhoneVerifyCode:(MGVerifyCode *) codeInfo completion:(MGHttpCompletion) cBlock failed:(MGHttpError) fBlock;
{
    if ([self checkParamsWithObj:codeInfo maybeNilsProperties:nil failedBlock:fBlock]) {
        
        NSDictionary *params1 = @{@"appid": [self MG_APP_ID],
                                  @"uid": codeInfo.uid,
                                  @"mobile": codeInfo.number,
                                  @"token": codeInfo.token,
                                  @"device_type":@"iOS"};
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:[[UIDevice currentDevice] deviceDict]];
        [params addEntriesFromDictionary:params1];
        [self beganSendPostWithParams:params andAction:@"account/boundMobile" completionBlock:cBlock failed:fBlock];

    }
}

//绑定手机
- (void) boundMobile:(MGBoundMobile *) bmInfo completion:(MGHttpCompletion) cBlock failed:(MGHttpError) fBlock
{
    if ([self checkParamsWithObj:bmInfo maybeNilsProperties:@[@"code"] failedBlock:fBlock]) {
        NSDictionary *params1 = @{@"appid": [self MG_APP_ID],
                                  @"uid": bmInfo.uid,
                                  @"mobile": bmInfo.number,
                                  @"token": bmInfo.token,
                                  @"device_type":@"iOS"
                                  };
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:params1];
        if (bmInfo.code != nil) {
            [params setObject:bmInfo.code forKey:@"code"];
        }
        [params addEntriesFromDictionary:[[UIDevice currentDevice] deviceDict]];
        [self beganSendPostWithParams:params andAction:@"account/boundMobile" completionBlock:cBlock failed:fBlock];

    }
}

- (void)rechargeVerificationOfAgeWithParams:(NSDictionary *)rechargeParams completion:(MGHttpCompletion) cblock failed:(MGHttpError) fBlock {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:rechargeParams];
    NSDictionary *dict = @{
                           @"device_type":@"iOS",
                           @"appid": [self MG_APP_ID],
                           @"uid" : [[MGManager defaultManager] MGOpenUID],
                           @"amount" : rechargeParams[@"amount"]
                           };
    [params addEntriesFromDictionary:dict];
    [params addEntriesFromDictionary:[[UIDevice currentDevice] deviceDict]];
    
    [self beganSendPostWithParams:params andAction:@"ipi1/upi" completionBlock:cblock failed:fBlock];
}

- (void) modifySecret:(MGModifySecret *)secretInfo completion:(MGHttpCompletion)cBlock failed:(MGHttpError)fBlock
{
    if ([self checkParamsWithObj:secretInfo maybeNilsProperties:nil failedBlock:fBlock]) {
        
        NSDictionary *params1 = @{@"appid": [self MG_APP_ID],
                                  @"uid": secretInfo.uid,
                                  @"oldpwd": secretInfo.oldpwd,
                                  @"newpwd1": secretInfo.newpwd1,
                                  @"newpwd2": secretInfo.newpwd2,
                                  @"token": secretInfo.token,
                                  @"device_type":@"iOS"};
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:[[UIDevice currentDevice] deviceDict]];
        [params addEntriesFromDictionary:params1];
        
        [self isUseHttpsAndXXTEParams:params andAaction:@"account/changePassword" Completion:cBlock failed:fBlock];

    }
}



- (void) getUserInfo:(MGUserInfoObj *) userInfoObj completion:(MGHttpCompletion) cBlock failed:(MGHttpError) fBlock
{
    if ([self checkParamsWithObj:userInfoObj maybeNilsProperties:nil failedBlock:fBlock]) {
        
        NSDictionary *params1 = @{@"appid": [self MG_APP_ID],
                                  @"uid": userInfoObj.uid,
                                  @"token": userInfoObj.token,
                                  @"device_type":@"iOS"};
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:[[UIDevice currentDevice] deviceDict]];
        [params addEntriesFromDictionary:params1];
        [self beganSendPostWithParams:params andAction:@"account/getAccountInfo" completionBlock:cBlock failed:fBlock];

    }
}

- (void) getUserInfoByuser:(MGAccountSettingInfo *) userInfoObj completion:(MGHttpCompletion) cBlock failed:(MGHttpError) fBlock
{
    NSDictionary *params1 = @{@"appid": [self MG_APP_ID],
                              @"uid": userInfoObj.uid,
                              @"token": userInfoObj.token,
                              @"device_type":@"iOS"};
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:[[UIDevice currentDevice] deviceDict]];
    [params addEntriesFromDictionary:params1];
    [self beganSendPostWithParams:params andAction:@"account/getAccountInfo" completionBlock:cBlock failed:fBlock];

    
    
}


#pragma mark https 和XXTEA加密
- (void)isUseHttpsAndXXTEParams:(NSDictionary *)params andAaction:(NSString *)action Completion:(MGHttpCompletion) cBlock failed:(MGHttpError) fBlock
{
    if (self.isEncrypt) {
        [self beganSendSafePostWithParams:params andAction:action completionBlock:cBlock failed:fBlock];
    }else {
        [self beganSendPostWithParams:params andAction:action completionBlock:cBlock failed:fBlock];
    }
}

#pragma mark 统计接口
//是否开启加密
- (void)useEncryptCompletion:(MGHttpCompletion) cBlock failed:(MGHttpError) fBlock
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:[[UIDevice currentDevice] deviceDict]];
    [params addEntriesFromDictionary:[self DanaParameterDict]];
    
    [self beganSendSafePostWithParams:params andAction:@"dana/iosUseEncrypt" completionBlock:cBlock failed:fBlock];
}

//app激活
- (void)statisticsActivationCompletion:(MGHttpCompletion) cBlock failed:(MGHttpError) fBlock
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:[[UIDevice currentDevice] deviceDict]];
    [params addEntriesFromDictionary:[self DanaParameterDict]];
    
    [self isUseHttpsAndXXTEParams:params andAaction:@"dana/activation" Completion:cBlock failed:fBlock];
}
//sdk激活
- (void)statisticsSDKActivationCompletion:(MGHttpCompletion) cBlock failed:(MGHttpError) fBlock
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:[[UIDevice currentDevice] deviceDict]];
    [params addEntriesFromDictionary:[self DanaParameterDict]];
    
    [self isUseHttpsAndXXTEParams:params andAaction:@"dana/sdkActivation" Completion:cBlock failed:fBlock];
}

//注册
- (void)statisticsRegisterUsername:(NSString *)username Completion:(MGHttpCompletion) cBlock failed:(MGHttpError) fBlock
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:[[UIDevice currentDevice] deviceDict]];
    [params addEntriesFromDictionary:[self DanaParameterDict]];
    [params addEntriesFromDictionary:@{
                                       @"username":username,
                                       @"uid":[MGManager defaultManager].MGOpenUID
                                       }];
    
    [self isUseHttpsAndXXTEParams:params andAaction:@"dana/register" Completion:cBlock failed:fBlock];
}

//创角
- (void)statisticsCreaterole:(NSString *)role role_name:(NSString *)role_name server:(NSString *)server Completion:(MGHttpCompletion) cBlock failed:(MGHttpError) fBlock
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:[[UIDevice currentDevice] deviceDict]];
    [params addEntriesFromDictionary:[self DanaParameterDict]];
    [params addEntriesFromDictionary:@{
                                       @"role":role,
                                       @"server":server,
                                       @"role_name":role_name,
                                       @"uid":[MGManager defaultManager].MGOpenUID
                                       }];
    
    [self isUseHttpsAndXXTEParams:params andAaction:@"dana/create" Completion:cBlock failed:fBlock];
}

//角色登录
- (void)statisticsRoleLoginrole:(NSString *)role server:(NSString *)server role_name:(NSString *)role_name level:(NSString *)level occupation:(NSString *)occupation Completion:(MGHttpCompletion) cBlock failed:(MGHttpError) fBlock
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:[[UIDevice currentDevice] deviceDict]];
    [params addEntriesFromDictionary:[self DanaParameterDict]];
    [params addEntriesFromDictionary:@{
                                       @"uid":[MGManager defaultManager].MGOpenUID,
                                       @"role":role,
                                       @"server":server,
                                       @"role_name":role_name,
                                       @"level":level,
                                       @"occupation":occupation
                                       }];
    [self isUseHttpsAndXXTEParams:params andAaction:@"dana/roleLogin" Completion:cBlock failed:fBlock];
}
//登录
- (void)statisticsLoginCompletion:(MGHttpCompletion) cBlock failed:(MGHttpError) fBlock
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:[[UIDevice currentDevice] deviceDict]];
    [params addEntriesFromDictionary:[self DanaParameterDict]];
    [params addEntriesFromDictionary:@{
                                       @"uid":[MGManager defaultManager].MGOpenUID
                                       }];
    [self isUseHttpsAndXXTEParams:params andAaction:@"dana/login" Completion:cBlock failed:fBlock];
}

//拉起支付
- (void)statisticsPaymentCompletion:(MGHttpCompletion) cBlock failed:(MGHttpError) fBlock
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:[[UIDevice currentDevice] deviceDict]];
    [params addEntriesFromDictionary:[self DanaParameterDict]];
    [params addEntriesFromDictionary:@{
                                       @"uid":[MGManager defaultManager].MGOpenUID
                                       }];
    [self isUseHttpsAndXXTEParams:params andAaction:@"dana/payPage" Completion:cBlock failed:fBlock];
    
}
//拉起渠道页面
- (void)statisticsChannelPageCompletion:(MGHttpCompletion) cBlock failed:(MGHttpError) fBlock
{
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:[[UIDevice currentDevice] deviceDict]];
    [params addEntriesFromDictionary:[self DanaParameterDict]];
    [params addEntriesFromDictionary:@{
                                       @"uid":[MGManager defaultManager].MGOpenUID
                                       }];
    [self isUseHttpsAndXXTEParams:params andAaction:@"dana/channelPage" Completion:cBlock failed:fBlock];
    
}
//购买订单数统计
- (void)statisticsPayOrderCompletion:(MGHttpCompletion) cBlock failed:(MGHttpError) fBlock
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:[[UIDevice currentDevice] deviceDict]];
    [params addEntriesFromDictionary:[self DanaParameterDict]];
    [params addEntriesFromDictionary:@{
                                       @"uid":[MGManager defaultManager].MGOpenUID
                                       }];
    [self isUseHttpsAndXXTEParams:params andAaction:@"dana/payOrder" Completion:cBlock failed:fBlock];
    
}
//关闭实名认证页面
- (void)statisticsRealNameCloseCompletion:(MGHttpCompletion) cBlock failed:(MGHttpError) fBlock {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:[[UIDevice currentDevice] deviceDict]];
    [params addEntriesFromDictionary:[self DanaParameterDict]];
    [params addEntriesFromDictionary:@{
                                       @"uid":[MGManager defaultManager].MGOpenUID
                                       }];
    [self isUseHttpsAndXXTEParams:params andAaction:@"dana/realNameClose" Completion:cBlock failed:fBlock];
}

//游戏热更新开始 或者结束
- (void)statisticsGamehotType:(GameHotType)hotType Completion:(MGHttpCompletion) cBlock failed:(MGHttpError) fBlock {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:[[UIDevice currentDevice] deviceDict]];
    [params addEntriesFromDictionary:[self DanaParameterDict]];
    [params addEntriesFromDictionary:@{
                                       @"type": hotType == GameHotStart ? @"hotStart" : @"hotEnd"
                                       }];
    [self isUseHttpsAndXXTEParams:params andAaction:@"dana/hotActivation" Completion:cBlock failed:fBlock];
    
}

//ASA归因上报
- (void)statisticsDanaToken:(NSString *)appToken asaData:(NSDictionary *)data ASACompletion:(MGHttpCompletion) cBlock failed:(MGHttpError) fBlock {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:[[UIDevice currentDevice] deviceDict]];
    [params addEntriesFromDictionary:[self DanaParameterDict]];
    if ([data isKindOfClass:[NSDictionary class]] && data.allKeys.count>0) {
        if (appToken.length>0) {
            BOOL iad_attribution = [data[@"attribution"] boolValue];
            NSString *dataStr = [self dictionaryToJson:data];
            [params addEntriesFromDictionary:@{
                                               @"app_token": appToken?:@"",
                                               @"app_attribution":iad_attribution==YES?@"1":@"0",
                                               @"app_data":dataStr?:@""
                                               }];
        }else{
            NSString *keyStr = data.allKeys.firstObject;
            BOOL iad_attribution = [data[keyStr][@"iad-attribution"]boolValue];
            NSDictionary *dataDic = data[keyStr];
            NSString *dataStr = [self dictionaryToJson:dataDic];
            [params addEntriesFromDictionary:@{
                                               @"app_token": appToken?:@"",
                                               @"app_attribution":iad_attribution==YES?@"1":@"0",
                                               @"app_data":dataStr?:@""
                                               }];
        }
       
        [self isUseHttpsAndXXTEParams:params andAaction:@"dana/asa" Completion:cBlock failed:fBlock];
    }
    
    
}



- (void)getAppinfoCompletion:(MGHttpCompletion) cBlock failed:(MGHttpError) fBlock {
    
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]];
    NSDictionary *params = @{
                             @"appname": MGAPPBundleId,
                             @"time" : timeSp,
                             @"version" : MGAPPVersion
                             };
    
    [self beganSendPostWithParams:params andAction:@"inapi/iOS_check" completionBlock:cBlock failed:fBlock];
}

//获取商品信息
- (void)getProductInfo:(MGHttpCompletion) cBlock failed:(MGHttpError) fBlock {
    NSDictionary *params1 = @{@"appid": [self MG_APP_ID],
                              @"version": MGAPPVersion};
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:[[UIDevice currentDevice] deviceDict]];
    [params addEntriesFromDictionary:params1];
    [self beganSendPostWithParams:params andAction:@"pay/product" completionBlock:cBlock failed:fBlock];
}


//dana参数
- (NSDictionary *)DanaParameterDict {
    NSString *pasteboardStr =[UIPasteboard generalPasteboard].string;
    NSString *ad = @"";
    if([pasteboardStr hasPrefix:@"iosacid:"]){
        ad = [pasteboardStr substringFromIndex:8];
    }
    return @{
             @"uuid": [NSString IDFAORSimulateIDFA],
             @"appid": [self MG_APP_ID],
             @"ad": ad,
             @"sdk_int":[MGManager sdkVersion],
             @"device_name":[[UIDevice currentDevice] hardwareSimpleDescription],
             @"device_type":@"iOS",
             @"macaddr":[[UIDevice currentDevice] macaddress],
             @"apk_name":MGAPPBundleId,
             @"app_version":MGAPPVersion
             };
}


- (void) downLoadImageWithUrl:(NSString *) imageUrl andTag:(NSInteger) tag completion:(void (^)(UIImage *image)) cBlock
{
    [self.imageDownder downLoadImageWithUrl:imageUrl withTag:tag completion:cBlock];
}



#pragma mark-- MGHttpTransfer


- (void) beganSendPostWithParams:(NSDictionary *) params andAction:(NSString *) action completionBlock:(MGHttpCompletion) cBlock failed:(MGHttpError) fBlock
{
     NSData *postData = [[self gen_safe_sign_with_postdata:params appKey:[self MGAppKey ]isSafe:false] dataUsingEncoding:NSUTF8StringEncoding];
    TTDEBUGLOG(@"params:%@ \nurl:%@", params, [self requestSafeUrlWithAction:action]);
    MGHttpTransferIDRef reg = [self.httpTransfer postData:[self requestSafeUrlWithAction:action] dataToPost:postData delegate:self];
    [cblock_dic setObject:cBlock forKey:[NSNumber numberWithLong:reg]];
    [fblock_dic setObject:fBlock forKey:[NSNumber numberWithLong:reg]];
}
- (void) beganSendSafePostWithParams:(NSDictionary *) params andAction:(NSString *) action completionBlock:(MGHttpCompletion) cBlock failed:(MGHttpError) fBlock
{
    NSData *postData = [[self gen_safe_sign_with_postdata:params appKey:[self MGAppKey]isSafe:YES] dataUsingEncoding:NSUTF8StringEncoding] ;
    TTDEBUGLOG(@"params:%@ \nurl:%@", params, [self requestSafeUrlWithAction:action]);
    MGHttpTransferIDRef reg = [self.httpTransfer postData:[self requestSafeUrlWithAction:action] dataToPost:postData delegate:self];
    [cblock_dic setObject:cBlock forKey:[NSNumber numberWithLong:reg]];
    [fblock_dic setObject:fBlock forKey:[NSNumber numberWithLong:reg]];
}


#pragma mark-- XTHttpTransfer Delegate

- (id) getStatusCodeByConnectionIdRef:(MGHttpTransferIDRef) idRef
{
    NSNumber *key = [NSNumber numberWithLong:idRef];
    id statusCode = nil;
    if (key) {
        statusCode = [status_dic objectForKey:key];
        [status_dic removeObjectForKey:key];
    }
    return statusCode;
}

- (void) transfer:(MGHttpTransferIDRef)connection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
    [status_dic setObject:[NSNumber numberWithInteger:httpResponse.statusCode] forKey:[NSNumber numberWithLong:connection]];
}


- (void) transfer:(MGHttpTransferIDRef)connection didReceiveData:(NSData *)data
{
    
    NSString *str = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    
    NSError *jsonError = nil;
    id jsonDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
    if (jsonError != nil) {
        TTDEBUGLOG(@"jsonError = %@", jsonError);
        MGHttpError fBlock = fblock_dic[[NSNumber numberWithLong:connection]];
        if (fBlock) {
            id statusCode = [self getStatusCodeByConnectionIdRef:connection];
            fBlock(MG_PLATFORM_ERROR_UNKNOWN, [NSString stringWithFormat:@"未知错误-%@",statusCode]);
        }
    }
    if ([jsonDict isKindOfClass:[NSDictionary class]]) {
        
        NSInteger ret = -1;
        if (jsonDict != nil) {
            ret = [jsonDict[@"ret"] integerValue];
        }
        
        if (ret == 0) {
            MGHttpCompletion cBlock = cblock_dic[[NSNumber numberWithLong:connection]];
            if (cBlock) {
                if (jsonDict != nil) {
                    cBlock(jsonDict);
                }else {
                    cBlock(jsonDict);
                }
                
            }
            [self getStatusCodeByConnectionIdRef:connection];
        }else{
            NSString *errmsg = jsonDict[@"msg"];
            if (errmsg == nil) errmsg = @"";
            MGHttpError fBlock = fblock_dic[[NSNumber numberWithLong:connection]];
            if (fBlock) {
//                errmsg = [NSString stringWithFormat:@"%@-%@", errmsg, [self getStatusCodeByConnectionIdRef:connection]];
                
                errmsg = [NSString stringWithFormat:@"%@", errmsg];
                fBlock(ret, errmsg);
            }
        }
    }
    [self performSelectorOnMainThread:@selector(removeBlockByKey:) withObject:[NSNumber numberWithLong:connection] waitUntilDone:YES];
}

- (void) transfer:(MGHttpTransferIDRef)connection didFailWithError:(NSError *)error
{
    MGHttpError fBlock = fblock_dic[[NSNumber numberWithLong:connection]];
    if (fBlock) {
        id obj = [self getStatusCodeByConnectionIdRef:connection];
        //        NSString *errMsg = obj != nil ? [NSString stringWithFormat:@"网络请求失败-%@", obj] : @"网络请求失败";
        NSString *errMsg =[NSString stringWithFormat:@"网络请求失败"];
        fBlock(MG_PLATFORM_ERROR_NETWORK, errMsg);
    }
    
    [self performSelectorOnMainThread:@selector(removeBlockByKey:) withObject:[NSNumber numberWithLong:connection] waitUntilDone:YES];
}

- (void) removeBlockByKey:(id) key
{
    if (key != nil) {
        [cblock_dic removeObjectForKey:key];
        [fblock_dic removeObjectForKey:key];
    }
}

#pragma mark-- 接口
// 通用接口 https
- (NSString *) requestSafeUrlWithAction:(const NSString *) action
{
    return [NSString stringWithFormat:@"%@%@", MGPlatformSafeBaseURL, action];
}


#pragma mark-- sign
/**
 * 签名和POST的参数生成方法
 对接（query = ％@－％@） －》 k_sign = md5(appkey ＋query) -> query&sign=k_sign
 */

- (NSString *) gen_safe_sign_with_postdata:(NSDictionary *) params appKey:(id) appkey isSafe:(BOOL)isSAafe

{
    
    NSString *post_str = @"";
    NSMutableArray *pairs = [NSMutableArray new];
    NSArray *keys = [[params allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2];
    }];
    
    for (NSString *key in keys) {
        [pairs addObject:[NSString stringWithFormat:@"%@=%@", key, params[key]]];
    }
    NSString *query = [pairs componentsJoinedByString:@"&"];
    
    NSString *query_key = [NSString stringWithFormat:@"%@%@", appkey, query];
    
    NSString *sign = [MGUtility md5:query_key];
    
    post_str = [NSString stringWithFormat:@"%@&sign=%@", [self encodePostParams:params], sign];
    if (isSAafe) {
        // 获得时间戳
        NSString *timeSp = [NSString stringWithFormat:@"%ld",(long)[[NSDate date]timeIntervalSince1970]];;
        
        
        NSString *key = [MGUtility md5:[NSString stringWithFormat:@"gjdie329d90f3%@",timeSp]];
        
        //加密
        NSString *o = [MGXXTEA MGencryptStringToBase64String:post_str stringKey:key];
        
        //特殊字符转义
        NSString *newo = [self encodeToPercentEscapeString:o];
        
        post_str = [NSString stringWithFormat:@"o=%@&t=%@",newo,timeSp];
    }

    
    return post_str;
}


#pragma mark -- encodeURl


//编码后的参数
- (NSString *) encodePostParams:(NSDictionary *) params
{
    NSMutableArray *pairs = [NSMutableArray new];
    
    NSArray *keys = [[params allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2];
    }];
    
    for (NSString *key in keys) {
        
        NSString* escaped_value = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                                        kCFAllocatorDefault, /* allocator */
                                                                                                        (CFStringRef)[params objectForKey:key],
                                                                                                        NULL, /* charactersToLeaveUnescaped */
                                                                                                        (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                                        kCFStringEncodingUTF8));
        
        
        [pairs addObject:[NSString stringWithFormat:@"%@=%@", key,escaped_value]];
        
    }
    
    NSString* query = [pairs componentsJoinedByString:@"&"];
    return query;
}

//编码为百分比转义字符串
- (NSString *)encodeToPercentEscapeString: (NSString *) input
{
    
    NSString *outputStr = (NSString *)
    CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                              (CFStringRef)input,
                                                              NULL,
                                                              (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                              kCFStringEncodingUTF8));
    return outputStr;
}
//解码从百分比转义字符串
- (NSString *)decodeFromPercentEscapeString: (NSString *) input
{
    NSMutableString *outputStr = [NSMutableString stringWithString:input];
    [outputStr replaceOccurrencesOfString:@"+"
                               withString:@" "
                                  options:NSLiteralSearch
                                    range:NSMakeRange(0, [outputStr length])];
    
    return [outputStr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}


#pragma mark-- 检查obj属性是不是有nil值， 避免expeation

- (BOOL) checkParamsWithObj:(id) obj maybeNilsProperties:(NSArray *) properties failedBlock:(MGHttpError) fBlock
{
    NSString *msg = nil;
    if ([self MG_APP_ID] == nil) {
        msg = @"MG_APP_ID 位空";
    }
    
    NSArray *nilProperties = [self findNilValuesByObj:obj];
    
    BOOL bOK = YES;
    NSString *name;
    for (NSString *propName in nilProperties) {
        if (![properties containsObject:propName]) {
            bOK = NO;
            name = propName;
            break;
        }
    }
    if (!bOK) {
        msg  = [NSString stringWithFormat:@"参数<%@>为nil, 请传入参数", name];
    }
    
    if (msg != nil) {
        fBlock(errorParamsCode, msg);
        return NO;
    }else
        return YES;
}

- (NSArray *) findNilValuesByObj:(id) obj
{
    NSMutableArray *M = [NSMutableArray new];
    unsigned int propsCount, i;
    objc_property_t *props = class_copyPropertyList([obj class], &propsCount);
    for (i = 0; i < propsCount; i++) {
        objc_property_t prop = props[i];
        const char * propName = property_getName(prop);
        NSString *propName_ = [NSString stringWithUTF8String:propName];
        id value = [obj valueForKey:propName_];
        if (value == nil) {
            [M addObject:propName_];
        }
    }
    return M;
}

- (NSString*)dictionaryToJson:(NSDictionary *)dic
{
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:0 error:&parseError];
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}


@end
