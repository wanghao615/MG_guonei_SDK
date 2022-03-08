//
//  MGUserDefaults.m
//  MGPlatformDemo
//
//  Created by SunYuan on 14-4-28.
//  Copyright (c) 2014年 Eason. All rights reserved.
//

#import "MGStorage.h"
//#import "SSKeychain.h"
#import "MGKeyChain.h"
#import "NSData+MGCryptUtil.h"
#import "MGUserDefault.h"
#import "NSString+MGString.h"

static NSString *const kMGUserAutomaticLogin = @"kMGUserAutomaticLogin";
static NSString *const kMGRememberSecret = @"kMGRememberSecret";

static NSString* const kMG_KeyChain_Service = @"com.mg.sdk";
static NSString* const kMG_KeyChain_Account = @"com.mg.sdk.account";
static NSString* const kMG_KeyChain_Password = @"com.mg.sdk.password";
static NSString* const kMG_KeyChain_Uid = @"com.mg.sdk.uid";
static NSString* const kMG_KeyChain_Guest_Uid = @"com.mg.sdk.guest.uid";
static NSString* const kMG_KeyChain_Token = @"com.mg.sdk.token";

static NSString* const kMG_KeyChain_ToolBarFrame = @"com.mg.sdk.toolbar";

static NSString *const kMG_KeyChain_Last_Account = @"com.mg.sdk.account.last";




static NSString *const MG_SHARE_KEY = @"MGzs00@!*&#^*@(ksk";

@implementation MGAccount

+ (MGAccount *) newAccountWithAccount:(NSString *) account andPassword:(NSString *) password
{
    return [[MGAccount alloc] initWithAccount:account andPassword:password];
}

- (instancetype) initWithAccount:(NSString *) account andPassword:(NSString *) password
{
    if (self == [super init]) {
        self.account =account;
        self.pwData = [NSString AES256Encrypt:password withKey:MG_SHARE_KEY];
    }
    return self;
}

@end



@implementation MGStorage


#define LIB_PATH  [NSHomeDirectory() stringByAppendingPathComponent:@"Library"]

+ (void) initializationMGStorage  //初始化做必要的数据转移。 特别是在版本升级的时候
{
    //判断Account, 游戏升级之后， 从sqlite中的用户数据转移到MGAccountSettingInfo对象中
    NSString *account = [self getFromUserDefaultByKey:kMG_KeyChain_Account];
    if ([account length] > 0) {  //说明有数据，可能是从老版本中升级过来的
        MGAccountSettingInfo *info = [self accountSettingInfoByAccount:account];
        if (info != nil) {
            info.secret = [[MGUserDefault defaultUserDefaults] objectForKey:kMG_KeyChain_Password];   //密码加密
            info.uid = [self getFromUserDefaultByKey:kMG_KeyChain_Uid];
            info.token = [self getFromUserDefaultByKey:kMG_KeyChain_Token];
            info.lastOrderNum = [[MGUserDefault defaultUserDefaults] stringValueForKey:@"kMGLastOrder"];
            [self setOneAccountSettingInfo:info isCurrentAccount:YES];
        }
        [self removeFromUserDefaultByKey:kMG_KeyChain_Account];   // remove掉老数据
        [self removeFromUserDefaultByKey:kMG_KeyChain_Password];
        [self removeFromUserDefaultByKey:kMG_KeyChain_Uid];
        [self removeFromUserDefaultByKey:kMG_KeyChain_Token];
    }
    
    [[MGKeyChainManager shareMGKeyChain] MGShareDeviceId];  //初始化一下
    iShareCount = [[self MGShareAccounts] count];
}


+ (void) syncWhiteAccountToAccountSetting
{
    // 白名单
    NSArray *accouns =  [[MGKeyChainManager shareMGKeyChain] whiteAccountAndPassword];
    [accouns enumerateObjectsUsingBlock:^(NSString *oneuser, NSUInteger idx, BOOL *stop) {
        NSArray *array = [oneuser componentsSeparatedByString:@":"];
        if ([array count] == 2) {
            NSString *acc = [array firstObject];

            MGAccountSettingInfo *info = [self bIncludeAccountSettingInfos:acc];
            if (info != nil && info.secret == nil) {
                info.secret = [MGStorage AES256Encrypt:[array objectAtIndex:1]];
            }
            [self saveOneAccountSettingInfo:info];
        }
    }];
}

