//
//  MGUtility.m
//  MGPlatformDemo
//
//  Created by SunYuan on 14-4-25.
//  Copyright (c) 2014年 Eason. All rights reserved.
//

#import "MGUtility.h"
#import <CommonCrypto/CommonDigest.h>
#import "MGUITextField_XLine.h"
#import "MGSSKeychain.h"


@implementation MGUtility


+ (NSString *) generateDeviceId
{
    NSString *deviceId = [self getUUID];
    if (deviceId == nil || [deviceId length] == 0) {
        
        if (TT_IS_IOS6_AND_UP) {
            deviceId = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        } else {
            deviceId = [NSString MD5String:[[UIDevice currentDevice] macaddress]];
        }
    }
    return deviceId == nil ? @"" : deviceId;
}

+ (NSString *) getUUID
{
    NSString *uuid = [MGSSKeychain passwordForService:@"com.mg.sdk" account:@"com.mg.sdk.uuid"];
    if (uuid == nil || [uuid length] == 0) {
        uuid = [self newUUID];
        [MGSSKeychain setPassword:uuid forService:@"com.mg.sdk" account:@"com.mg.sdk.uuid"];
    }
    return uuid;
}

+ (NSString *) newUUID
{
    CFUUIDRef uuid_ref = CFUUIDCreate(NULL);
    CFStringRef uuid_string_ref= CFUUIDCreateString(NULL, uuid_ref);
    CFRelease(uuid_ref);
    NSString *uuid = [NSString stringWithString:(__bridge NSString*)uuid_string_ref];
    CFRelease(uuid_string_ref);
    return uuid;
}

#pragma mark -- MD5 md5后小写 后台只识别小写的

+ (NSString *)md5:(NSString *)string
{
    const char *cStr = [string UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
    return [NSString
            stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3], result[4], result[5],
            result[6], result[7], result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]];
}

#pragma mark-- 密码账号

+ (BOOL) validateAccountWithAlert:(NSString *) account
{
    return [self validateAccount:account andErrorMsg:^(NSString *errorMsg) {
        [[[UIAlertView alloc] initWithTitle:nil message:errorMsg delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil, nil] show];
    }];
}

+ (BOOL) validatePasswordWithAlert:(NSString *) password
{
    return [self validatePassword:password andErrorMsg:^(NSString *errorMsg) {
        [[[UIAlertView alloc] initWithTitle:nil message:errorMsg delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil, nil] show];
    }];
}
//验证手机号
+(BOOL) validatePhoneNumber:(NSString *) phoneNumber andErrorMsg:(void (^)(NSString *errorMsg)) errorMsg
{
    NSString *msg = nil;
    if ([phoneNumber length] == 0) {
        msg = @"手机号不能为空";
    }else if ([phoneNumber length] != 11) {
        msg = @"手机号码格式不正确";
    }
    
    
//    else{
//
////        NSString *regex = @"^1(3[0-9]|4[57]|5[0-35-9]|8[0-9]|7[0135678])\\d{8}$";
//        NSString *regex = @"^1(3|4|5|7|8)[0-9]{1}\\d{8}$";
//        BOOL bMatch = [[NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex] evaluateWithObject:phoneNumber];
//        if (!bMatch) {
//            msg = @"请输入您的手机号码";
//        }
//    }
    if (errorMsg && msg) {
        errorMsg(msg);
    }
    return msg == nil;
}


