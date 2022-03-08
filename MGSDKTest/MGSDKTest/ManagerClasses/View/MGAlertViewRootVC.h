//
//  MGAlertViewRootVC.h
//  MGPlatformTest
//
//  Created by wangcl on 14-8-22.
//  Copyright (c) 2014年 qmqj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGShowTipsView.h"
#import "MGBaseViewController.h"

#define kDialogViewWidthPhone                       290.0f
#define kDialogViewWidthPad                         420.0f

@interface MGAlertViewRootVC : MGBaseViewController

@property (nonatomic, weak) MGShowTipsView *dialogAlert;

@property (nonatomic, strong) NSMutableArray *buttonTitles;

@property (nonatomic, strong) UIView *containerView;
/**
 *  是否应该更新button排列成一行当横屏时，默认为NO
 */
@property (nonatomic, assign) BOOL shouldUpdateButtonsUIWhenLandscape;

- (void)startShow;
- (void)dismissView;
- (void)containerViewEndEditing;

@end