+ (void) syncAccountSettingToWhiteAccount:(MGAccountSettingInfo *) info  isAddAction:(BOOL) bAdd
{
    if (info == nil) {
        return;
    }
    
    if (info.isGuestAccount) {
        return;
    }
    
    
    if (bAdd) {
        
        // 同步白名单
        if (info.bRememberSecret) {
            [[MGKeyChainManager shareMGKeyChain] addWhiteAccount:info.account pwd:[NSString AES256Decrypt:info.secret withKey:KMG_S]];
        }else{
            [[MGKeyChainManager shareMGKeyChain] addWhiteAccount:info.account pwd:nil];
        }
        
        // 同步黑名单  白名单已经有了 删除黑名单
        
        if ([[MGKeyChainManager shareMGKeyChain] isInBlackAccounts:info.account]) {
            [[MGKeyChainManager shareMGKeyChain] removeBlackAccount:info.account];
        }
        
        // 同步共享
        [self MGShareAddOneAccount:[MGAccount newAccountWithAccount:info.account andPassword:[NSString AES256Decrypt:info.secret withKey:KMG_S]]];

    }else{  // remove
        
        [[MGKeyChainManager shareMGKeyChain] removeWhiteAccount:info.account];
        [[MGKeyChainManager shareMGKeyChain] addBlackAccounts:info.account];
        [self MGShareRemoveOneAccountByAccount:info.account];
    }
    
    iShareCount = [[self MGShareAccounts] count];
}



+ (BOOL) storeLastOrder:(NSString *) orderNum
{
    [[MGUserDefault defaultUserDefaults] setObject:orderNum forKey:@"kMGLastOrder"];

    return YES;
}

+ (NSString *) getLastOrder
{
    return  [[MGUserDefault defaultUserDefaults] stringValueForKey:@"kMGLastOrder"];
}

+ (BOOL)getAutomaticLoginBool
{
    return  [[MGUserDefault defaultUserDefaults] boolValueForKey:kMGUserAutomaticLogin];
}

+ (void)saveAutomaticLoginBool:(BOOL)AutomaticLoginBool
{
    [[MGUserDefault defaultUserDefaults] setBoolValue:AutomaticLoginBool forKey:kMGUserAutomaticLogin];
}

+ (void) saveIsRememberSecret:(BOOL) bRemember
{
    [[MGUserDefault defaultUserDefaults] setBoolValue:bRemember forKey:kMGRememberSecret];
}

+ (BOOL) getIsRememberSecret
{
    return [[MGUserDefault defaultUserDefaults] boolValueForKey:kMGRememberSecret];
}


//////*******
// AES

+ (BOOL) saveToUserDefaultKey:(NSString *) key andValue:(id) value
{
    id data;
    if ([value isKindOfClass:[NSString class]]) {
        data = [NSString AES256Encrypt:value withKey:KMG_S];
    }else if ([value isKindOfClass:[NSData class]]){
        data = [value AES256EncryptWithKey:KMG_S];
    }else
        data = value;
    
    [[MGUserDefault defaultUserDefaults] setObject:data forKey:key];

    return YES;
}

+ (NSString *) getFromUserDefaultByKey:(NSString *) key
{
    id data = [[MGUserDefault defaultUserDefaults] objectForKey:key];
    if (![data isKindOfClass:[NSData class]]) {
        data = [data dataUsingEncoding:NSUTF8StringEncoding];
    }
    return [NSString AES256Decrypt:data withKey:KMG_S];
}

+ (BOOL) removeFromUserDefaultByKey:(NSString *) key
{
    [[MGUserDefault defaultUserDefaults] removeObjectForKey:key];
    return YES;
}


