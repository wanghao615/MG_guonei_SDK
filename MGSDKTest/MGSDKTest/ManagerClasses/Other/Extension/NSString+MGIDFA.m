//
//  NSString+MGIDFA.m
//  MGManagerTest
//
//  Created by ZYZ on 2017/8/3.
//  Copyright © 2017年 MGzs. All rights reserved.
//

#import "NSString+MGIDFA.h"
#import <AppTrackingTransparency/AppTrackingTransparency.h>
#import <AdSupport/AdSupport.h>
#import "MGSimulateIDFA.h"
#import "MGKeyChain.h"

@implementation NSString (MGIDFA)

+ (NSString *) IDFA
{
    // iOS 14请求idfa权限

    if (@available(iOS 14.0, *)) {
        ATTrackingManagerAuthorizationStatus states = [ATTrackingManager trackingAuthorizationStatus];
        if (states == ATTrackingManagerAuthorizationStatusNotDetermined) {
            // 未提示用户
            [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    // 获取到权限后，依然使用老方法获取idfa
                    if (status == ATTrackingManagerAuthorizationStatusAuthorized) {
                        // 可以使用IDFA
                        NSString *idfaString = [[ASIdentifierManager sharedManager] advertisingIdentifier].UUIDString;
                        [MGKeyChain mgKeyChainSave:KEY_IDFAORSimulateIDFA data:idfaString];
                        
                    }else {
                       
                    }
                });
            }];
           
        }else if (states == ATTrackingManagerAuthorizationStatusRestricted) {
            // 限制使用
          
        }else if (states == ATTrackingManagerAuthorizationStatusDenied) {
            // 拒绝
        
           
        }else if (states == ATTrackingManagerAuthorizationStatusAuthorized) {
            // 可以使用IDFA
            NSString *idfaString = [[ASIdentifierManager sharedManager] advertisingIdentifier].UUIDString;
            return idfaString;
        }
    }
    // iOS 14以下请求idfa权限
    else {
        if ([[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled]) {
            NSString *idfaString = [[ASIdentifierManager sharedManager] advertisingIdentifier].UUIDString;
            return idfaString;
        }
    }
    return @"";
}


+ (NSString *)SimulateIDFA {
    return [MGSimulateIDFA createSimulateIDFA];
}


+ (NSString *)IDFAORSimulateIDFA {
   
    NSString *IDFAorSimulateIDFA = [MGKeyChain mgKeyChainLoad:KEY_IDFAORSimulateIDFA];
    
    if (IDFAorSimulateIDFA.length < 1||IDFAorSimulateIDFA == nil) {
        
        NSString *idfa = [self IDFA];
        
        if (idfa == nil||idfa.length < 1||[idfa isEqualToString:@"00000000-0000-0000-0000-000000000000"]) {
            
            IDFAorSimulateIDFA = [NSString stringWithFormat:@"A-%@",[self SimulateIDFA]];
            //存到keychina
            [MGKeyChain mgKeyChainSave:KEY_IDFAORSimulateIDFA data:IDFAorSimulateIDFA];
            
        }else{
            //取到idfa
            IDFAorSimulateIDFA = idfa;
            //存到keychina
            [MGKeyChain mgKeyChainSave:KEY_IDFAORSimulateIDFA data:idfa];
        }
    }
    
    return IDFAorSimulateIDFA;
}


@end
