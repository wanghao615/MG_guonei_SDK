//
//  MGKeyChainManager.h
//  MGPlatformTest
//
//  Created by caosq on 14-9-22.
//  Copyright (c) 2014年 qmqj. All rights reserved.
//



#import <Foundation/Foundation.h>

@interface MGKeyChainManager : NSObject

+ (MGKeyChainManager *) shareMGKeyChain;

// 共享的deviceID
- (NSString *) MGShareDeviceId;


/*
// 共享的
- (void) MGSaveAccountPassword:(NSArray *) strings;
- (NSArray *) MGAccountsFromKeyChain;
*/


// 缓存的用户名密码 白名单

// aaa:111<>bbb:222
- (void) removeWhiteAccount:(NSString *) account;
- (void) addWhiteAccount:(NSString *) account pwd:(NSString *) pwd;
- (NSArray *) whiteAccountAndPassword;




// 删除的用户名列表  黑名单
- (void) addBlackAccounts:(NSString *) account;
- (void) removeBlackAccount:(NSString *) account;
- (BOOL) isInBlackAccounts:(NSString *) account;



@end
