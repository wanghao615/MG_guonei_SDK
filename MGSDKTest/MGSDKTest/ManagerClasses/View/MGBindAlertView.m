//
//  MGBindAlertView.m
//  MGSDKTest
//
//  Created by ZYZ on 2018/1/31.
//  Copyright © 2018年 MG. All rights reserved.
//

#import "MGBindAlertView.h"
#import "UIView+MGHandleFrame.h"
#import "MGConfiguration.h"
#import "MGIdentityVerificationAlertView.h"
#import "MGHttpClient.h"

@interface MGBindAlertView()<MGIdentityVerificationAlertViewDelegate>
@property(nonatomic,strong)UIView *clearbgView;

@property(nonatomic,strong)NSString *message;

@property(nonatomic,strong)UIView *alertView;

@property(nonatomic,strong)UILabel *messageLabel;

@property(nonatomic,strong)UIButton *bindPhoneBtn;

@property(nonatomic,strong)UIButton *checkNameBtn;

@property(nonatomic,strong)UIButton *closeBtn;

@property (nonatomic, strong) MGIdentityVerificationAlertView *IdentityVerificationAlert;
@end

@implementation MGBindAlertView

- (UIButton *)closeBtn {
    if (_closeBtn == nil) {
        _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeBtn setImage:[MGUtility MGImageName:@"alert_close_btn"] forState:UIControlStateNormal];
        _closeBtn.frame = CGRectMake(0, 0, 25, 25);
        [_closeBtn addTarget:self action:@selector(closeView:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeBtn;
}

- (UIButton *)bindPhoneBtn {
    if (_bindPhoneBtn == nil) {
        _bindPhoneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _bindPhoneBtn.backgroundColor = [UIColor orangeColor];
        [_bindPhoneBtn setTitle:@"绑定手机" forState:UIControlStateNormal];
        [_bindPhoneBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _bindPhoneBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        _bindPhoneBtn.frame = CGRectMake(0, 0, 85, 35);
        [_bindPhoneBtn addTarget:self action:@selector(bindphoneOnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _bindPhoneBtn;
}
- (UIButton *)checkNameBtn {
    if (_checkNameBtn == nil) {
        _checkNameBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _checkNameBtn.backgroundColor = TTRGBColor(0, 156, 227);
        [_checkNameBtn setTitle:@"实名认证" forState:UIControlStateNormal];
        [_checkNameBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _checkNameBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        _checkNameBtn.frame = CGRectMake(0, 0, 85, 35);
        [_checkNameBtn addTarget:self action:@selector(checkNameOnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _checkNameBtn;
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
        _clearbgView = [[UIView alloc]initWithFrame:self.frame];
        _clearbgView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    }
    return _clearbgView;
    
}


- (instancetype)alerViewWithMessige:(NSString *)messige {
    if (self == [super init]) {
        MGAccountSettingInfo *info = [MGStorage currentAccountSettingInfo];
        
        
        self.frame = [UIScreen mainScreen].bounds;

        [self addSubview:self.clearbgView];
        
        
        [self.alertView addSubview:self.closeBtn];
        
        self.message = messige;
        CGFloat H = 47 + 10;
        self.messageLabel.frame = CGRectMake(10, H, [self heightForString:messige andWidth:self.bounds.size.width*0.5 - 20].width, [self heightForString:messige andWidth:self.bounds.size.width*0.5 - 20].height);
        self.messageLabel.text = messige;
        [self.alertView addSubview:self.messageLabel];
        H += CGRectGetHeight(self.messageLabel.frame) + 20;
        
        self.bindPhoneBtn.frame = CGRectMake(0, H, self.messageLabel.frame.size.width * 0.8, 35);
        
        [self.alertView addSubview:self.bindPhoneBtn];
        H += 35 + 10;
        
        self.checkNameBtn.frame = CGRectMake(0, H, self.messageLabel.frame.size.width * 0.8, 35);
        [self.alertView addSubview:self.checkNameBtn];
        H += 35 + 10;
        
        self.alertView.frame = CGRectMake(0, 0, self.bounds.size.width*0.5, H+50);
        
        self.closeBtn.frame = CGRectMake(CGRectGetMaxX(self.alertView.frame) - 40, 20, 25, 25);
        
        [self addSubview:self.alertView];
        
        if ([info.phoneStatus isEqualToString:@"1"]) {
            self.bindPhoneBtn.hidden = YES;
        }
        if ([info.idCardBindStatus isEqualToString:@"1"]) {
            self.checkNameBtn.hidden = YES;
        }
    }
    
    
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.bindPhoneBtn setOriginX:(self.alertView.frame.size.width  - self.messageLabel.frame.size.width * 0.8)* 0.5];
    [self.checkNameBtn setOriginX:(self.alertView.frame.size.width  - self.messageLabel.frame.size.width * 0.8)* 0.5];
    if (self.messageLabel.frame.size.height > [self heightForString:@"测试" andWidth:self.bounds.size.width*0.5 - 20].height) {
        
        [self.messageLabel setOriginX:10];
    }else {
        [self.messageLabel setOriginX:(self.alertView.frame.size.width - [self heightForString:self.message andWidth:self.bounds.size.width*0.5 - 20].width) *0.5];
    }
}


- (void)show {
    UIWindow *rootWindow = [UIApplication sharedApplication].keyWindow;
    [rootWindow addSubview:self];
    [self creatShowAnimation];
}

- (void)dissmiss {
    [self removeFromSuperview];
}




#pragma mark -- tager
- (void)bindphoneOnClick:(UIButton *)btn {
    if (self.handler) {
        self.handler(0);
    }
    __weak typeof(self) weakSelf = self;
    [[MGManager defaultManager]MGEnterBindPhoneCompletion:^(NSString *phone, BOOL bindstatus) {
        if (bindstatus == YES&&phone != 0) {
            [weakSelf dissmiss];
        }
    }];
}

- (void)checkNameOnClick:(UIButton *)btn {
    if (self.handler) {
        self.handler(1);
    }
//    [[MGManager defaultManager]MGCheckidCard];
     [self.IdentityVerificationAlert show];
}

- (void)closeView:(UIButton *)btn {
    if (self.closeSelf) {
        self.closeSelf();
    }
    
    [self dissmiss];
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


#pragma mark - 防沉迷验证 began ------------------------------------------
- (MGIdentityVerificationAlertView *)IdentityVerificationAlert {
    
    if (_IdentityVerificationAlert == nil) {
        NSString *title = @"填写身份证认证信息";
        CGFloat w = TT_IS_IPAD ? 420 : 290;
        _IdentityVerificationAlert = [[MGIdentityVerificationAlertView alloc] initWithCancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        
        MGIdentityVerificationContainerView *view = [[MGIdentityVerificationContainerView alloc] initWithWidth:w title:title message:nil];
        [view setMessageAlignment:NSTextAlignmentLeft];
        [view setMessageColor:[UIColor redColor]];
        [view addVerifyIdentidyView];
        view.alertVC = _IdentityVerificationAlert.rootVC;
        
        _IdentityVerificationAlert.shouldUpdateButtonsUIWhenLandscape = YES;
        [_IdentityVerificationAlert setContainerView:view];
        _IdentityVerificationAlert.alertDelegate = self;
    }
    
    return _IdentityVerificationAlert;
}

#pragma mark - MGIdentityVerificationAlertViewDelegate

- (void)MGIdentityVerificationAlertView:(MGIdentityVerificationAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0) {
        [self IdentityVerificationSubmitCompleteInfo:alertView];
    } else {
        [alertView dismiss];
        
        [_IdentityVerificationAlert.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        _IdentityVerificationAlert = nil;
        
//        if ([self.idCardStats isEqualToString:@"1"]) {
//            [[MGManager defaultManager] MGUserLogin:0];
//        }
        
    }
}


- (void)MGIdentityVerificationAlertViewEndTextFieldsEditing:(MGIdentityVerificationAlertView *)alertView {
    [self IdentityVerificationSubmitCompleteInfo:alertView];
}


- (void)showIdentityVerificationAlertViewString:(NSString*)alertString
{
    if (IPHONE_8_UP) {
        
        [UIAlertView showWithTitle:nil
                           message:alertString
                 cancelButtonTitle:@"确定"
                 otherButtonTitles:nil
                          tapBlock:^(UIAlertView* alertView, NSInteger buttonIndex) {
                          }];
    }else
        [MGSVProgressHUD showErrorWithStatus:alertString];
}


- (void)IdentityVerificationSubmitCompleteInfo:(MGIdentityVerificationAlertView *)alertView {
    
    NSString *name = alertView.inputStrings[0];
    NSString *idCardNum = alertView.inputStrings[1];
    
    if (![MGUtility validateName:name andErrorMsg:^(NSString *errorMsg) {
        MGAlertCustomView *alerView = [[MGAlertCustomView alloc]alerViewWithMessige:errorMsg withType:AlertTypeWithSure];
        __weak typeof(alerView) weakalert = alerView;
        alerView.handler = ^(NSInteger index){
            if (index == 1) {
                [weakalert dissmiss];
            }
        };
        [alerView show];
        
    }])
    {
        return;
    }
    
    if (![MGUtility validateIdCardNum:idCardNum andErrorMsg:^(NSString *errorMsg) {
        MGAlertCustomView *alerView = [[MGAlertCustomView alloc]alerViewWithMessige:errorMsg withType:AlertTypeWithSure];
        __weak typeof(alerView) weakalert = alerView;
        alerView.handler = ^(NSInteger index){
            if (index == 1) {
                [weakalert dissmiss];
            }
        };
        [alerView show];
        
    }])
    {
        return;
    }
    
    __block MGIdentityVerificationAlertView *alert = alertView;
    
    MGUserIdCard *userInfo = [[MGUserIdCard alloc]init];
    userInfo.name = name;
    userInfo.idCard = idCardNum;
    __weak typeof(self) weakSelf = self;
    [self bindIdCard:userInfo completion:^(BOOL success) {
        if (success) {
            [alert dismiss];
            [weakSelf dissmiss];
        }
    }];
}

- (void)bindIdCard:(MGUserIdCard *)userInfo completion:(void (^)(BOOL success))block {
    [MGSVProgressHUD showWithStatus:@"身份认证中..." maskType:MGSVProgressHUDMaskTypeClear];
    __weak typeof(&*self) weakSelf = self;
    [[MGHttpClient shareMGHttpClient] bindIdCard:userInfo completion:^(NSDictionary *responseDic) {
        
        MGAccountSettingInfo *info = [MGStorage currentAccountSettingInfo];
        info.idCardBindStatus = @"1";
        
        info.is_adult = @"2";
             NSString *borthDateStr = [userInfo.idCard substringWithRange:NSMakeRange(6, 8)];
             NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
             [dateFormatter setDateFormat:@"YYYYMMdd"];
             NSDate *borthDate = [dateFormatter dateFromString:borthDateStr];
             //获得当前系统时间
             NSDate *currentDate = [NSDate date];
             //获得当前系统时间与出生日期之间的时间间隔
             NSTimeInterval time = [currentDate timeIntervalSinceDate:borthDate];
             //时间间隔以秒作为单位,求年的话除以60*60*24*356
             int age = ((int)time)/(3600*24*365);
             if (age >= 18) {
                 info.is_adult = @"1";
             }else {
                 info.is_adult = @"0";
             }
        
        [MGStorage setOneAccountSettingInfo:info isCurrentAccount:YES];
        
        if (block) {
            block(YES);
        }
        weakSelf.IdentityVerificationAlert = nil;
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"认证成功" delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
        [alertView show];
        double delayInSeconds = 1.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            
            
            [alertView dismissWithClickedButtonIndex:0 animated:YES];
        });
        
        
    } failed:^(NSInteger ret, NSString *errMsg) {
        [MGSVProgressHUD dismiss];
        MGAlertCustomView *alerView = [[MGAlertCustomView alloc]alerViewWithMessige:errMsg withType:AlertTypeWithSure];
        __weak typeof(alerView) weakalert = alerView;
        alerView.handler = ^(NSInteger index){
            if (index == 1) {
                [weakalert dissmiss];
            }
        };
        [alerView show];
//        [MGSVProgressHUD showErrorWithStatus:errMsg];
        
    }];
}





#pragma mark - 防沉迷验证 end --------------------------------------------


@end
