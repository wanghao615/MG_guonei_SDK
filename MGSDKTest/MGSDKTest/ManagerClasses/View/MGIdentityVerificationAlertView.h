//
//  MGIdentityVerificationAlertView.h
//  MGPlatformTest
//
//  Created by ZYZ on 17/3/22.
//  Copyright © 2017年 MGzs. All rights reserved.
//

#import "MGKeyWindow.h"


#define kDialogFirstTextFieldTag                    20001
#define kDialogSecTextFieldTag                      20002

@class MGIdentityVerificationAlertView;
@class MGAlertViewRootVC;

@protocol MGIdentityVerificationAlertViewDelegate <NSObject>

@optional

- (void)MGIdentityVerificationAlertView:(MGIdentityVerificationAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
- (void)MGIdentityVerificationAlertViewEndTextFieldsEditing:(MGIdentityVerificationAlertView *)alertView;

@end

@interface MGIdentityVerificationAlertView : MGKeyWindow

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, getter = inputStrings) NSArray *textFieldsTexts;
@property (nonatomic, assign) BOOL shouldUpdateButtonsUIWhenLandscape;
@property (nonatomic, strong) MGAlertViewRootVC *rootVC;

@property (nonatomic, weak) id<MGIdentityVerificationAlertViewDelegate> alertDelegate;

@property (copy) void(^onButtonTouchInside) (MGIdentityVerificationAlertView *alert, NSInteger index);

- (id)initWithCancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...;

- (void)show;
- (void)dismiss;
- (void)setOnButtonTouchInside:(void (^)(MGIdentityVerificationAlertView *dialogAlert, NSInteger buttonIndex))onButtonTouchInside;
+ (CGFloat)getMaxContainerViewWidth;


@end

@class MGAlertViewRootVC;

@interface MGIdentityVerificationContainerView : UIView



- (id)initWithWidth:(CGFloat)width title:(NSString *)title message:(NSString *)message;

- (void)setTitleColor:(UIColor *)color;
- (void)setMessageColor:(UIColor *)color;
- (void)setTitleAlignment:(NSTextAlignment)alignment;
- (void)setMessageAlignment:(NSTextAlignment)alignment;

- (UIView *)addVerifyIdentidyView;

@property (nonatomic, weak) MGAlertViewRootVC *alertVC;

@end