//验证账号
+ (BOOL) validateAccount:(NSString *) account andErrorMsg:(void (^)(NSString *errorMsg)) errorMsg
{
    NSString *msg = nil;
    if ([account length] == 0) {
        msg = @"账号不能为空";
    }
//    else if ([account length] < 6 || [account length] > 20){
//        msg = @"账号长度错误，账号是6－20位数字或与字母组合";
//    }else{
//        
//        NSString *regex = @"^[0-9]*$";
//        BOOL bMatch = [[NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex] evaluateWithObject:account];
//        if (bMatch) {
//            msg = @"账号格式错误，账号不能是纯数字";
//        }else{
//            NSString *regex1 = @"^[A-Za-z]+${6,20}$";
//            NSString *regex2 = @"^(?![0-9]+$)(?![a-zA-Z]+$)[0-9A-Za-z]{6,20}$";
//            bMatch = [[NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex1] evaluateWithObject:account] || [[NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex2] evaluateWithObject:account];
//            if (!bMatch) {
//                msg = @"账号格式错误，账号是6－20位字母或与数字组合";
//            }
//        }
//    }
    if (errorMsg && msg) {
        errorMsg(msg);
    }
    return msg == nil;
}

+ (BOOL) validatePassword:(NSString *) password andErrorMsg:(void (^)(NSString *errorMsg)) errorMsg
{
    NSString *msg = nil;
    if ([password length] == 0) {
        msg = @"请输入密码";
    }else if ([password length] < 6 || [password length] > 20){
        msg = @"密码长度错误，密码是6-20位字母和数字的组合";
    }
    
    //   else{
    //        NSString *regex = @"^[_a-zA-Z0-9]{6,20}$";    // @"^(?![0-9]+$)(?![a-zA-Z]+$)[0-9A-Za-z]{6,18}$"; // @"^[A-Za-z0-9]{6,18}$";
    //        BOOL bMatch = [[NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex] evaluateWithObject:password];
    //        if (!bMatch) {
    //            msg = @"存在非法字符，请输入正确的密码";
    //        }
    //    }
    
    if (errorMsg &&  msg) {
        errorMsg(msg);
    }
    return msg == nil;
}

+ (BOOL)isChinese:(NSString *)name
{
    NSString *match = @"(^[\u4e00-\u9fa5]+$)";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF matches %@", match];
    return [predicate evaluateWithObject:name];
}

//验证姓名
+(BOOL)validateName:(NSString *)name andErrorMsg:(void (^)(NSString *errorMsg)) errorMsg
{
    NSString *msg = nil;
    if ([name length] == 0) {
        msg = @"真实姓名不能为空";
    }
//    else if(![self isChinese:name]){
//        msg = @"真实姓名不正确";
//    }else if(name.length > 10){
//       msg = @"真实姓名不能超过10个字";
//    }
    if (errorMsg && msg) {
        errorMsg(msg);
    }
    return msg == nil;
}






+ (BOOL)isTrueIdCard:(NSString *)IdCard {
    NSMutableArray *tempArray = [NSMutableArray array];
    for (int i = 0; i < IdCard.length; i++) {
        [tempArray addObject:[NSString stringWithFormat:@"%c",[IdCard characterAtIndex:i]]];
    }
    NSInteger x =
    ([tempArray[0] integerValue] + [tempArray[10] integerValue]) * 7 +
    ([tempArray[1] integerValue] + [tempArray[11] integerValue]) * 9 +
    ([tempArray[2] integerValue] + [tempArray[12] integerValue]) * 10 +
    ([tempArray[3] integerValue] + [tempArray[13] integerValue]) * 5 +
    ([tempArray[4] integerValue] + [tempArray[14] integerValue]) * 8 +
    ([tempArray[5] integerValue] + [tempArray[15] integerValue]) * 4 +
    ([tempArray[6] integerValue] + [tempArray[16] integerValue]) * 2 +
    [tempArray[7] integerValue]  * 1 + [tempArray[8] integerValue] * 6 +
    [tempArray[9] integerValue] * 3;
    
    NSString *checkIndex = [NSString stringWithFormat:@"%d",(int)x%11];
    NSString *checkCode = @"10X98765432";
    NSString *code = [checkCode substringWithRange:NSMakeRange([checkIndex integerValue], 1)];
    NSString *last = [IdCard substringWithRange:NSMakeRange(IdCard.length - 1, 1)];
    
    if ([code isEqualToString:last]) {
        return YES;
    }else{
        return false;
    }
    
}

