//
//  MGAlertView.m
//  MGPlatformTest
//
//  Created by caosq on 14-6-10.
//  Copyright (c) 2014年 Eason. All rights reserved.
//

#import "MGAlertView.h"

typedef void (^MGAlertViewCallBack)(int buttonIndex, NSString *buttonTitle);

@interface MGAlertView()<UIAlertViewDelegate>

@property (nonatomic, copy) MGAlertViewCallBack callback;

@end


@implementation MGAlertView

- (id) initWithTitle:(NSString *)title message:(NSString *)message  callback:(void (^)(int index, NSString *title))callback cancelButtonTitle:(NSString *)cancelButtonTitle  otherButtonTitles:(NSString *)otherButtonTitles, ...
{
    self = [super initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil, nil];
    if (self) {
        self.delegate = self;
        va_list args;
        va_start(args, otherButtonTitles);
        for (NSString *str = otherButtonTitles; str != nil; str = va_arg(args,NSString*)) {
            [self addButtonWithTitle:str];
        }
        va_end(args);
        self.callback = callback;
    }
    return self;
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (self.callback) {
        self.callback((int)buttonIndex, [alertView buttonTitleAtIndex:buttonIndex]);
    }
}

@end