+ (BOOL) storeToKeyChainLoginAccount:(NSString *) account
{
    return [self saveToUserDefaultKey:kMG_KeyChain_Account andValue:account];
}

+ (BOOL) storeToKeyChainLoginAccount:(NSString *) account andPassword:(NSString *) password
{
    BOOL bSaved = [self saveToUserDefaultKey:kMG_KeyChain_Account andValue:account];
    bSaved = [self saveToUserDefaultKey:kMG_KeyChain_Password andValue:password];
    return bSaved;
}

+ (BOOL) storeChangedPassword:(NSString *) password
{
    return [self saveToUserDefaultKey:kMG_KeyChain_Password andValue:password];
}


+ (id) getAccount
{
    NSString *account = [self getFromUserDefaultByKey:kMG_KeyChain_Account];
    if ([account length] == 0) {
        account = [self lastAccount];
    }
    return account;
}

+ (id) getSecret
{
    id secret = [self getFromUserDefaultByKey:kMG_KeyChain_Password];
    if ([secret length] == 0) {
        MGAccountSettingInfo *info = [self currentAccountSettingInfo];
        secret = [NSString AES256Decrypt:info.secret withKey:KMG_S];
    }
    return secret;
}

+ (BOOL) removeSecret
{
    return [self removeFromUserDefaultByKey:kMG_KeyChain_Password];
}

+ (BOOL)removeAccountAndSecret {
    return [self removeFromUserDefaultByKey:kMG_KeyChain_Password] && [self removeFromUserDefaultByKey:kMG_KeyChain_Account];
}

+ (BOOL) removeUid
{
    return [self removeFromUserDefaultByKey:kMG_KeyChain_Uid];
}

+ (BOOL) removeToken
{
    return [self removeFromUserDefaultByKey:kMG_KeyChain_Token];
}


+ (void) storeToKeyChainUid:(id)uid andToken:(id)token
{
    [self saveToUserDefaultKey:kMG_KeyChain_Uid andValue:uid];
    [self saveToUserDefaultKey:kMG_KeyChain_Token andValue:token];
}

+ (id) getUid
{
    id uid = [self getFromUserDefaultByKey:kMG_KeyChain_Uid];
    if ([uid length] == 0) {
        MGAccountSettingInfo *info = [self currentAccountSettingInfo];
        uid  = info.uid;
    }
    return uid;
}

+ (id) getToken
{
    id token = [self getFromUserDefaultByKey:kMG_KeyChain_Token];
    if ([token length] == 0) {
        MGAccountSettingInfo *info = [self currentAccountSettingInfo];
        token = info;
    }
    return token;
}

+ (BOOL) storeToolBarFrame:(CGRect) frame
{
    return [self saveToUserDefaultKey:kMG_KeyChain_ToolBarFrame andValue:NSStringFromCGRect(frame)];
}

+ (CGRect) getToolBarFrame
{
   NSString *frame = [self getFromUserDefaultByKey:kMG_KeyChain_ToolBarFrame];
    if ([frame length] == 0) {
        return CGRectZero;
    }else
        return CGRectFromString(frame);
}


+ (BOOL) isStoreAccountEmpty {
    NSString *account = [MGStorage getAccount];
    return [NSString stringIsEmpty:account];
}


+ (UIPasteboard *) sharedPasteboard
{
    UIPasteboard *past = [UIPasteboard pasteboardWithName:@"com.tmgame.qmqj" create:NO];
    if (past==nil) {
        past = [UIPasteboard pasteboardWithName:@"com.tmgame.qmqj" create:YES];
        past.persistent = YES;
    }
    return past;
}


+ (BOOL) removeGuestUid
{
    return [self removeFromUserDefaultByKey:kMG_KeyChain_Guest_Uid];
}

+ (void) storeToKeyChainGuestUid:(id)guestUid
{
    [self saveToUserDefaultKey:kMG_KeyChain_Guest_Uid andValue:guestUid];
}

