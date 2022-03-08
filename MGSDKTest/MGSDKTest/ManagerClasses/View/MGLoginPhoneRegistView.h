//
//  MGLoginPhoneRegistView.h
//  MGPlatformTest
//
//  Created by ZYZ on 17/1/19.
//  Copyright © 2017年 MGzs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MGLoginPhoneRegistView : UIView


@property (nonatomic, strong) UIButton *buttonPhoneRegist;



- (void)resizeForLandscape;
- (void)resizeForPortrait;
- (void)resizeForiPad;


@end
