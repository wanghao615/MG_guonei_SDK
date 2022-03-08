//
//  MGUtility.h
//  MGPlatformDemo
//
//  Created by SunYuan on 14-4-25.
//  Copyright (c) 2014年 Eason. All rights reserved.
//

#import <Foundation/Foundation.h>


extern BOOL MG_DEBUG_LOG;


#define MG_LOG(fmt, ...) (MG_DEBUG_LOG ? NSLog((@"\n" fmt), ##__VA_ARGS__) : nil)


#define I_PAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define I_PHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define I_PHONE_X ([[[UIDevice currentDevice] hardwareSimpleDescription]isEqualToString:@"iPhone X"])

#define I_FONT_14_19  (I_PAD ? [UIFont systemFontOfSize:19.0] : [UIFont systemFontOfSize:14.0])
#define I_FONT_14_17  (I_PAD ? [UIFont systemFontOfSize:17.0] : [UIFont systemFontOfSize:14.0])
#define I_FONT_13_14  (I_PAD ? [UIFont systemFontOfSize:14.0] : [UIFont systemFontOfSize:13.0])
#define I_FONT_13_16  (I_PAD ? iPad_Font16 : iPhone_Font13)
#define I_FONT_13_17  (I_PAD ? [UIFont systemFontOfSize:17.0] : [UIFont systemFontOfSize:13.0])
#define I_FONT_12_14  (I_PAD ? iPhone_Font20 : iPhone_Font12)



// 常用iPhone字体
#define iPhone_Font12  [UIFont systemFontOfSize:12.0]
#define iPhone_Font13  [UIFont systemFontOfSize:13.0]
#define iPhone_Font14  [UIFont systemFontOfSize:14.0]
#define iPhone_Font20  [UIFont systemFontOfSize:20.0]

// 常用iPad字体
#define iPad_Font16    [UIFont systemFontOfSize:16.0]
#define iPad_Font15    [UIFont systemFontOfSize:15.0]



#define iPhone_L UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])

#define iPhone_P UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])

#define iPad_L UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])

#define iPad_P UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])

static NSString *const kMGPlatformReloadUserInfoNitifaication = @"kMGPlatformReloadUserInfoNitifaication";
static NSString *const kMGPlatform_Dismiss_Noti = @"kMGPlatform_Dismiss_Noti";
static NSString *const GDListenForAttributeDidChanges = @"GDListenForAttributeDidChanges";
static NSString *const GDSaveDidPrivacyVersion = @"GDSaveDidPrivacyVersion";

#define DEBUG_ERROR @"错误(DEBUG)"


typedef enum MGAction_{
    MGActionLogin       = 1,
    MGActionRegister    = 2,
    MGActioncoshow         = 3,
    MGActionSNSCenter   = 4,
    MGActionInitPlatform= 5,
    MGActionNoAction    = 90,
    MGActionNothing     = 99,
} MGAction;





@interface MGUtility : NSObject

+ (NSString *) generateDeviceId;

/// **** md5
+ (NSString *)md5:(NSString *)string;


/// **** 密码账号
+ (BOOL) validateAccountWithAlert:(NSString *) account;
+ (BOOL) validatePasswordWithAlert:(NSString *) password;
//验证手机号
+(BOOL) validatePhoneNumber:(NSString *) phoneNumber andErrorMsg:(void (^)(NSString *errorMsg)) errorMsg;
+ (BOOL) validateAccount:(NSString *) account andErrorMsg:(void (^)(NSString *errorMsg)) errorMsg;
+ (BOOL) validatePassword:(NSString *) password andErrorMsg:(void (^)(NSString *errorMsg)) errorMsg;

//验证身份证号码
+(BOOL) validateIdCardNum:(NSString *) IdCardNum andErrorMsg:(void (^)(NSString *errorMsg)) errorMsg;
//验证姓名
+(BOOL)validateName:(NSString *)name andErrorMsg:(void (^)(NSString *errorMsg)) errorMsg;


/// **** 一些简便方法
+ (void) setTextField:(UITextField *) tf  leftTitle:(NSString *) leftTitle leftWidth:(CGFloat) lWidth;

+ (BOOL)validateNickname:(NSString *)str;

/// *** screntoration
+ (UIInterfaceOrientation) defaultScreenOrientation;

+ (UIImage*)MGImageName:(NSString*)imageName;

+ (UILabel *) naviTitle:(NSString *) title;

+ (NSString *) appName;

+ (UIButton *) newBackItemButtonIos6Target:(id)target action:(SEL) action;

+ (UIView *) newRoundCornerView:(CGRect) frame;

+ (UITextField *) newTextField_XLineWithFrame:(CGRect)frame leftTitle:(NSString *) ltitle andContent:(NSString *) content placeHoder:(NSString *) placeHoder;
+ (UITextField *) newTextField_XLineWithFrame:(CGRect)frame leftTitle:(NSString *) ltitle andContent:(NSString *) content placeHoder:(NSString *) placeHoder fontSize:(CGFloat) fontSize;
+ (UITextField *) newTextFieldWithFrame:(CGRect)frame leftTitle:(NSString *) ltitle andContent:(NSString *) content placeHoder:(NSString *) placeHoder;
+ (UITextField *) newTextFieldWithFrame:(CGRect)frame leftTitle:(NSString *) ltitle andContent:(NSString *) content placeHoder:(NSString *) placeHoder fontSize:(CGFloat) fontSize;

+ (UIButton *) newBlueButton:(CGRect) frame withTitle:(NSString *) title target:(id)target action:(SEL) action;

+ (UILabel *) newLabel:(CGRect) frame title:(NSString *) title font:(UIFont *) font textColor:(UIColor *) color;

/**
 *  创建一条线
 *
 *  @param width  线的宽度
 *  @param height 线的高度
 *  @param color  线的颜色
 *
 *  @return 竖线view
 */
+ (UIView *)newLineViewWithWidth:(CGFloat)width height:(CGFloat)height color:(UIColor *)color;





@end
