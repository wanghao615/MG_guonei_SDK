//
//  MGConfiguration.h
//  MGSDKTest
//
//  Created by ZYZ on 2018/1/31.
//  Copyright © 2018年 MG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MGConfiguration : NSObject


+ (MGConfiguration *)shareConfiguration;

/**  全局  **/

//实名或手机验证弹框 是否对全部用户提示，还是只针对没有绑定手机的用户展示
@property(nonatomic,strong)NSString *isAll;
//是否显示一键注册按钮
@property(nonatomic,strong)NSString *oneKeyReg;


/**  登录  **/

//登录弹框状态 0开启(非强制) 1开启(强制) 2关闭
@property(nonatomic,strong)NSString *auth_login;


/**  支付  **/

//是否开启实名或手机验证弹框
@property(nonatomic,strong)NSString *auth_pay;


/// 服务器版本号
@property(nonatomic,assign)int privacy_version;

@property(nonatomic,assign,readwrite)BOOL showPrivacyNew;


@end
