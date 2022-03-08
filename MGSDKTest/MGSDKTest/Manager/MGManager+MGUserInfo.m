//
//  MGPlatform+MGUserInfo.m
//  MYGameManagerTest
//
//  Created by caosq on 14-7-10.
//  Copyright (c) 2014年 MG. All rights reserved.
//

#import "MGManager+MGUserInfo.h"
#import <objc/runtime.h>
#import "MGHttpClient.h"


@implementation MGUserInfo

@end




@interface MGManager()

@property (nonatomic, strong, readwrite) MGUserInfo *mgUserInfo;

@end

@implementation MGManager (MGUserInfo)

static char mg_userinfo_key;

- (void) setMgUserInfo:(MGUserInfo *)mgUserInfo
{
    objc_setAssociatedObject(self, &mg_userinfo_key, mgUserInfo, OBJC_ASSOCIATION_RETAIN);
}

- (MGUserInfo *) mgUserInfo
{
    MGUserInfo *info = objc_getAssociatedObject(self, &mg_userinfo_key);
    return info;
}

- (void) MGClearUserInfos
{
    self.mgUserInfo = nil;
}


- (void) MGGetUserInfos
{
    if ([[self MGOpenUID] length] == 0 || [[self MGToken] length] == 0) {
        return;
    }
    MGUserInfoObj *obj =[[MGUserInfoObj alloc] init];
    
    obj.uid = [self MGOpenUID];
    obj.token = [self MGToken];
    
    __weak MGManager *weakself = self;
    [[MGHttpClient shareMGHttpClient] getUserInfo:obj completion:^(NSDictionary *responseDic) {
       
        id obj = responseDic[@"data"];
        if ([obj isKindOfClass:[NSDictionary class]]) {
            
            MGUserInfo *info = [[MGUserInfo alloc] init];
            info.uid = [self MGOpenUID];
            info.token = [self MGToken];
            if (![obj[@"nick"] isEqual:[NSNull null]]) {
                info.nick = [NSString stringWithFormat:@"%@", obj[@"nick"]];
            }
            if (![obj[@"birth"] isEqual:[NSNull null]]) {
                info.birth = [NSString stringWithFormat:@"%@", obj[@"birth"]];
            }

            if (![obj[@"sex"] isEqual:[NSNull null]]) {
                info.sex = [NSString stringWithFormat:@"%@", obj[@"sex"]];
            }
            if (![obj[@"email"] isEqual:[NSNull null]]) {
                info.email = [NSString stringWithFormat:@"%@", obj[@"email"]];
            }
            if (![obj[@"phone"] isEqual:[NSNull null]]) {
                info.mobile = [NSString stringWithFormat:@"%@", obj[@"phone"]];
            }
            if (![obj[@"safeQ"] isEqual:[NSNull null]]) {
                info.safeq = [NSString stringWithFormat:@"%@", obj[@"safeQ"]];
            }
            
            objc_setAssociatedObject(self, &mg_userinfo_key, nil, OBJC_ASSOCIATION_RETAIN);
            [weakself setMgUserInfo:info];
            
            [weakself performSelector:@selector(sendGetUserInfoNotification:) withObject:nil];
        }
        
    } failed:^(NSInteger ret, NSString *errMsg) {
        
        [weakself performSelector:@selector(sendGetUserInfoNotification:) withObject:@{kMGPlatformErrorMsg: errMsg}];
        
    }];
}


- (void) sendGetUserInfoNotification:(id)obj
{
    [[NSNotificationCenter defaultCenter] postNotificationName:MGGetUserInfoNotification object:obj];
}


@end
