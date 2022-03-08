//
//  MGLoginFooterView.h
//  MGPlatformTest
//
//  Created by wangcl on 14-8-18.
//  Copyright (c) 2014年 qmqj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MGLoginFooterView : UIView


@property (nonatomic, strong) UIButton *buttonVisitor;



- (void)resizeForLandscape;
- (void)resizeForPortrait;
- (void)resizeForiPad;

@end
