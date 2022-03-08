//
//  MGAlertView.h
//  MGPlatformTest
//
//  Created by caosq on 14-7-12.
//  Copyright (c) 2014年 qmqj. All rights reserved.
//

#import <UIKit/UIKit.h>



typedef enum MGAlertType_ {
	MGAlertTypeNormal = 0,
	MGAlertTypeRedTitle,
} MGAlertType;


@interface MGAlertViewX : UIView

@property (nonatomic, assign, readonly) NSInteger cancelButtonIndex;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) MGAlertType alertType;

- (instancetype) initWithTitle:(NSString *)title message:(NSString *)message  callback:(void (^)(int index, NSString *title))callback cancelButtonTitle:(NSString *)cancelButtonTitle  otherButtonTitles:(NSString *)otherButtonTitles, ...;

- (void) show;

@end
