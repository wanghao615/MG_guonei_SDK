//
//  MGLoginFooterView.m
//  MGPlatformTest
//
//  Created by wangcl on 14-8-18.
//  Copyright (c) 2014年 qmqj. All rights reserved.
//

#import "MGLoginFooterView.h"

#import "MGUtility.h"

@interface MGLoginFooterView ()

@property (nonatomic, strong) UIView *verticalLine1;
@property (nonatomic, strong) UIView *verticalLine2;

@end

@implementation MGLoginFooterView



- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self addSubview:self.buttonVisitor];
        
        
        
    }
    return self;
}


- (UIButton *)buttonVisitor {
    if (_buttonVisitor == nil) {
        
        _buttonVisitor = [UIButton buttonWithType:UIButtonTypeCustom];
        [_buttonVisitor setImage:[MGUtility MGImageName:@"MG_icon_visit_login@2x.png"] forState:UIControlStateNormal];
        [_buttonVisitor setImageEdgeInsets:UIEdgeInsetsMake(-1, -7, 0, 0)];
        [_buttonVisitor setTitle:@"游客登录" forState:UIControlStateNormal];
        [_buttonVisitor setTitleColor:TTHexColor(0x676974) forState:UIControlStateNormal];
        [_buttonVisitor setBackgroundColor:TTHexColor(0xf7f7f9)];
        [_buttonVisitor.titleLabel setFont:TTSystemFont(15)];
        _buttonVisitor.frame = CGRectMake(15, 0, self.bounds.size.width, self.bounds.size.height);
        
        [_buttonVisitor.layer setCornerRadius:3.0f];
        [_buttonVisitor.layer setMasksToBounds:YES];
        [_buttonVisitor.layer setBorderWidth:.7f];
        
        _buttonVisitor.titleLabel.font = TTSystemFont(16);
        [_buttonVisitor.layer setBorderColor:TTHexColor(0xd5d5db).CGColor];
    }
    
    return _buttonVisitor;
}


- (UIView *)verticalLine1 {
    if (_verticalLine1 == nil) {
        _verticalLine1 = [MGUtility newLineViewWithWidth:0.5f height:16 color:TTHexColor(0xd4d4d4)];
        _verticalLine1.frame = CGRectMake(self.buttonVisitor.frame.origin.x + self.buttonVisitor.frame.size.width + 13, (self.frame.size.height - 16) / 2, 0.5f, 16.0f);
    }
    return _verticalLine1;
}

- (UIView *)verticalLine2 {
    if (_verticalLine2 == nil) {
        _verticalLine2 = [MGUtility newLineViewWithWidth:0.5f height:16 color:TTHexColor(0xd4d4d4)];
       
    }
    return _verticalLine2;
}

- (void)resizeForLandscape {
    self.buttonVisitor.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    
}

- (void)resizeForPortrait {
    self.buttonVisitor.frame = CGRectMake(15, 0, self.bounds.size.width - 30, self.bounds.size.height);
    
    
}

- (void)resizeForiPad {
    self.buttonVisitor.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    
}

@end