+ (id) getGuestUid
{
    NSArray *accounts = [self allAccountSettings];
    __block MGAccountSettingInfo *_info = nil;
    [accounts enumerateObjectsUsingBlock:^(MGAccountSettingInfo *info, NSUInteger idx, BOOL *stop) {
        if (info.isGuestAccount) {
            _info = info;
            *stop = YES;
        }
    }];
    return _info.uid;
}




#pragma mark-- MGShareAccounts ------------------began----------------------------

static NSInteger iShareCount = 0;

+ (NSInteger) MGShareAccountsCount
{
    return iShareCount;
}


+ (NSArray *) MGShareAccounts
{
    NSMutableArray *M = [NSMutableArray new];
    
    NSArray *strings = [[self sharedPasteboard] strings];
    
    [strings enumerateObjectsUsingBlock:^(NSString *acc_str, NSUInteger idx, BOOL *stop) {
        
        NSArray *array = [acc_str componentsSeparatedByString:@":"];
        if ([array count] == 2) {
            NSString *pw = [array objectAtIndex:1];
            NSData *pwData =  [pw MGbase64DecodedData];
            MGAccount *account = [MGAccount new];
            account.account = [array firstObject];
            account.pwData = pwData;
            [M addObject:account];
        }
    }];
    return M;
}


+ (void) MGShareAddOneAccount:(MGAccount *)account
{
    NSArray *array =  [self MGShareAccounts]; // [self sharedPasteboard].strings;
    NSMutableArray *MArray = [NSMutableArray arrayWithArray:array];
    
    __block MGAccount *theAccount = nil;
    [MArray enumerateObjectsUsingBlock:^(MGAccount *innerAccount, NSUInteger idx, BOOL *stop) {
        if ([innerAccount.account isEqualToString:account.account]) {
            theAccount = innerAccount;
            *stop = YES;
        }
    }];
    if (theAccount != nil) {
        theAccount.pwData =  account.pwData;
    }else{
        [MArray addObject:account];
    }
    
    [self saveToPasteboard:nil];
    
    NSMutableArray *strings = [NSMutableArray new];
    [MArray enumerateObjectsUsingBlock:^(MGAccount *oneAccount, NSUInteger idx, BOOL *stop) {
        [strings addObject:[NSString stringWithFormat:@"%@:%@", oneAccount.account, [oneAccount.pwData MGbase64EncodedString]]];
    }];
    [self saveToPasteboard:strings];
    
}

+ (BOOL) MGShareMaybeChanged
{
    return iShareCount < [[self MGShareAccounts] count];  // 有共享数据来了
}


+ (MGAccount *) MGAccountByAccount:(NSString *) account
{
    __block MGAccount *_theAccount = nil;
    [[self MGShareAccounts] enumerateObjectsUsingBlock:^(MGAccount *oneAccount, NSUInteger idx, BOOL *stop) {
        if ([oneAccount.account isEqualToString:account]) {
            _theAccount = oneAccount;
            *stop = YES;
        }
    }];    
    return _theAccount;
}


+ (void) MGShareRemoveOneAccountByAccount:(NSString *) account
{
    NSArray *array =  [self MGShareAccounts]; // [self sharedPasteboard].strings;
    NSMutableArray *MArray = [NSMutableArray arrayWithArray:array];
    
    __block MGAccount *theAccount = nil;
    [MArray enumerateObjectsUsingBlock:^(MGAccount *innerAccount, NSUInteger idx, BOOL *stop) {
        if ([innerAccount.account isEqualToString:account]) {
            theAccount = innerAccount;
            *stop = YES;
        }
    }];
    if (theAccount != nil) {
        [MArray removeObject:theAccount];
    }
    
    [self saveToPasteboard:nil];
    
    NSMutableArray *strings = [NSMutableArray new];
    [MArray enumerateObjectsUsingBlock:^(MGAccount *oneAccount, NSUInteger idx, BOOL *stop) {
        [strings addObject:[NSString stringWithFormat:@"%@:%@", oneAccount.account, [oneAccount.pwData MGbase64EncodedString]]];
    }];
    [self saveToPasteboard:strings];    
}


