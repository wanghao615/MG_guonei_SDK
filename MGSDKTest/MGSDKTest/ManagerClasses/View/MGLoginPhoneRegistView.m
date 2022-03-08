//
//  MGLoginPhoneRegistView.m
//  MGPlatformTest
//
//  Created by ZYZ on 17/1/19.
//  Copyright © 2017年 MGzs. All rights reserved.
//

#import "MGLoginPhoneRegistView.h"
#import "MGUtility.h"

@implementation MGLoginPhoneRegistView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self addSubview:self.buttonPhoneRegist];
        
    }
    return self;
}


- (UIButton *)buttonPhoneRegist {
    if (_buttonPhoneRegist == nil) {
        
        _buttonPhoneRegist = [UIButton buttonWithType:UIButtonTypeCustom];
        [_buttonPhoneRegist setImage:[MGUtility MGImageName:@"MG_icon_visit_login@2x.png"] forState:UIControlStateNormal];
        [_buttonPhoneRegist setImageEdgeInsets:UIEdgeInsetsMake(-1, -7, 0, 0)];
        [_buttonPhoneRegist setTitle:@"一秒注册" forState:UIControlStateNormal];
        [_buttonPhoneRegist setTitleColor:TTHexColor(0x676974) forState:UIControlStateNormal];
        [_buttonPhoneRegist setBackgroundColor:TTHexColor(0xf7f7f9)];
        [_buttonPhoneRegist.titleLabel setFont:TTSystemFont(15)];
        _buttonPhoneRegist.frame = CGRectMake(15, 0, self.bounds.size.width, self.bounds.size.height);
        
        [_buttonPhoneRegist.layer setCornerRadius:3.0f];
        [_buttonPhoneRegist.layer setMasksToBounds:YES];
        [_buttonPhoneRegist.layer setBorderWidth:.7f];
        
        _buttonPhoneRegist.titleLabel.font = TTSystemFont(16);
        [_buttonPhoneRegist.layer setBorderColor:TTHexColor(0xd5d5db).CGColor];
    }
    
    return _buttonPhoneRegist;
}


- (void)resizeForLandscape {
    self.buttonPhoneRegist.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    
}

- (void)resizeForPortrait {
    self.buttonPhoneRegist.frame = CGRectMake(15, 0, self.bounds.size.width - 30, self.bounds.size.height);
    
    
}

- (void)resizeForiPad {
    self.buttonPhoneRegist.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
   
}

@end
