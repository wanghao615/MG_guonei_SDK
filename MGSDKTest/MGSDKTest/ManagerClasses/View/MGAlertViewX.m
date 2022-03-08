//
//  MGAlertView.m
//  MGPlatformTest
//
//  Created by caosq on 14-7-12.
//  Copyright (c) 2014年 qmqj. All rights reserved.
//

#import "MGAlertViewX.h"


typedef void (^MGAlertViewCallBackX)(int buttonIndex, NSString *buttonTitle);


@interface MGAlertViewX()
{
    UIView *middleIv;
    UILabel *lbTitle;
    UILabel *lbMsg;
    
    NSString *title;
    NSString *msg;
    NSString *cancelButtonTitle;
    
    CALayer *maskLayer;
}

@property (nonatomic, copy) MGAlertViewCallBackX callback;

@property (nonatomic, strong) NSMutableArray *buttonTitles;

@property (nonatomic, strong) NSMutableArray *buttons;

@property (nonatomic, assign, readwrite) NSInteger cancelButtonIndex;

@end


@implementation MGAlertViewX


- (void) setFrame:(CGRect)frame
{
    frame = [[UIScreen mainScreen] bounds];
    [super setFrame:frame];
}

- (id) initWithTitle:(NSString *)atitle message:(NSString *)message  callback:(void (^)(int index, NSString *title))callback cancelButtonTitle:(NSString *)acancelButtonTitle  otherButtonTitles:(NSString *)otherButtonTitles, ...
{
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        
        va_list args;
        va_start(args, otherButtonTitles);
        for (NSString *str = otherButtonTitles; str != nil; str = va_arg(args,NSString*)) {
            [self.buttonTitles addObject:str];
        }
        va_end(args);

        cancelButtonTitle = acancelButtonTitle;
        title = atitle;
        msg = message;
        self.callback = callback;
        
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        
        [self initContent];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recieveStatusBarOriNoti:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
        
    }
    return self;
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSMutableArray *) buttons
{
    if (!_buttons) {
        _buttons = [NSMutableArray new];
    }
    return _buttons;
}

- (NSMutableArray *) buttonTitles
{
    if (!_buttonTitles) {
        _buttonTitles = [NSMutableArray new];
    }
    return _buttonTitles;
}


- (void) initContent
{
    maskLayer = [[CALayer alloc] init];
    maskLayer.frame = self.bounds;
    [maskLayer setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.7].CGColor];
    [self.layer addSublayer:maskLayer];

    UIFont *font1 =  I_PAD ? [UIFont systemFontOfSize:18] : [UIFont systemFontOfSize:16];
    UIFont *font =  I_PAD ? [UIFont systemFontOfSize:17] : [UIFont systemFontOfSize:15];
    
    CGFloat w = 580.0/2, h = 250.0;
    CGFloat x = ([UIScreen mainScreen].bounds.size.width - w)/2, y = ([[UIScreen mainScreen] bounds].size.height - h)/2;
    middleIv = [[UIView alloc] initWithFrame:CGRectMake(x, y, w, h)];
    [middleIv setBackgroundColor:[UIColor clearColor]];
    
    CGFloat x1 = 20.0, y1 = 20.0;
    
    UIColor *color = TTHexColor(0x000000);
    if (self.alertType == MGAlertTypeRedTitle) {
        color = TTHexColor(0xff0000);
    }
    lbTitle = [MGUtility newLabel:CGRectMake(x1, y1, w-2*x1, 20.0) title:title font:font1 textColor:color];
    [middleIv addSubview:lbTitle];
    lbTitle.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    lbTitle.numberOfLines = 0;
//    [lbTitle sizeToFit];
    lbTitle.lineBreakMode = NSLineBreakByCharWrapping;
    lbTitle.textAlignment = NSTextAlignmentCenter;
    
    
    y1 += lbTitle.bounds.size.height + 14.0;
    lbMsg = [MGUtility newLabel:CGRectMake(x1, y1, w-2*x1, MAX_TRAILER_SIZE) title:msg font:font textColor:TTHexColor(0x868891)];
    [middleIv addSubview:lbMsg];
    lbMsg.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    lbMsg.lineBreakMode = NSLineBreakByCharWrapping;
    lbMsg.textAlignment = NSTextAlignmentLeft;
    lbMsg.numberOfLines  = 0;
    [lbMsg sizeToFit];
    
    