+ (void) saveToPasteboard:(NSArray *) strings
{
    [[self sharedPasteboard] setStrings:strings];
}

#pragma mark-- MGShareAccounts ------------------end----------------------------



+ (NSData *) AES256Encrypt:(NSString *)src
{
    return [NSString AES256Encrypt:src withKey:KMG_S];
}


#pragma mark--
//#define MGAccountPath [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory,NSUserDomainMask,YES) objectAtIndex:0] stringByAppendingPathComponent:@"MG_account_setting"]]

+ (NSString *) settingFileName
{
    NSString *path =[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory,NSUserDomainMask,YES) objectAtIndex:0];
    NSString *fileName = [path stringByAppendingPathComponent:@"MG_account_setting"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:fileName]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:fileName withIntermediateDirectories:NO attributes:nil error:nil];
    }
    return fileName;
}

static bool MG_reload_account = YES;
static NSArray *_MGAccounts = nil;


+ (void) setAccountSettingsWithRemoteData:(NSArray *) accounts
{
    if (accounts != nil  && ![accounts isEqual:[NSNull null]]) {
        
        [accounts enumerateObjectsUsingBlock:^(NSDictionary *account, NSUInteger idx, BOOL *stop) {
            
            
                MGAccountSettingInfo *info = [self accountSettingInfoByAccount:account[@"username"]];
            
                [MGStorage saveOneAccountSettingInfo:info];
            
        }];
    }
    
    [self syncWhiteAccountToAccountSetting];    //和keychain同步一下密码
    
}


+ (NSArray *) allAccountSettings
{
    //    [MGKeyChain mgKeyChainDelete:KEY_USERLOGIN_INFO];
    //    [MGKeyChain mgKeyChainDelete:KEY_USERINFO];
    if (!_MGAccounts || MG_reload_account) {
        MG_reload_account = NO;
        //        [MGKeyChain mgKeyChainDelete:KEY_USERLOGIN_INFO];
        _MGAccounts = [MGKeyChain mgKeyChainLoad:KEY_USERLOGIN_INFO];
        //        _MGAccounts = [NSKeyedUnarchiver unarchiveObjectWithFile:[self settingFileName]];
        if (_MGAccounts.count < 1) {
            _MGAccounts = [MGStorage getAccountbyfive];
        }
    }
    return _MGAccounts;
}

+ (NSArray *) allAccountSettingsExceptGuest
{
    NSArray *array = [self allAccountSettings];
  __block NSMutableArray *M = [NSMutableArray new];
    [array enumerateObjectsUsingBlock:^(MGAccountSettingInfo *info, NSUInteger idx, BOOL *stop) {
        if (!info.isGuestAccount) {
            [M addObject:info];
        }
    }];

    return M;
}



+ (MGAccountSettingInfo *) bIncludeAccountSettingInfos:(NSString *) account
{
    NSArray *allAs = [self allAccountSettings];
    __block MGAccountSettingInfo *_info = nil;
    [allAs enumerateObjectsUsingBlock:^(MGAccountSettingInfo *settingInfo, NSUInteger idx, BOOL *stop) {
        if ([settingInfo.account isEqualToString:account]) {
            _info = settingInfo;
            *stop = YES;
        }
    }];
    return _info;
}

+ (MGAccountSettingInfo *) firstAccountSettingInfo
{
    return [[self allAccountSettings] firstObject];
}

//得到用户信息
+ (MGAccountSettingInfo *) findGuestAccountSettingInfo
{
    NSArray *array = [self allAccountSettings];
    MGAccountSettingInfo *_info = nil;
    for (MGAccountSettingInfo *info  in array) {
        if (info.isGuestAccount) {
            _info = info;
            break;
        }
    }
    return _info;
}


+ (MGAccountSettingInfo *) findNotGuestAccountSettingInfo
{
    NSArray *array = [self allAccountSettings];
    MGAccountSettingInfo *_info = nil;
    for (MGAccountSettingInfo *info  in array) {
        if (!info.isGuestAccount) {
            _info = info;
            break;
        }
    }
    return _info;
}


