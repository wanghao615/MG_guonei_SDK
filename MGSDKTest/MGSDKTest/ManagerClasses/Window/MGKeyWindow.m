//
//  MGKeyWindow.m
//  MGPlatformTest
//
//  Created by caosq on 14-7-14.
//  Copyright (c) 2014年 qmqj. All rights reserved.
//

#import "MGKeyWindow.h"
#import "MGUpdateAlertView.h"

@implementation MGKeyWindow

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        if (IPHONE_8_UP) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recieveStatusBarOriNoti:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
        }
    }
    return self;
}

- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    UIView* __tmpView = [super hitTest:point withEvent:event];
    if (__tmpView == self) {
        return nil;
    }
    return __tmpView;
}

- (void) recieveStatusBarOriNoti:(id)sender
{
    self.frame = [[UIScreen mainScreen] bounds];
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) setFrame:(CGRect)frame
{
    if (IPHONE_8_UP) {
        frame = [[UIScreen mainScreen] bounds];
    }
    [super setFrame:frame];
}


- (void) setRootViewController:(UIViewController *)rootViewController
{
    __block BOOL bAlerting = NO;
    NSArray *subViews = self.subviews;
    [subViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[MGUpdateAlertView class]]) {
            bAlerting = YES;
            *stop = YES;
        }
    }];
    
    if (!bAlerting) {
        [super setRootViewController:rootViewController];
    }
}

- (void) addSubview:(UIView *)view
{
    __block BOOL bAlerting = NO;
    NSArray *subViews = self.subviews;
    [subViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[MGUpdateAlertView class]]) {
            bAlerting = YES;
            *stop = YES;
        }
    }];
    
    if (!bAlerting) {
        [super addSubview:view];
    }
}


@end