//验证身份证号码
+(BOOL) validateIdCardNum:(NSString *) IdCardNum andErrorMsg:(void (^)(NSString *errorMsg)) errorMsg
{
    NSString *msg = nil;
    if ([IdCardNum length] == 0) {
        msg = @"身份证不合法";
    }else{
        
//        NSString *regex = @"(^[1-9]\\d{5}(18|19|([23]\\d))\\d{2}((0[1-9])|(10|11|12))(([0-2][1-9])|10|20|30|31)\\d{3}[0-9Xx]$)|(^[1-9]\\d{5}\\d{2}((0[1-9])|(10|11|12))(([0-2][1-9])|10|20|30|31)\\d{2}$)";
//        BOOL bMatch = [[NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex] evaluateWithObject:IdCardNum];
//        if (bMatch) {
//            if (![self isTrueIdCard:IdCardNum]) {
//               msg = @"身份证不合法";
//            }
//
//        }else{
//            msg = @"身份证不合法";
//        }
    }
    if (errorMsg && msg) {
        errorMsg(msg);
    }
    return msg == nil;
}




#pragma mark-- Tools

+ (void) setTextField:(UITextField *) tf  leftTitle:(NSString *) leftTitle leftWidth:(CGFloat) lWidth
{
    UILabel *lb = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, lWidth, tf.bounds.size.height)];
    [lb setBackgroundColor:[UIColor clearColor]];
    lb.text = leftTitle;
    lb.font =  I_PAD ? iPad_Font15 : iPhone_Font13; //  [UIFont systemFontOfSize:13];
    [tf setLeftView:lb];
    lb.textColor = [UIColor colorWithRed:103.0/255.0 green:105.0/255.0 blue:116.0/255.0 alpha:1.0];
    [tf setLeftViewMode:UITextFieldViewModeAlways];
}

+ (BOOL)validateNickname:(NSString*)str
{
    BOOL isAuth = YES;

    NSRegularExpression* regularexpression = [[NSRegularExpression alloc]
        initWithPattern:@"[\t\n\x0B\f\r]"
                options:NSRegularExpressionCaseInsensitive
                  error:nil];
    NSUInteger numberofMatch = [regularexpression numberOfMatchesInString:str
                                                                  options:NSMatchingReportProgress
                                                                    range:NSMakeRange(0, str.length)];

    if (numberofMatch > 0) {
        isAuth = NO;
    }
    return isAuth;
}

+ (UIInterfaceOrientation) defaultScreenOrientation
{
    return [MGManager defaultManager].mInterfaceOrientation;
}




+ (UIImage*)MGImageName:(NSString*)imageName
{
    static NSString *kMGPlatformBundle = @"AWSDKResources.bundle";
    NSString* bundlePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:kMGPlatformBundle];
    NSString* imagePath = [bundlePath stringByAppendingPathComponent:imageName];
    return [UIImage imageWithContentsOfFile:imagePath];
}


+ (UILabel *) naviTitle:(NSString *) title
{
    UILabel *label = [[UILabel alloc] init];
    [label setBackgroundColor:[UIColor clearColor]];
    label.font = [UIFont systemFontOfSize:17];
    label.text = title;
    label.textColor = [UIColor blackColor];
    [label sizeToFit];
    return label;
}

+ (NSString *) appName
{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
}

+ (UIButton *) newBackItemButtonIos6Target:(id)target action:(SEL) action;
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:[self MGImageName:@"MG_nav_back.png"] forState:UIControlStateNormal];
    btn.frame = CGRectMake(0, 0, 50, 44);
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    return btn;
}


+ (UIView *) newRoundCornerView:(CGRect) frame
{
    UIView *newView = [[UIView alloc] initWithFrame:frame];
    newView.layer.borderWidth = TT_IS_RETINA ? 0.6f : 1.0f;
    newView.layer.borderColor = TTHexColor(0xd5d5db).CGColor;
    newView.layer.cornerRadius = 6.0;
    newView.clipsToBounds = YES;
    [newView setBackgroundColor:[UIColor whiteColor]];
    return newView;
}


