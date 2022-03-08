//
//  MGPlatformDefines.h
//  MGPlatform
//
//  Created by Eason on 28/04/2014.
//  Copyright (c) 2014 . All rights reserved.
//

#ifndef MGPlatformDemo_MGPlatformDefines_h
#define MGPlatformDemo_MGPlatformDefines_h

#pragma mark - Notification 相关 key ---------------------------------------

extern NSString* const kMGPlatformErrorKey;    /*noti userinfo 错误码Key */
extern NSString* const kMGPlatformErrorMsg;    /*noti userinfo errmsg key */

#pragma mark - Notification -----------------------------------------------

extern NSString* const kMGPlatformInitDidFinishedNotification;   //初始化成功
extern NSString* const kMGPlatformLogoutNotification;            //注销
extern NSString* const kMGPlatformLoginNotification;             //登录
extern NSString* const kMGPlatformLeavedNotification;            //离开平台

#pragma mark -- enum

/**
 * @brief 离开平台的类型
 */
typedef enum {
    
    MGPlatformLeavedDefault = 0,    /* 离开未知页（预留状态）*/
    MGPlatformLeavedFromLogin,      /* 离开登录页面        */
    MGPlatformLeavedFromRegister,   /* 离开注册页面        */
    MGPlatformLeavedFromcoshow,    /* 离开充值页面        */
    MGPlatformLeavedFromSNSCenter,  /* 离开各种中心        */
    
} MGPlatformLeavedType;



/**
 *@brief ToolBar 位置
 */
typedef enum {
    
	MGToolBarAtTopLeft = 1,   /* 左上 */
    
	MGToolBarAtTopRight,      /* 右上 */
    
    MGToolBarAtMiddleLeft,    /* 左中 */
    
	MGToolBarAtMiddleRight,   /* 右中 */
    
	MGToolBarAtBottomLeft,    /* 左下 */
    
	MGToolBarAtBottomRight,   /* 右下 */
    
}MGToolBarPlace;




#pragma mark- 一般错误码 －－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－

#define MG_PLATFORM_NO_ERROR                                0       /**< 没有错误,成功 */
#define MG_PLATFORM_ERROR_UNKNOWN                           -1       /**< 未知错误 */
#define MG_PLATFORM_ERROR_NETWORK                           -2       /**< 网络错误 */

#define MG_PLATFORM_ERROR_NOT_INIT                          -99      /**< 平台未初始化 */

#define MG_PLATFORM_ERROR_ACCOUNT_EMPTY                     1       /**< 用户名位空， 用户名6-20位字符和数字组合 */
#define MG_PLATFORM_ERROR_UID_INVALID                       2       /**< UID不能为空 */
#define MG_PLATFORM_ERROR_PASSWORD_INVALID                  3       /**< 密码为空或不合法 ， 密码是6-16位字符 */
#define MG_PLATFORM_ERROR_ACCOUNT_INVALID                   4       /**< 用户名格式不正确， 用户名6-20位字母和数字组合 */
#define MG_PLATFORM_ERROR_ACCOUNT_EXIST                     5       /**< 用户名已存在 */
#define MG_PLATFORM_ERROR_ACCOUNT_NO_EXIST                  6       /**< 无此用户 */
#define MG_PLATFORM_ERROR_ACCOUNT_OR_PASSWORD               7       /**< 账号或密码错误 */
#define MG_PLATFORM_ERROR_PASSWORD_DIFF                     8       /**< 两次密码不一致 */
#define MG_PLATFORM_ERROR_SIGN                              9       /**< sign错误 */
#define MG_PLATFORM_ERROR_BEYOND_SEND_OUT                   10      /**< 超出发送限制 */
#define MG_PLATFORM_ERROR_PARAMETERS                        11      /**< 参数错误 */
#define MG_PLATFORM_ERROR_BINDED_MOBILE_OR_EMAIL            12      /**< 手机号或邮箱已绑定 */
#define MG_PLATFORM_ERROR_LACK_PARAMETERS                   13      /**< 缺少参数 */
#define MG_PLATFORM_ERROR_OLD_PASSWORD_EMPTY                14      /**< 原密码位空 */
#define MG_PLATFORM_ERROR_MOBILE_NO_CONFORM                 15      /**< 手机号码不对应 */
#define MG_PLATFORM_ERROR_MOBILE_INVALID                    16      /**< 手机号错误 */
#define MG_PLATFORM_ERROR_EMAIL_INVALID                     17      /**< 邮箱错误 */
#define MG_PLATFORM_ERROR_CAPTCHA                           18      /**< 验证码错误 */
#define MG_PLATFORM_ERROR_APP_NO_INFORMATION                19      /**< 无此app信息 */
#define MG_PLATFORM_ERROR_NO_APPID                          20      /**< 缺少 appid */
#define MG_PLATFORM_ERROR_NOT_IN_WHITELIST                  21      /**< 不在白名单内 */


#define MG_PLATFORM_ERROR_ONLY_BIND_ONE_MOBILE_OR_EMAIL     24      /**< 只能绑定一个手机或邮箱，先解绑再绑其他 */


#define MG_PLATFORM_ERROR_DATA_PROCESSING                   996     /**< 数据处理错误 */
#define MG_PLATFORM_ERROR_TOKEN_OUTDATE                     997     /**< token过期 */
#define MG_PLATFORM_ERROR_TOKEN_NOT_AUTH                    998     /**< token验证失败 */
#define MG_PLATFORM_ERROR_CAPTCHA_NOT_AUTH                  999     /**< 验证码校验失败 */



#endif
