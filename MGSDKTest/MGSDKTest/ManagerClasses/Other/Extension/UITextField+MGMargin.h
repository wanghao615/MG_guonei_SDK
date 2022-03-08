//
//  UITextField+Margin.h
//
//
//  Created by 曹 胜全 on 5/24/14.
//  Copyright (c) 2014 . All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITextField (MGMargin)

@property (nonatomic, assign) CGFloat leftMargin;
@property (nonatomic, assign) CGFloat rightMargin;

@property (nonatomic, assign) UIEdgeInsets bgImageEdgeInsets;

- (void) setBackgroundNormalStateImageName:(NSString *) nImageName andSelectedStateImageName:(NSString *) sImageName;


@end
