//
//  MGManager+MGUserInfo.h
//  MYGameManagerTest
//
//  Created by caosq on 14-7-10.
//  Copyright (c) 2014年 MG. All rights reserved.
//

#import "MGManager.h"

static NSString* const MGGetUserInfoNotification = @"MGGetUserInfoNotification";

///
@interface MGUserInfo : NSObject

@property (nonatomic, copy) NSString *uid;
@property (nonatomic, copy) NSString *token;
@property (nonatomic, copy) NSString *nick;
@property (nonatomic, copy) NSString *sex;
@property (nonatomic, copy) NSString *birth;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *mobile;
@property (nonatomic, copy) NSString *safeq;

@end


@interface MGManager (MGUserInfo)

@property (nonatomic, strong, readonly) MGUserInfo *mgUserInfo;

- (void) MGGetUserInfos;

- (void) MGClearUserInfos;

@end
