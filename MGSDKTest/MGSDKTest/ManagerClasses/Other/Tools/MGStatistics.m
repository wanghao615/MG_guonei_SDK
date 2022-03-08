//
//  MGStatistics.m
//  MGPlatformTest
//
//  Created by caosq on 14-7-9.
//  Copyright (c) 2014年 qmqj. All rights reserved.
//

#import "MGStatistics.h"
#import "MGUserDefault.h"

#import "MGASAAttribution.h"
#import "MGHttpClient.h"
#import "MGConfiguration.h"

static int encriptRequestCount = 0;
static int encriptFailRequestCount = 0;

@interface MGStatistics ()

@end

@implementation MGStatistics

//是否使用加密
- (void)userEncript {
    __weak typeof(self) weakSelf = self;
    [[MGHttpClient shareMGHttpClient]useEncryptCompletion:^(NSDictionary *responseDic) {
        //app激活
        [weakSelf launchedStatistics];
        
        NSDictionary *data = responseDic[@"data"];
        //判断登录后是否需要弹框 赋值
        [MGConfiguration shareConfiguration].auth_login = [NSString stringWithFormat:@"%@",data[@"auth_login"]];
        
        [MGConfiguration shareConfiguration].auth_pay = [NSString stringWithFormat:@"%@",data[@"auth_pay"]];
        [MGConfiguration shareConfiguration].oneKeyReg = [NSString stringWithFormat:@"%@",data[@"one_key"]];
        [MGConfiguration shareConfiguration].isAll = [NSString stringWithFormat:@"%@",data[@"is_all"]];
     
        [MGConfiguration shareConfiguration].privacy_version = [data[@"privacy_version"] intValue];
        
        if ([[NSString stringWithFormat:@"%@",data[@"encrypt"]] isEqualToString:@"0"]) {
            //加密
            [MGHttpClient shareMGHttpClient].isEncrypt = YES;
        }else if ([[NSString stringWithFormat:@"%@",data[@"encrypt"]] isEqualToString:@"1"]){
            //不加密
            [MGHttpClient shareMGHttpClient].isEncrypt = false;
        }else if ([[NSString stringWithFormat:@"%@",data[@"encrypt"]] isEqualToString:@"2"]){
            //重新请求两次
            encriptRequestCount ++;
            if (encriptRequestCount <= 3) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [weakSelf userEncript];
                });
            }
        }
        
        [MGASAAttribution requestTrackingAuthorization];
        
    } failed:^(NSInteger ret, NSString *errMsg) {
        //重新请求
        encriptFailRequestCount ++;
        if (encriptFailRequestCount <= 60) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf userEncript];
            });
        }
        
        
    }];
    
}





//app激活
- (void) launchedStatistics
{
    [[MGHttpClient shareMGHttpClient]statisticsActivationCompletion:^(NSDictionary *responseDic) {
            
           
            
    } failed:^(NSInteger ret, NSString *errMsg) {
            
    }];

    
}

//sdk激活
- (void)sdkActiveation {
    
    [[MGHttpClient shareMGHttpClient]statisticsSDKActivationCompletion:^(NSDictionary *responseDic) {
        
        
    } failed:^(NSInteger ret, NSString *errMsg) {
        
    }];
    
}

- (void) registerStatistics:(NSString *) userName andUserId:(id) uid
{
    [[MGHttpClient shareMGHttpClient]statisticsRegisterUsername:userName Completion:^(NSDictionary *responseDic) {
        
    } failed:^(NSInteger ret, NSString *errMsg) {
        
    }];

}


- (void) MG_LoginStatistics:(id) uid
{
    [[MGHttpClient shareMGHttpClient]statisticsLoginCompletion:^(NSDictionary *responseDic) {
        
    } failed:^(NSInteger ret, NSString *errMsg) {
        
    }];

}



- (void)createRole:(NSString *)role roleName:(NSString *)roleName gameServer:(NSString *)server {
    
    [[MGHttpClient shareMGHttpClient]statisticsCreaterole:role role_name:roleName server:server Completion:^(NSDictionary *responseDic) {
        
    } failed:^(NSInteger ret, NSString *errMsg) {
        
    }];

    
}

- (void)roleLogin:(NSString *)role roleName:(NSString *)roleName gameServer:(NSString *)gameServer level:(NSString *)level occupation:(NSString *)occupation {
    [[MGHttpClient shareMGHttpClient]statisticsRoleLoginrole:role server:gameServer role_name:roleName level:level occupation:occupation Completion:^(NSDictionary *responseDic) {
        
    } failed:^(NSInteger ret, NSString *errMsg) {
        
    }];
}

- (void)orderNumber:(int)num gameServer:(int)server {
    
}

//游戏开始热更新
- (void)gameHotStart {
    [[MGHttpClient shareMGHttpClient]statisticsGamehotType:GameHotStart Completion:^(NSDictionary *responseDic) {
        
    } failed:^(NSInteger ret, NSString *errMsg) {
        
    }];
}
//游戏结束热更新
- (void)gameHotEnd {
    [[MGHttpClient shareMGHttpClient]statisticsGamehotType:GameHotEnd Completion:^(NSDictionary *responseDic) {
        
    } failed:^(NSInteger ret, NSString *errMsg) {
        
    }];
}

//充值的时候关闭实名认证
- (void)closeAlertView {
    [[MGHttpClient shareMGHttpClient]statisticsRealNameCloseCompletion:^(NSDictionary *responseDic) {
        
    } failed:^(NSInteger ret, NSString *errMsg) {
        
    }];
}

- (void)appleSearchAd:(NSString *)asaToken data:(NSDictionary *)asaData{
    [[MGHttpClient shareMGHttpClient]statisticsDanaToken:asaToken asaData:asaData ASACompletion:^(NSDictionary *responseDic) {
            
        } failed:^(NSInteger ret, NSString *errMsg) {
            
        }];
}


@end
