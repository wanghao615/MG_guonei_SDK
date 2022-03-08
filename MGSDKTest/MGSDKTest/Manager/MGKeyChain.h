//
//  MGKeyChain.h
//  MGSDKTest
//
//  Created by kingnet on 2017/11/10.
//  Copyright © 2017年 xyzs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Security/Security.h>


#define KEY_USERACCOUNT  @"com.mgsdk.useraccout"
#define KEY_USERLOGIN_INFO  @"com.mgsdk.userlogininfo"
#define KEY_IDFAORSimulateIDFA  @"com.mgsdk.IDFAORSimulateIDFA"
#define KEY_USERINFO  @"com.mgsdk.userinfo"
#define KEY_UA  @"com.mgsdk.UA"

@interface MGKeyChain : NSObject

+ (void)mgKeyChainSave:(NSString *)service data:(id)data;

+ (id)mgKeyChainLoad:(NSString *)service;

+ (void)mgKeyChainDelete:(NSString *)service;

@end
