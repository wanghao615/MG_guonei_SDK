//
//  MGHttpClient.h
//  MGPlatformTest
//
//  Created by caosq on 14-6-11.
//  Copyright (c) 2014年 Eason. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MGModelObj.h"
#import "MGStatistics.h"



typedef NS_ENUM(NSUInteger, GameHotType) {
    GameHotStart,
    GameHotEnd
};



typedef void (^MGHttpCompletion)(NSDictionary *responseDic);

typedef void (^MGHttpError)(NSInteger ret, NSString *errMsg);

@interface MGHttpClient : NSObject

@property (nonatomic, strong) MGStatistics *statistics;


+ (instancetype) shareMGHttpClient;

- (void) userLogin:(MGLoginInfo *) userInfo completion:(MGHttpCompletion) cBlock failed:(MGHttpError) fBlock;

- (void) userRegister:(MGUserRegister *) registerInfo completion:(MGHttpCompletion) cblock failed:(MGHttpError) fBlock;

- (void) getRegister:(MGUserRegister *) registerInfo completion:(MGHttpCompletion) cblock failed:(MGHttpError) fBlock;

- (void) phoneRegister:(MGUserRegister *) registerInfo completion:(MGHttpCompletion) cblock failed:(MGHttpError) fBlock;

- (void)getAutoAccountWithCompletion:(MGHttpCompletion) cblock failed:(MGHttpError) fBlock;



//绑定身份证
- (void)bindIdCard:(MGUserIdCard *) userInfo completion:(MGHttpCompletion) cBlock failed:(MGHttpError) fBlock;


- (void)cancellationAccountCompletion:(MGHttpCompletion) cBlock failed:(MGHttpError) fBlock;

//手机找回密码 发送验证码
- (void)getPhoneFindPasswordVerifyCodeWithParams:(MGBoundMobile *)mobile completion:(MGHttpCompletion) cblock failed:(MGHttpError) fBlock;

//通过手机 密保找回密码
- (void)findPasswordWithParams:(NSDictionary *)findParams completion:(MGHttpCompletion) cblock failed:(MGHttpError) fBlock;

// 充值防沉迷控制---每次充值前必须调此接口
- (void)rechargeVerificationOfAgeWithParams:(NSDictionary *)rechargeParams completion:(MGHttpCompletion) cblock failed:(MGHttpError) fBlock;

//手机验证码
- (void) genPhoneVerifyCode:(MGVerifyCode *) codeInfo completion:(MGHttpCompletion) cBlock failed:(MGHttpError) fBlock;

- (void) boundMobile:(MGBoundMobile *) bmInfo completion:(MGHttpCompletion) cBlock failed:(MGHttpError) fBlock;

- (void) modifySecret:(MGModifySecret *) secretInfo completion:(MGHttpCompletion) cBlock failed:(MGHttpError) fBlock;

- (void) checkLoginState:(NSString *) uid appId:(NSString *) appid token:(NSString *) token completion:(MGHttpCompletion) cBlock failed:(MGHttpError) fBlock;

//根据idfa获取账号
- (void)getAccountArraycompletion:(MGHttpCompletion) cBlock failed:(MGHttpError) fBlock;

- (void) getUserInfo:(MGUserInfoObj *) userInfoObj completion:(MGHttpCompletion) cBlock failed:(MGHttpError) fBlock;

- (void) getUserInfoByuser:(MGAccountSettingInfo *) userInfoObj completion:(MGHttpCompletion) cBlock failed:(MGHttpError) fBlock;

- (void) downLoadImageWithUrl:(NSString *) imageUrl andTag:(NSInteger) tag completion:(void (^)(UIImage *image)) cBlock;

- (void)getAppinfoCompletion:(MGHttpCompletion) cBlock failed:(MGHttpError) fBlock;

//获取商品信息
- (void)getProductInfo:(MGHttpCompletion) cBlock failed:(MGHttpError) fBlock;

#pragma mark 统计接口

@property(nonatomic,assign)BOOL isEncrypt;

/**
 *  @brief  是否开启加密
 *
 *  @result  0是启用，1是不启用，2是重新请求
 */
- (void)useEncryptCompletion:(MGHttpCompletion) cBlock failed:(MGHttpError) fBlock;
//app激活
- (void)statisticsActivationCompletion:(MGHttpCompletion) cBlock failed:(MGHttpError) fBlock;
//sdk激活
- (void)statisticsSDKActivationCompletion:(MGHttpCompletion) cBlock failed:(MGHttpError) fBlock;
//注册
- (void)statisticsRegisterUsername:(NSString *)username Completion:(MGHttpCompletion) cBlock failed:(MGHttpError) fBlock
;
//创角
- (void)statisticsCreaterole:(NSString *)role role_name:(NSString *)role_name server:(NSString *)server Completion:(MGHttpCompletion) cBlock failed:(MGHttpError) fBlock;
//角色登录
- (void)statisticsRoleLoginrole:(NSString *)role server:(NSString *)server role_name:(NSString *)role_name level:(NSString *)level occupation:(NSString *)occupation Completion:(MGHttpCompletion) cBlock failed:(MGHttpError) fBlock;

//ASA归因上报
- (void)statisticsDanaToken:(NSString *)appToken asaData:(NSDictionary *)data ASACompletion:(MGHttpCompletion) cBlock failed:(MGHttpError) fBlock;

//登录
- (void)statisticsLoginCompletion:(MGHttpCompletion) cBlock failed:(MGHttpError) fBlock;
//拉起支付
- (void)statisticsPaymentCompletion:(MGHttpCompletion) cBlock failed:(MGHttpError) fBlock;
//拉起渠道页面
- (void)statisticsChannelPageCompletion:(MGHttpCompletion) cBlock failed:(MGHttpError) fBlock;
//购买订单数统计
- (void)statisticsPayOrderCompletion:(MGHttpCompletion) cBlock failed:(MGHttpError) fBlock;
//关闭实名认证页面
- (void)statisticsRealNameCloseCompletion:(MGHttpCompletion) cBlock failed:(MGHttpError) fBlock;
//游戏热更新开始 或者结束
- (void)statisticsGamehotType:(GameHotType)hotType Completion:(MGHttpCompletion) cBlock failed:(MGHttpError) fBlock;
@end
