//
//  MGModelObj.h
//  MGPlatformTest
//
//  Created by 曹 胜全 on 6/12/14.
//  Copyright (c) 2014 Eason. All rights reserved.
//

#import <Foundation/Foundation.h>


#pragma mark-- 请求参数

@interface MGUserInfoObj : NSObject

@property (nonatomic, copy) NSString *uid;
@property (nonatomic, copy) NSString *token;

@end


@interface MGUserRegister : NSObject

@property (nonatomic, copy) NSString *account;
@property (nonatomic, copy) NSString *password1;
@property (nonatomic, copy) NSString *password2;
@property (nonatomic, copy) NSString *source;
//注册类型
@property (nonatomic, copy) NSString *type;
//验证码
@property (nonatomic, copy) NSString *code;


@end


@interface MGUserIdCard: NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *idCard;


@end



@interface MGVerifyCode : NSObject

@property (nonatomic, copy) NSString *uid;
@property (nonatomic, copy) NSString *number;  //mobile/email
//@property (nonatomic, copy) NSString *type;  //mobile/email 邮箱暂时不需要
@property (nonatomic, copy) NSString *token;

@end


@interface MGLoginInfo : NSObject

@property (nonatomic, copy) NSString *account;
@property (nonatomic, copy) NSString *password;

@end


@interface MGBoundMobile : NSObject

@property (nonatomic, copy) NSString *uid;
@property (nonatomic, copy) NSString *number;  // 手机号码或者邮箱
//@property (nonatomic, copy) NSString *type; // mobile/email 现在绑定分开两个接口不需要
@property (nonatomic, copy) NSString *code; // 验证码
@property (nonatomic, copy) NSString *token; // token

@end



@interface MGModifySecret : NSObject

@property (nonatomic, copy) NSString *uid;
@property (nonatomic, copy) NSString *oldpwd;
@property (nonatomic, copy) NSString *newpwd1;
@property (nonatomic, copy) NSString *newpwd2;
@property (nonatomic, copy) NSString *token;

@end





@interface MGChangeAccountInfo : NSObject

@property (nonatomic, copy) NSString *uid;
@property (nonatomic, copy) NSString *token;
@property (nonatomic, copy) NSString *nick; //可选
@property (nonatomic, copy) NSString *sex; // 0 为止 1男 2女 可选
@property (nonatomic, copy) NSString *birth; // 可选

@property (nonatomic, copy) NSString *safeq1;
@property (nonatomic, copy) NSString *safea1;
@property (nonatomic, copy) NSString *safeq2;
@property (nonatomic, copy) NSString *safea2;


@end