+ (UITextField *) newTextField_XLineWithFrame:(CGRect)frame leftTitle:(NSString *) ltitle andContent:(NSString *) content placeHoder:(NSString *) placeHoder
{
    return [self newTextField_XLineWithFrame:frame leftTitle:ltitle andContent:content placeHoder:placeHoder fontSize:13.0];
}

+ (UITextField *) newTextField_XLineWithFrame:(CGRect)frame leftTitle:(NSString *) ltitle andContent:(NSString *) content placeHoder:(NSString *) placeHoder fontSize:(CGFloat) fontSize
{
    UITextField *_tf  = [[MGUITextField_XLine alloc] initWithFrame:CGRectMake(10.0, frame.origin.y, frame.size.width - 20.0, frame.size.height)];
//    [self setTextField:_tf leftTitle:ltitle leftWidth:[ltitle sizeWithFont:[UIFont systemFontOfSize:fontSize]].width];
    [self setTextField:_tf leftTitle:ltitle leftWidth:[ltitle sizeWithAttributes:@{NSFontAttributeName :[UIFont systemFontOfSize:fontSize] }].width];
    _tf.text = content;
    _tf.placeholder = placeHoder;
    _tf.font = [UIFont systemFontOfSize:fontSize];
    _tf.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _tf.autocorrectionType = UITextAutocorrectionTypeNo;
    _tf.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _tf.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    return _tf;
}

+ (UITextField *) newTextFieldWithFrame:(CGRect)frame leftTitle:(NSString *) ltitle andContent:(NSString *) content placeHoder:(NSString *) placeHoder fontSize:(CGFloat) fontSize
{
    UITextField *_tf  = [[UITextField alloc] initWithFrame:CGRectMake(10.0, frame.origin.y, frame.size.width - 20.0, frame.size.height)];
//    [MGUtility setTextField:_tf leftTitle:ltitle leftWidth:[ltitle sizeWithFont:[UIFont systemFontOfSize:fontSize]].width];
    
    [MGUtility setTextField:_tf leftTitle:ltitle leftWidth:[ltitle sizeWithAttributes:@{NSFontAttributeName :[UIFont systemFontOfSize:fontSize]}].width];
    _tf.font = [UIFont systemFontOfSize:fontSize];
    _tf.text = content;
    _tf.placeholder = placeHoder;
    _tf.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _tf.autocorrectionType = UITextAutocorrectionTypeNo;
    _tf.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _tf.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    return _tf;
}

+ (UITextField *) newTextFieldWithFrame:(CGRect)frame leftTitle:(NSString *) ltitle andContent:(NSString *) content placeHoder:(NSString *) placeHoder
{
    return [self newTextFieldWithFrame:frame leftTitle:ltitle andContent:content placeHoder:placeHoder fontSize:13.0];
}

+ (UIButton *) newBlueButton:(CGRect) frame withTitle:(NSString *) title target:(id)target action:(SEL) action
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = frame;
    [btn setBackgroundImage:[[MGUtility MGImageName:@"MG_login_button_sel.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)] forState:UIControlStateNormal];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:15];
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    btn.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    return btn;
}

+ (UILabel *) newLabel:(CGRect) frame title:(NSString *) title font:(UIFont *) font textColor:(UIColor *) color
{
    UILabel *lb = [[UILabel alloc] initWithFrame:frame];
    [lb setBackgroundColor:[UIColor clearColor]];
    [lb setText:title];
    lb.font = font;
    lb.textColor = color;
    return lb;
}

+ (UIView *)newLineViewWithWidth:(CGFloat)width height:(CGFloat)height color:(UIColor *)color {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    view.backgroundColor = color;
    return view;
}

@end