+ (MGAccountSettingInfo *) accountSettingInfoByAccount:(NSString *) account
{
    NSArray *allAs = [self allAccountSettings];
    __block MGAccountSettingInfo *_info = nil;
    [allAs enumerateObjectsUsingBlock:^(MGAccountSettingInfo *settingInfo, NSUInteger idx, BOOL *stop) {
        if ([settingInfo.account isEqualToString:account]) {
            _info = settingInfo;
            *stop = YES;
        }
    }];
    if (_info == nil && [account length] > 0) {
        _info = [MGAccountSettingInfo new];
        _info.account = account;
        _info.bAutoLogin = YES;
        _info.bRememberSecret = YES;
        _info.isGuestAccount = NO;     //默认不是游客
    }
    return _info;
}

+ (void) setOneAccountSettingInfo:(MGAccountSettingInfo *) asInfo isCurrentAccount:(BOOL) bCurrent
{
    [self saveOneAccountSettingInfo:asInfo];
    
    if (bCurrent) {
        
        if (![[self lastAccount] isEqualToString:asInfo.account]) {
            [self saveAsLastAccount:asInfo.account];
        }
        
    }else{
        if ([[self lastAccount] isEqualToString:asInfo.account]) {
            [self removeLastAccount];
        }
    }
    
}

+ (void) saveOneAccountSettingInfo:(MGAccountSettingInfo *) asInfo
{
    if (asInfo == nil) return;
    
    [MGStorage setAccountWithModel:asInfo];
    
    NSMutableArray *M = [NSMutableArray arrayWithArray:[self allAccountSettings]];
    __block MGAccountSettingInfo *_as = nil;
    [M enumerateObjectsUsingBlock:^(MGAccountSettingInfo *innerInfo, NSUInteger idx, BOOL *stop) {
        if ([innerInfo.account isEqualToString:asInfo.account]) {
            _as = innerInfo;
            *stop = YES;
        }
    }];
    [M removeObject:_as];
    [M addObject:asInfo];
    _MGAccounts = M;
    [self saveAccountSettingsAction:M];
    
    [self syncAccountSettingToWhiteAccount:asInfo isAddAction:YES];
}


+ (void) saveAccountSettingsAction:(NSArray *) allAccounts
{
    [MGKeyChain mgKeyChainSave:KEY_USERLOGIN_INFO data:allAccounts];
    

    BOOL bSave = [NSKeyedArchiver archiveRootObject:allAccounts toFile:[self settingFileName]];
    MG_reload_account = bSave;
    if (!bSave) {
        NSLog(@"MG 保存用户设置失败");
    }
}




+ (void) saveAsLastAccount:(NSString *) account
{
    [MGKeyChain mgKeyChainSave:KEY_USERACCOUNT data:account];
    [[MGUserDefault defaultUserDefaults] setObject:account forKey:kMG_KeyChain_Last_Account];
}

+ (id) lastAccount
{
    return [MGKeyChain mgKeyChainLoad:KEY_USERACCOUNT];
}

+ (void) removeLastAccount
{
    [MGKeyChain mgKeyChainDelete:KEY_USERACCOUNT];
    [[MGUserDefault defaultUserDefaults] removeObjectForKey:kMG_KeyChain_Last_Account];

}


+ (MGAccountSettingInfo *) currentAccountSettingInfo
{
    NSString *lastAccount = [self lastAccount];
    __block MGAccountSettingInfo *_theAccount = nil;
    [[self allAccountSettings] enumerateObjectsUsingBlock:^(MGAccountSettingInfo *innerInfo, NSUInteger idx, BOOL *stop) {
        if ([innerInfo.account isEqualToString:lastAccount] && [lastAccount length] > 0) {
            _theAccount = innerInfo;
            *stop = YES;
        }
    }];
    return _theAccount;
}


