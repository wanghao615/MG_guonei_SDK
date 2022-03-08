//
//  MGSelectButtonBox.m
//  MGPlatformDemo
//
//  Created by SunYuan on 14-4-23.
//  Copyright (c) 2014年 Eason. All rights reserved.
//

#import "MGChooseView.h"

@implementation MGChooseView
@synthesize MGChooseButton = _MGChooseButton;
@synthesize MGChooseLabel = _MGChooseLabel;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self addSubview:[self MGChooseButton]];
        [self addSubview:[self MGChooseLabel]];
    }
    return self;
}

- (UIButton*)MGChooseButton
{
    if (!_MGChooseButton) {
        _MGChooseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_MGChooseButton setImage:[MGUtility MGImageName:@"MG_checkbox_sel.png"]
                         forState:UIControlStateNormal];
        _MGChooseButton.frame = CGRectMake(0.f, 0, 17, 17.f);
    }
    return _MGChooseButton;
}

- (UILabel*)MGChooseLabel
{
    if (!_MGChooseLabel) {
        _MGChooseLabel = [[UILabel alloc] initWithFrame:CGRectMake(25.f, 0, 60, 15)];
        [_MGChooseLabel setBackgroundColor:[UIColor clearColor]];
        _MGChooseLabel.textColor = TTBlackColor;
        _MGChooseLabel.backgroundColor = TTClearColor;
        _MGChooseLabel.font = TTSystemFont(13);
    }
    return _MGChooseLabel;
}

- (void)setMGChooseButton:(BOOL)ChooseButtonType
{
    if (ChooseButtonType) {
        [_MGChooseButton setImage:[MGUtility MGImageName:@"MG_checkbox_sel.png"]
                         forState:UIControlStateNormal];
    } else {
        [_MGChooseButton setImage:[MGUtility MGImageName:@"MG_checkbox_nor.png"]
                         forState:UIControlStateNormal];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
