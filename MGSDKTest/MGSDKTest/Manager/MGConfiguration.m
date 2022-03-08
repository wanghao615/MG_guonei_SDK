//
//  MGConfiguration.m
//  MGSDKTest
//
//  Created by ZYZ on 2018/1/31.
//  Copyright © 2018年 MG. All rights reserved.
//

#import "MGConfiguration.h"
static MGConfiguration* shareConfiguration = nil;

@interface MGConfiguration()


@end
@implementation MGConfiguration

- (instancetype)init{
    self = [super init];
    if (self) {
        [self addObserver:self forKeyPath:@"showPrivacyNew" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (NSString *)auth_login {
    if (_auth_login == nil) {
        _auth_login = @"2";
    }
    return _auth_login;
}
- (NSString *)auth_pay {
    if (_auth_pay == nil) {
        _auth_pay = @"2";
    }
    return _auth_pay;
}
- (NSString *)oneKeyReg {
    if (_oneKeyReg == nil) {
        _oneKeyReg = @"1";
    }
    return _oneKeyReg;
}
- (NSString *)isAll {
    if (_isAll == nil) {
        _isAll = @"1";
    }
    return _isAll;
}

- (int)privacy_version{
    if (_privacy_version&&_privacy_version>0) {
        return _privacy_version;
    }
    return 0;
}


- (BOOL)showPrivacyNew{
    
    if (![[NSUserDefaults standardUserDefaults]objectForKey:GDSaveDidPrivacyVersion]) {
        return YES;
    }
   
    if ([[[NSUserDefaults standardUserDefaults]objectForKey:GDSaveDidPrivacyVersion] intValue] != self.privacy_version &&self.privacy_version!=0 ) {
        return YES;
    }
    return NO;
}

+ (MGConfiguration *)shareConfiguration
{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareConfiguration = [[MGConfiguration alloc] init];
    });
    
    return shareConfiguration;
}



-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{

    [[NSNotificationCenter defaultCenter]postNotificationName:GDListenForAttributeDidChanges object:nil userInfo:@{@"showPrivacyNew":[NSString stringWithFormat:@"%d",self.showPrivacyNew]}];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}


@end
