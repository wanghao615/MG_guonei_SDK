//
//  MGStatistics.h
//  MGPlatformTest
//
//  Created by caosq on 14-7-9.
//  Copyright (c) 2014年 qmqj. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MGStatistics : NSObject

//是否使用加密
- (void)userEncript;
//app激活
- (void) launchedStatistics;
//sdk激活 已经弹出登录界面
- (void)sdkActiveation;
- (void) registerStatistics:(NSString *) userName andUserId:(id) uid;
- (void) MG_LoginStatistics:(id) uid;

//游戏开始热更新
- (void)gameHotStart;
//游戏结束热更新
- (void)gameHotEnd;

//充值的时候关闭实名认证
- (void)closeAlertView;

//创角色
- (void)createRole:(NSString *)role roleName:(NSString *)roleName gameServer:(NSString *)server;

- (void)roleLogin:(NSString *)role roleName:(NSString *)roleName gameServer:(NSString *)gameServer level:(NSString *)level occupation:(NSString *)occupation;

//asa归因
- (void)appleSearchAd:(NSString *)asaToken data:(NSDictionary *)asaData;

//充值 (暂时未用)
- (void)orderNumber:(int)num gameServer:(int)server;

@end
