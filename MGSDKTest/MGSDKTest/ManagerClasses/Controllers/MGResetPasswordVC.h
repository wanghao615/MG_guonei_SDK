//
//  MGResetPasswordVC.h
//  MGPlatformTest
//
//  Created by wangcl on 14-8-19.
//  Copyright (c) 2014年 qmqj. All rights reserved.
//

#import "MGBaseViewController.h"

@interface MGResetPasswordVC : MGBaseViewController

@property (nonatomic, strong) NSString *account;
@property (nonatomic, setter = setTokenFlag:) NSString *token;

@end