+ (void) removeAccountSettingInfoByAccount:(NSString *) account
{
    NSMutableArray *M = [NSMutableArray arrayWithArray:[self allAccountSettings]];
    __block MGAccountSettingInfo *_as = nil;
    [M enumerateObjectsUsingBlock:^(MGAccountSettingInfo *innerInfo, NSUInteger idx, BOOL *stop) {
        if ([innerInfo.account isEqualToString:account]) {
            _as = innerInfo;
            *stop = YES;
        }
    }];
    
    if (_as != nil) {
        [M removeObject:_as];
        _MGAccounts = M;
        [self syncAccountSettingToWhiteAccount:_as isAddAction:NO];
        [self saveAccountSettingsAction:M];
        
    }
    [MGStorage removeAccountWithModel:_as];
}

+ (void) removeAccountSettingInfoByUid:(NSString *) uid
{
    NSMutableArray *M = [NSMutableArray arrayWithArray:[self allAccountSettings]];
    __block MGAccountSettingInfo *_as = nil;
    [M enumerateObjectsUsingBlock:^(MGAccountSettingInfo *innerInfo, NSUInteger idx, BOOL *stop) {
        if ([innerInfo.uid isEqualToString:uid]) {
            _as = innerInfo;
            *stop = YES;
        }
    }];
    
    if (_as != nil) {
        [M removeObject:_as];
        _MGAccounts = M;
        [self saveAccountSettingsAction:M];
        
        [self syncAccountSettingToWhiteAccount:_as isAddAction:NO];
    }
}

//删除账号
+ (void)removeAccountWithModel:(MGAccountSettingInfo *)model {
    
    NSMutableString *Strarray = [MGKeyChain mgKeyChainLoad:KEY_USERINFO];
    NSArray *sourceArray = [Strarray componentsSeparatedByString:@"<>"];
    NSMutableArray *tempArray = [NSMutableArray arrayWithArray:sourceArray];
    [tempArray removeLastObject];
    NSMutableString *resultStr = [NSMutableString string];
    for (int i = 0; i < tempArray.count; i++) {
        NSString *obj =  tempArray[i];
        NSString *account = [obj componentsSeparatedByString:@":"].firstObject;
        NSString *secret = [obj componentsSeparatedByString:@":"].lastObject;
        if (![account isEqualToString:model.account]) {
            [resultStr appendString:[NSString stringWithFormat:@"%@:%@<>",account,secret]];
        }
        
    }
    
    [MGKeyChain mgKeyChainSave:KEY_USERINFO data:resultStr];
}
//取账号
+ (NSArray *)getAccountbyfive{
   NSMutableString *Strarray = [MGKeyChain mgKeyChainLoad:KEY_USERINFO];
    NSArray *sourceArray = [Strarray componentsSeparatedByString:@"<>"];
    NSMutableArray *tempArray = [NSMutableArray arrayWithArray:sourceArray];
    [tempArray removeLastObject];
    NSMutableArray *resultArray = [NSMutableArray array];
    for (int i = 0; i < tempArray.count; i++) {
        MGAccountSettingInfo *model =  [[MGAccountSettingInfo alloc]init];
        model.account = [tempArray[i] componentsSeparatedByString:@":"].firstObject;
        model.secret = [NSString AES256Encrypt:[tempArray[i] componentsSeparatedByString:@":"].lastObject withKey:KMG_S];
        model.bRememberSecret = YES;
        model.bAutoLogin = YES;
        model.isGuestAccount = false;
        [resultArray addObject:model];
    }
    return resultArray;
}

