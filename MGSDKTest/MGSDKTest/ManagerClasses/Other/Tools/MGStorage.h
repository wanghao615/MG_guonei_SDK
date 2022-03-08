//
//  MGUserDefaults.h
//  MGPlatformDemo
//
//  Created by SunYuan on 14-4-28.
//  Copyright (c) 2014年 Eason. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MGModelObj.h"
#import "MGKeyChainManager.h"

static NSString *const KMG_S = @"MGzs@#wqer983";




// 共享的用户系统
@interface MGAccount : NSObject

@property (nonatomic, copy) NSString *account;
@property (nonatomic, copy) NSData *pwData;

+ (MGAccount *) newAccountWithAccount:(NSString *) account andPassword:(NSString *) password;

@end


//多用户信息设置

@interface MGAccountSettingInfo : NSObject <NSCoding>

@property (nonatomic, copy) NSString *account;
@property (nonatomic, copy) NSData *secret;
@property (nonatomic, copy) NSString *uid;
@property (nonatomic, copy) NSString *token;
@property (nonatomic, copy) NSString *phoneNum;
@property (nonatomic, copy) NSString *phoneStatus;
@property (nonatomic, copy) NSString *idCardBindStatus;
@property (nonatomic, assign) BOOL bRememberSecret;
@property (nonatomic, assign) BOOL bAutoLogin;
@property (nonatomic, assign) BOOL isGuestAccount;

@property (nonatomic, copy) NSString *lastOrderNum;

@property (nonatomic, strong) NSString *is_adult;

@end




@interface MGStorage : NSObject


+ (BOOL) storeToolBarFrame:(CGRect) frame;
+ (CGRect) getToolBarFrame;


// 一台设备游客uid唯一，保存起来
//+ (void) storeToKeyChainGuestUid:(id)guestUid;
+ (id) getGuestUid;
//+ (BOOL) removeGuestUid;


+ (NSInteger) MGShareAccountsCount;
+ (UIPasteboard *) sharedPasteboard;
+ (NSArray *) MGShareAccounts;

+ (MGAccount *) MGAccountByAccount:(NSString *) account;
+ (void) MGShareRemoveOneAccountByAccount:(NSString *) account;

+ (BOOL) MGShareMaybeChanged;


//多账号系统

+ (NSArray *) allAccountSettings;
+ (NSArray *) allAccountSettingsExceptGuest;

+ (NSData *) AES256Encrypt:(NSString *)src;
+ (MGAccountSettingInfo *) accountSettingInfoByAccount:(NSString *) account;
+ (MGAccountSettingInfo *) firstAccountSettingInfo;
+ (MGAccountSettingInfo *) findNotGuestAccountSettingInfo;
//得到用户信息
+ (MGAccountSettingInfo *) findGuestAccountSettingInfo;


+ (void) setOneAccountSettingInfo:(MGAccountSettingInfo *) asInfo isCurrentAccount:(BOOL) bCurrent;
+ (MGAccountSettingInfo *) currentAccountSettingInfo;
+ (void) removeAccountSettingInfoByUid:(NSString *) uid;
+ (void) removeAccountSettingInfoByAccount:(NSString *) account;
+ (void) saveOneAccountSettingInfo:(MGAccountSettingInfo *) info;


//版本记录 用于游戏版本升级过程中得一些数据转移
//跟游戏相关，不跟共享用户系统相关
+ (void) initializationMGStorage;   //初始化


+ (void) setAccountSettingsWithRemoteData:(NSArray *) accounts;


@end
