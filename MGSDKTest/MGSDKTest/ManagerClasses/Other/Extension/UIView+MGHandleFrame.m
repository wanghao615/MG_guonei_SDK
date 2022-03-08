//
//  UIView+MGHandleFrame.m
//  MGPlatformTest
//
//  Created by wangcl on 14-8-19.
//  Copyright (c) 2014年 qmqj. All rights reserved.
//

#import "UIView+MGHandleFrame.h"

@implementation UIView (MGHandleFrame)

- (void)setwidth:(CGFloat)width {
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (void)setHeight:(CGFloat)height {
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}


- (void)setOriginX:(CGFloat)originX {
    CGRect frame = self.frame;
    frame.origin.x = originX;
    self.frame = frame;
}

- (void)setOriginY:(CGFloat)originY {
    CGRect frame = self.frame;
    frame.origin.y = originY;
    self.frame = frame;
}

@end
