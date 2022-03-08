//
//  MGSelectButtonBox.h
//  MGPlatformDemo
//
//  Created by SunYuan on 14-4-23.
//  Copyright (c) 2014年 Eason. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MGChooseView : UIView
@property (nonatomic, strong) UIButton* MGChooseButton;
@property (nonatomic, strong) UILabel * MGChooseLabel;
-(void)setMGChooseButton:(BOOL)ChooseButtonType;

@end
