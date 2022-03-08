//
//  LoginViewController.h
//  MGPlatformTest
//
//  Created by caosq on 14-6-11.
//  Copyright (c) 2014年 Eason. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGBaseViewController.h"

typedef enum MGLoginType_ {
	MGLoginTypeNormal = 0,
	MGLoginTypeAutoLogin,
    MGLoginTypeGuest
} MGLoginType;

@interface MGLoginViewController : MGBaseViewController

- (instancetype)  initWithLoginType:(MGLoginType) loginType;

@end
