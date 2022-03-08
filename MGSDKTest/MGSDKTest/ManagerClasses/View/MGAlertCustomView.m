//
//  MGAlertCustomView.m
//  MGSDKTest
//
//  Created by ZYZ on 2017/12/22.
//  Copyright © 2017年 MG. All rights reserved.
//

#import "MGAlertCustomView.h"
#import "UIView+MGHandleFrame.h"
@interface MGAlertCustomView()

@property(nonatomic,strong)UIView *clearbgView;

@property(nonatomic,strong)NSString *message;

@property(nonatomic,strong)UIView *alertView;

@property(nonatomic,strong)UILabel *messageLabel;

@property(nonatomic,strong)UIButton *sureBtn;

@property(nonatomic,strong)UIButton *cancelBtn;

@property(nonatomic,assign)AlertType type;

@end


@implementation MGAlertCustomView
- (UIButton *)sureBtn {
    if (_sureBtn == nil) {
        _sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        _sureBtn.backgroundColor = TTRGBColor(0, 110, 250);
        UIImage* strechedImage = [[MGUtility MGImageName:@"MG_login_button_sel.png"] stretchableImageWithLeftCapWidth:5
                                                                                                         topCapHeight:5];
        [_sureBtn setBackgroundImage:strechedImage
                                   forState:UIControlStateNormal];
        [_sureBtn setTitle:@"确定" forState:UIControlStateNormal];
        [_sureBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _sureBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        _sureBtn.frame = CGRectMake(0, 0, 85, 28);
        _sureBtn.layer.cornerRadius = CGRectGetHeight(_sureBtn.frame)*0.5;
        _sureBtn.clipsToBounds = YES;
        [_sureBtn addTarget:self action:@selector(sureOnclick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sureBtn;
}
- (UIButton *)cancelBtn {
    if (_cancelBtn == nil) {
        _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage* strechedImage = [[MGUtility MGImageName:@"MG_login_button_sel.png"] stretchableImageWithLeftCapWidth:5
                                                                                                         topCapHeight:5];
        [_cancelBtn setBackgroundImage:strechedImage
                            forState:UIControlStateNormal];
//        _cancelBtn.backgroundColor = TTRGBColor(0, 156, 227);
        [_cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _cancelBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        _cancelBtn.frame = CGRectMake(0, 0, 85, 28);
        _cancelBtn.layer.cornerRadius = CGRectGetHeight(_sureBtn.frame)*0.5;
        _cancelBtn.clipsToBounds = YES;
        [_cancelBtn addTarget:self action:@selector(cancelOnclick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelBtn;
}

- (UIView *)alertView {
    if (_alertView == nil) {
        _alertView = [[UIView alloc]init];
        _alertView.layer.cornerRadius = 5;
        _alertView.clipsToBounds = YES;
        _alertView.backgroundColor = [UIColor whiteColor];
    }
    return _alertView;
}
- (UILabel *)messageLabel {
    if (_messageLabel == nil) {
        _messageLabel = [[UILabel alloc]init];
        _messageLabel.numberOfLines = 0;
        _messageLabel.textColor = [UIColor grayColor];
        _messageLabel.font = [UIFont systemFontOfSize:16];
    }
    return _messageLabel;
}
- (UIView *)clearbgView {
    if (_clearbgView == nil) {
        _clearbgView = [UIView new];
    }
    return _clearbgView;
    
}


- (instancetype)alerViewWithMessige:(NSString *)messige withType:(AlertType)type {
    if (self == [super init]) {
        self.frame = [UIScreen mainScreen].bounds;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clerView)];
        [self addGestureRecognizer:tap];
        self.clearbgView.frame = self.frame;
        [self.clearbgView addGestureRecognizer:tap];
        
        [self addSubview:self.clearbgView];
        
        self.type = type;
        self.message = messige;
        CGFloat H = 50;
        self.messageLabel.frame = CGRectMake(10, 25, [self heightForString:messige andWidth:self.bounds.size.width*0.4 - 20].width, [self heightForString:messige andWidth:self.bounds.size.width*0.4 - 20].height);
        self.messageLabel.text = messige;
        [self.alertView addSubview:self.messageLabel];
        H += CGRectGetHeight(self.messageLabel.frame);
        
        
        
        if (type == AlertTypeWithSure) {
            self.sureBtn.frame = CGRectMake(0, H, 85, 28);
            [self.alertView addSubview:self.sureBtn];
            
        }else{
            self.sureBtn.frame = CGRectMake(0, H, 85, 28);
            self.cancelBtn.frame = CGRectMake(0, H, 85, 28);
            [self.alertView addSubview:self.sureBtn];
            [self.alertView addSubview:self.cancelBtn];
        }
        H += 48;
        
        self.alertView.frame = CGRectMake(0, 0, self.bounds.size.width*0.4, H);
        
        [self addSubview:self.alertView];
    }
    
    
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.type == AlertTypeWithSure) {
        [self.sureBtn setOriginX:(self.alertView.frame.size.width - 85) *0.5];
    }else {
        [self.sureBtn setOriginX:(self.alertView.frame.size.width * 0.5) - 105];
        [self.cancelBtn setOriginX:(self.alertView.frame.size.width * 0.5)+20];
    }
    if (self.messageLabel.frame.size.height > [self heightForString:@"测试" andWidth:self.bounds.size.width*0.4 - 20].height) {
    
        [self.messageLabel setOriginX:10];
    }else {
        [self.messageLabel setOriginX:(self.alertView.frame.size.width - [self heightForString:self.message andWidth:self.bounds.size.width*0.4 - 20].width) *0.5];
    }
}


- (void)show {
    
//    UIWindow *rootWindow = [UIApplication sharedApplication].keyWindow;
    UIWindow *rootWindow = [[UIApplication sharedApplication].windows lastObject];
    [rootWindow addSubview:self];
    [self creatShowAnimation];
}

- (void)dissmiss {
    [self removeFromSuperview];
}

- (void)clerView {
    [self dissmiss];
}



#pragma mark -- tager
- (void)cancelOnclick:(UIButton *)btn {
    if (self.handler) {
        self.handler(0);
    }
}

- (void)sureOnclick:(UIButton *)btn {
    if (self.handler) {
        self.handler(1);
    }
}

- (void)creatShowAnimation
{
    self.alertView.layer.position = self.center;
    self.alertView.transform = CGAffineTransformMakeScale(0.90, 0.90);
    [UIView animateWithDuration:0.25 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:1 options:UIViewAnimationOptionCurveLinear animations:^{
        self.alertView.transform = CGAffineTransformMakeScale(1.0, 1.0);
    } completion:^(BOOL finished) {
    }];
}




- (CGSize) heightForString:(NSString *)value andWidth:(float)width{
    
    NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:value attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:16.0f]}];
    
    NSRange range = NSMakeRange(0, attrStr.length);
    
    NSDictionary *dic = [attrStr attributesAtIndex:0 effectiveRange:&range];
  
    CGSize sizeToFit = [value boundingRectWithSize:CGSizeMake(width, MAXFLOAT)
                                           options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                        attributes:dic
                                           context:nil].size;
    return sizeToFit;
}



@end