//    if ([msg sizeWithFont:font].height == lbMsg.bounds.size.height) {
//        y1 += lbMsg.bounds.size.height + 35.0;
    if ([msg sizeWithAttributes:@{NSFontAttributeName : font}].height == lbMsg.bounds.size.height) {
        y1 += lbMsg.bounds.size.height + 35.0;
    }else
        y1 += lbMsg.bounds.size.height + 20.0;
    
    CGFloat b_h = I_PAD ? 50.0 : 42.0;
    for (NSString *btnTitle in self.buttonTitles) {
        UIButton *btn = [MGUtility newBlueButton:CGRectMake(x1, y1, 250.0, b_h) withTitle:btnTitle target:self action:@selector(buttonClick:)];
        btn.titleLabel.font = font;
        [middleIv addSubview:btn];
        [self.buttons addObject:btn];
        y1 += b_h + 10.0;
    }
    
    if (cancelButtonTitle != nil) {
        UIButton *btn = [MGUtility newBlueButton:CGRectMake(x1, y1, 250.0, b_h) withTitle:cancelButtonTitle target:self action:@selector(cancelButtonClick:)];
        btn.titleLabel.font = font;
        [btn setBackgroundImage:[[MGUtility MGImageName:@"MG_btn_gray.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(8, 8, 8, 8) ] forState:UIControlStateNormal];
        [middleIv addSubview:btn];
        
        [self.buttons addObject:btn];
        
        self.cancelButtonIndex = [self.buttons count] - 1;
        
        y1 += b_h;
    }
    
    h = y1 + 20.0;
    
    middleIv.frame = CGRectMake(x,  ceilf(([UIScreen mainScreen].bounds.size.height - h) /2) , w, h);
    
    UIImageView *iv = [[UIImageView alloc] initWithImage:[[MGUtility MGImageName:@"MG_alertview_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)]];
    iv.frame = middleIv.bounds;
    iv.tag = 99;
    iv.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [middleIv insertSubview:iv atIndex:0];
    [self addSubview:middleIv];
    
}

- (void) setAlertType:(MGAlertType)alertType
{
    if (_alertType != alertType) {
        _alertType = alertType;
        
        UIColor *color = TTHexColor(0x000000);
        if (_alertType == MGAlertTypeRedTitle) {
            color = TTHexColor(0xff0000);
            lbMsg.textAlignment = NSTextAlignmentCenter;
        }else
            lbMsg.textAlignment = NSTextAlignmentLeft;
        lbTitle.textColor = color;
    }
}

- (void) setWidth:(CGFloat)width
{
    if (_width != width) {
        _width = width;
        
        CGRect frame = middleIv.frame;
        frame.size.width = _width;
        middleIv.frame = frame;
        middleIv.center = self.center;
        
        frame = lbMsg.frame;
        frame.size.width = width - 20*2;
        lbMsg.frame = frame;
    }
}

-(void) buttonClick:(UIButton *) btn
{
    NSInteger index = [self.buttons indexOfObject:btn];
    if (self.callback) {
        self.callback((int)index, [btn titleForState:UIControlStateNormal]);
    }
    [self dismiss];
}

- (void)cancelButtonClick:(UIButton *) btn
{
    NSInteger index = [self.buttons indexOfObject:btn];
    if (self.callback) {
        self.callback((int)index, [btn titleForState:UIControlStateNormal]);
    }
    [self dismiss];
}

- (void) dismiss
{
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        [maskLayer setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.0].CGColor];
        middleIv.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}


- (void) show
{
    UIView *superView = [[UIApplication sharedApplication] keyWindow];

    [self fitTransform];
    [superView addSubview:self];
    [maskLayer setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.0].CGColor];
//    CGRect frame = middleIv.frame;
//    frame = CGRectInset(frame, 0.4, 0.4);
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
       
        [maskLayer setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.7].CGColor];
//        middleIv.frame = frame;
        
    } completion:^(BOOL finished) {
        
    }];
}


- (void) fitTransform
{
    if ((IPHONE_8_UP) && (__IPHONE_OS_8_0)) {
        
        self.frame = [[UIScreen mainScreen] bounds];
        maskLayer.frame = self.bounds;
        middleIv.center = self.center;

    }else{
    
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    CGSize size = [[UIScreen mainScreen] bounds].size;
    
    if (UIInterfaceOrientationIsLandscape(orientation)) {
            CGFloat w = size.width;
            size.width = size.height;
            size.height = w;
    }
    if (orientation == UIInterfaceOrientationLandscapeLeft) {
        [middleIv setTransform:CGAffineTransformMake(0, -1, 1, 0, 0, 0)];
    }else if (orientation == UIInterfaceOrientationLandscapeRight){
        [middleIv setTransform:CGAffineTransformMake(0, 1, -1, 0, 0, 0)];
    }else if (orientation == UIInterfaceOrientationPortrait){
        middleIv.transform = CGAffineTransformIdentity;
    }else if (orientation == UIInterfaceOrientationPortraitUpsideDown){
        middleIv.transform = CGAffineTransformMake(-1, 0, -0, -1, 0, 0);
    }
    
    }
}

- (void) recieveStatusBarOriNoti:(NSNotification *) noti
{
    [self fitTransform];
}


@end
