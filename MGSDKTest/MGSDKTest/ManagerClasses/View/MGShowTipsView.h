//
//  MGDialogAlertView.h
//  MGPlatformTest
//
//  Created by wangcl on 14-8-22.
//  Copyright (c) 2014年 qmqj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGKeyWindow.h"

#define kDialogFirstTextFieldTag                    20001
#define kDialogSecTextFieldTag                      20002

@class MGShowTipsView;
@class MGAlertViewRootVC;
@protocol MGDialogAlertViewDelegate <NSObject>

@optional

- (void)MGDialogAlertView:(MGShowTipsView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
- (void)MGDialogAlertviewEndTextFieldsEditing:(MGShowTipsView *)alertView;

@end

@interface MGShowTipsView : MGKeyWindow

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, getter = inputStrings) NSArray *textFieldsTexts;
@property (nonatomic, assign) BOOL shouldUpdateButtonsUIWhenLandscape;
@property (nonatomic, strong) MGAlertViewRootVC *rootVC;

@property (nonatomic, weak) id<MGDialogAlertViewDelegate> alertDelegate;

@property (copy) void(^onButtonTouchInside) (MGShowTipsView *alert, NSInteger index);

- (id)initWithCancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...;

- (void)show;
- (void)dismiss;
- (void)setOnButtonTouchInside:(void (^)(MGShowTipsView *dialogAlert, NSInteger buttonIndex))onButtonTouchInside;
+ (CGFloat)getMaxContainerViewWidth;

@end

@class MGAlertViewRootVC;

@interface MGDialogAlertContainerView : UIView



- (id)initWithWidth:(CGFloat)width title:(NSString *)title message:(NSString *)message;

- (void)setTitleColor:(UIColor *)color;
- (void)setMessageColor:(UIColor *)color;
- (void)setTitleAlignment:(NSTextAlignment)alignment;
- (void)setMessageAlignment:(NSTextAlignment)alignment;

- (UIView *)addRegiserView;

@property (nonatomic, weak) MGAlertViewRootVC *alertVC;

@end

@interface MGLowSafeAccountView : UIView

- (id)initWithWidth:(CGFloat)width title:(NSString *)title message:(NSString *)message;

- (void)setTitleColorRedAtrange:(NSRange)range;

@end