//存账号
+ (void)setAccountWithModel:(MGAccountSettingInfo *)model {
    
    NSMutableString *Strarray = [MGKeyChain mgKeyChainLoad:KEY_USERINFO];
    if (Strarray == nil) {
        Strarray = [NSMutableString string];
    }
    NSArray *sourceArray = [Strarray componentsSeparatedByString:@"<>"];
    NSMutableArray *tempArray = [NSMutableArray arrayWithArray:sourceArray];
    [tempArray removeLastObject];
    NSMutableString *newAccounts = [NSMutableString string];
    
    
    if([Strarray containsString:model.account]){
        
        for (int i = 0; i < tempArray.count; i++) {
            if (![tempArray[i] containsString:model.account]) {
                [newAccounts appendString:[NSString stringWithFormat:@"%@<>",tempArray[i]]];
            }
        }
        [MGKeyChain mgKeyChainSave:KEY_USERINFO data:[MGStorage connectionStrWithModel:model oldString:newAccounts]];
        
        return;
    }
    else{
        if (tempArray.count >= 5) {
            
            [tempArray removeLastObject];
            for (int i = 0; i < tempArray.count; i++) {
                [newAccounts appendString:[NSString stringWithFormat:@"%@<>",tempArray[i]]];
            }
            [MGKeyChain mgKeyChainSave:KEY_USERINFO data:[MGStorage connectionStrWithModel:model oldString:newAccounts]];
        }else {
            [MGKeyChain mgKeyChainSave:KEY_USERINFO data:[MGStorage connectionStrWithModel:model oldString:Strarray]];
        }
        
    }
    
}

//拼接字符串 <>分割
+ (NSString *)connectionStrWithModel:(MGAccountSettingInfo *)model oldString:(NSString *)oldStr{
    
    NSMutableString *modelStr = [NSMutableString stringWithString:oldStr];
    [modelStr appendString:[NSString stringWithFormat:@"%@:%@<>",model.account,[NSString AES256Decrypt:model.secret withKey:KMG_S]]];
    return modelStr;
}


@end



/*
 @property (nonatomic, copy) NSString *account;
 @property (nonatomic, copy) NSData *secret;
 @property (nonatomic, copy) NSString *uid;
 @property (nonatomic, copy) NSString *token;
 @property (nonatomic, assign) BOOL bRememberSecret;
 @property (nonatomic, assign) BOOL bAutoLogin;
 @property (nonatomic, assign) BOOL isGuestAccount;
 
 @property (nonatomic, copy) NSString *lastOrderNum;
*/


@implementation MGAccountSettingInfo

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.account = [aDecoder decodeObjectForKey:@"account"];
        self.bAutoLogin = [aDecoder decodeBoolForKey:@"autologin"];
        self.bRememberSecret = [aDecoder decodeBoolForKey:@"rememberSecret"];
        self.uid = [aDecoder decodeObjectForKey:@"uid"];
        self.token = [aDecoder decodeObjectForKey:@"token"];
        self.phoneNum = [aDecoder decodeObjectForKey:@"phoneNum"];
        self.phoneStatus = [aDecoder decodeObjectForKey:@"phoneStatus"];
        self.idCardBindStatus = [aDecoder decodeObjectForKey:@"idCardBindStatus"];
        self.secret = [aDecoder decodeObjectForKey:@"secret"];
        self.isGuestAccount = [aDecoder decodeBoolForKey:@"isGuestAccount"];
        self.lastOrderNum = [aDecoder decodeObjectForKey:@"lastOrderNum"];
        self.is_adult = [aDecoder decodeObjectForKey:@"is_adult"];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.account forKey:@"account"];
    [aCoder encodeBool:self.bAutoLogin forKey:@"autologin"];
    [aCoder encodeBool:self.bRememberSecret forKey:@"rememberSecret"];
    [aCoder encodeObject:self.uid forKey:@"uid"];
    [aCoder encodeObject:self.token forKey:@"token"];
    [aCoder encodeObject:self.phoneNum forKey:@"phoneNum"];
    [aCoder encodeObject:self.phoneStatus forKey:@"phoneStatus"];
    [aCoder encodeObject:self.idCardBindStatus forKey:@"idCardBindStatus"];
    [aCoder encodeObject:self.secret forKey:@"secret"];
    [aCoder encodeBool:self.isGuestAccount forKey:@"isGuestAccount"];
    [aCoder encodeObject:self.lastOrderNum forKey:@"lastOrderNum"];
    [aCoder encodeObject:self.is_adult forKey:@"is_adult"];
}

@end



