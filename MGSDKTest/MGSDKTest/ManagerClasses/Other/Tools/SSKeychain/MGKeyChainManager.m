//
//  MGKeyChainManager.m
//  MGPlatformTest
//
//  Created by caosq on 14-9-22.
//  Copyright (c) 2014年 qmqj. All rights reserved.
//

#import "MGKeyChainManager.h"
#import "MGSSKeychain.h"


static NSString* const kMG_KeyChain_ServiceX = @"com.mg.sdk";
static NSString* const kMG_KeyChain_DeviceIdX= @"com.mg.sdk.deviceId";
static NSString* const kMG_KeyChain_Accounts = @"com.mg.sdk.accounts";
static NSString* const kMG_KeyChain_Accounts_Remote = @"com.mg.sdk.remote";

static NSString* const kMG__Accounts = @"com.mg.sdk.save";



@implementation MGKeyChainManager

+ (MGKeyChainManager *) shareMGKeyChain
{
    static MGKeyChainManager* _MGKeyChain = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _MGKeyChain = [[MGKeyChainManager alloc] init];
        [_MGKeyChain initilizeMGKeyChain];
    });
    return _MGKeyChain;
}



- (NSString *) initilizeMGKeyChain
{
    NSString *keychain = [MGSSKeychain passwordForService:kMG_KeyChain_ServiceX account:kMG_KeyChain_DeviceIdX];
    if ([keychain length] == 0) {  // keychain中还没有数据
            
        NSString *deviceId = [[self sharedPasteboard] string]; // 判断剪贴板数据
        if ([deviceId length] == 0) {  // 剪贴板也没有数据
            deviceId = [MGUtility generateDeviceId]; // 生成数据
            [[self sharedPasteboard] setString:deviceId];  //保存数据
        }
        [MGSSKeychain setPassword:deviceId forService:kMG_KeyChain_ServiceX account:kMG_KeyChain_DeviceIdX];       // 保存到keychian
        keychain = deviceId;

    }else{  // 应用被全部卸载之后，重新安装之前的app，
        
        NSString *deviceId = [[self sharedPasteboard] string];
        if ([deviceId length] == 0) {  // 黏贴板无数据
            [[self sharedPasteboard] setString:keychain];   // 共享出去

        }else{
            
            if (![keychain isEqualToString:deviceId]) {
                NSLog(@"MG-> deviceId：%@ keychain:%@ 不一致", deviceId, keychain);
                // 这种情况，1、全部卸载  2、下载新的app  3、下载一个旧的app， 4 打开旧的app不一致
                // 5 、 结果： 不做任何策略处理，老的app使用旧的账号，新的app可生成新的游客账号
            }
        }
    }
    
    return keychain;
}


- (UIPasteboard *) sharedPasteboard
{
    UIPasteboard *past = [UIPasteboard pasteboardWithName:@"com.tmgame.qmqj.keychain" create:NO];
    if (past==nil) {
        past = [UIPasteboard pasteboardWithName:@"com.tmgame.qmqj.keychain" create:YES];
        past.persistent = YES;
    }
    return past;
}


- (NSString *) MGShareDeviceId
{
    return [self initilizeMGKeyChain];
}


#pragma mark-- 用户保存的名单，白名单

- (void) addWhiteAccount:(NSString *)account pwd:(NSString *)pwd
{
    NSString *acc = [MGSSKeychain passwordForService:kMG_KeyChain_ServiceX account:kMG__Accounts];
    if ([acc length] > 0) {
        
        NSMutableArray *MArray = [NSMutableArray arrayWithArray:[acc componentsSeparatedByString:@"<>"]];
        
        __block NSInteger bIndex = -1;
        [MArray enumerateObjectsUsingBlock:^( NSString *acc, NSUInteger idx, BOOL *stop) {
            if ([acc hasPrefix:account]) {
                bIndex = idx;
                *stop = YES;
            }
        }];
        if (bIndex == -1) {
            [MArray addObject:[NSString stringWithFormat:@"%@:%@", account, pwd]];
            [MGSSKeychain setPassword:[MArray componentsJoinedByString:@"<>"] forService:kMG_KeyChain_ServiceX account:kMG__Accounts];
        }else{
            [MArray removeObjectAtIndex:bIndex];
            [MArray addObject:[NSString stringWithFormat:@"%@:%@", account, pwd]];
            [MGSSKeychain setPassword:[MArray componentsJoinedByString:@"<>"] forService:kMG_KeyChain_ServiceX account:kMG__Accounts];
        }
        
    }else{
        
        NSMutableArray *MArray = [NSMutableArray array];
        [MArray addObject:[NSString stringWithFormat:@"%@:%@", account, pwd]];
        [MGSSKeychain setPassword:[MArray componentsJoinedByString:@"<>"] forService:kMG_KeyChain_ServiceX account:kMG__Accounts];
    }
}

