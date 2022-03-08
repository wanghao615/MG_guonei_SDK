//
//  MGAlertView.h
//  MGPlatformTest
//
//  Created by caosq on 14-6-10.
//  Copyright (c) 2014年 Eason. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MGAlertView : UIAlertView

- (id) initWithTitle:(NSString *)title message:(NSString *)message  callback:(void (^)(int index, NSString *title))callback cancelButtonTitle:(NSString *)cancelButtonTitle  otherButtonTitles:(NSString *)otherButtonTitles, ...;

@end
