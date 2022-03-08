//
//  MGCheckBox.m
//  MGPlatformTest
//
//  Created by Eason on 21/05/2014.
//  Copyright (c) 2014 Eason. All rights reserved.
//

#import "MGCheckBox.h"

#define MGCHECKICONWIDTH (15.0)
#define MGCHECKICONTITLEMARGIN (5.0)

@implementation MGCheckBox
@synthesize delegate = _delegate;
@synthesize userInfo = _userInfo;
@synthesize checked = _checked;

- (id)initWithDelegate:(id)delegate fromCon:(fromControllerType)conType
{
    self = [super init];
    if (self) {
        _delegate = delegate;
        _fromConType = conType;
        
        self.exclusiveTouch = YES;
        [self setImage:[MGUtility MGImageName:@"MG_checkbox_uncheck.png"]
              forState:UIControlStateNormal];

        [self setImage:[MGUtility MGImageName:@"MG_checkbox_checked.png"]
              forState:UIControlStateSelected];
        
        if (self.fromConType == fromControllerLogin) {
            [self setImage:[MGUtility MGImageName:@""]
                  forState:UIControlStateNormal];

            [self setImage:[MGUtility MGImageName:@""]
                  forState:UIControlStateSelected];
        }else{
            [self addTarget:self
                          action:@selector(checkboxButtnChecked)
                forControlEvents:UIControlEventTouchUpInside];
        }

        [self setTitleColor:TTRGBColor(59, 110, 255)
                   forState:UIControlStateSelected];

        [self setTitleColor:[UIColor grayColor]
                   forState:UIControlStateNormal];

        [self.titleLabel setFont:[UIFont boldSystemFontOfSize:13.0f]];
    }
    return self;
}

- (void)setChecked:(BOOL)checked
{
    if (_checked == checked) {
        return;
    }

    _checked = checked;
    self.selected = checked;

    if (_delegate && [_delegate respondsToSelector:@selector(didSelectedCheckBox:
                                                                         checked:)]) {
        [_delegate didSelectedCheckBox:self
                               checked:self.selected];
    }
}

- (void)checkboxButtnChecked
{
    self.selected = !self.selected;
    _checked = self.selected;

    if (_delegate && [_delegate respondsToSelector:@selector(didSelectedCheckBox:
                                                                         checked:)]) {
        [_delegate didSelectedCheckBox:self
                               checked:self.selected];
    }
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect
{
    return CGRectMake(0, (CGRectGetHeight(contentRect) - MGCHECKICONWIDTH) / 2.0, MGCHECKICONWIDTH, MGCHECKICONWIDTH);
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect
{
    return CGRectMake(MGCHECKICONWIDTH + MGCHECKICONTITLEMARGIN, 0,
                      CGRectGetWidth(contentRect) - MGCHECKICONWIDTH - MGCHECKICONTITLEMARGIN,
                      CGRectGetHeight(contentRect));
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