- (NSArray *) whiteAccountAndPassword
{
    NSString *acc = [MGSSKeychain passwordForService:kMG_KeyChain_ServiceX account:kMG__Accounts];
    return [acc componentsSeparatedByString:@"<>"];
}

- (void) removeWhiteAccount:(NSString *)account
{
    NSString *acc = [MGSSKeychain passwordForService:kMG_KeyChain_ServiceX account:kMG__Accounts];
    if ([acc length] > 0) {
        
        __block NSInteger index = -1;
        NSMutableArray *MArray = [NSMutableArray arrayWithArray:[acc componentsSeparatedByString:@"<>"]];
        [MArray enumerateObjectsUsingBlock:^(NSString *accpwd, NSUInteger idx, BOOL *stop) {
            if ([accpwd hasPrefix:account]) {
                index = idx;
                *stop = YES;
            }
        }];
        if (index != -1) {
            [MArray removeObjectAtIndex:index];
        }
        [MGSSKeychain setPassword:[MArray componentsJoinedByString:@"<>"] forService:kMG_KeyChain_ServiceX account:kMG__Accounts];
    }
}



//删除keychain中的共享数据
/*
- (void) MGSaveAccountPassword:(NSArray *) strings
{
    NSString *users = [strings componentsJoinedByString:@"<>"];
    [SSKeychain setPassword:users forService:kMG_KeyChain_ServiceX account:kMG_KeyChain_Accounts];
}

- (NSArray *) MGAccountsFromKeyChain
{
    NSString *pw = [SSKeychain passwordForService:kMG_KeyChain_ServiceX account:kMG_KeyChain_Accounts];
    NSArray *strings = [pw componentsSeparatedByString:@"<>"];
    return strings;
}
*/





#pragma mark-- 黑名单 黑名单表示用户删除的游戏用户

- (void) addBlackAccounts:(NSString *)account
{
    NSString *keychain_str;
    NSString *d_account = [MGSSKeychain passwordForService:kMG_KeyChain_ServiceX account:kMG_KeyChain_Accounts_Remote];
    if ([d_account length] > 0) {
        NSMutableArray *M = [NSMutableArray arrayWithArray:[d_account componentsSeparatedByString:@"<>"]];
        if (![M containsObject:account]) {
            [M addObject:account];
        }
        keychain_str = [M componentsJoinedByString:@"<>"];
    }else
        keychain_str = account;
    [MGSSKeychain  setPassword:keychain_str forService:kMG_KeyChain_ServiceX account:kMG_KeyChain_Accounts_Remote];
}

- (void) removeBlackAccount:(NSString *)account
{
    NSString *d_account = [MGSSKeychain passwordForService:kMG_KeyChain_ServiceX account:kMG_KeyChain_Accounts_Remote];
    if (d_account) {
        NSMutableArray *M = [NSMutableArray arrayWithArray:[d_account componentsSeparatedByString:@"<>"]];
        if ([M containsObject:account]) {
            [M removeObject:account];
        }
        NSString *keychain_s = [M componentsJoinedByString:@"<>"];
        if ([keychain_s length] > 0) {
            
            [MGSSKeychain setPassword:keychain_s forService:kMG_KeyChain_ServiceX account:kMG_KeyChain_Accounts_Remote];
        }
    }
}

- (BOOL) isInBlackAccounts:(NSString *) account
{
    NSString *d_account = [MGSSKeychain passwordForService:kMG_KeyChain_ServiceX account:kMG_KeyChain_Accounts_Remote];
    if (d_account) {
        NSArray *array = [d_account componentsSeparatedByString:@"<>"];
        return [array containsObject:account];
    }else
        return NO;
}







@end
