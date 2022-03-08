//
//  XYProtectionController.m
//  MGSDKTest
//
//  Created by 王浩2 on 2020/12/22.
//  Copyright © 2020 xyzs. All rights reserved.
//

#import "XYProtectionController.h"
#import "MGTAttributedLabel.h"
#import "MGConfiguration.h"
#import "MGRegisterAgreementController.h"

NSString *const contetStr  = @"我们依据最新的法律要求制定了隐私协议。\n \n \n     请您充分阅读并理解相关条款，包括但不限于：我们如何收集和使用您的个人信息；我们如何共享、转让、公开披露您的个人信息；我们如何保护和保存您的个人信息；您的权利等内容。\n\n\n       您可以阅读《隐私保护协议&儿童隐私保护协议》了解详细信息。如您同意，请点击“同意”开始接受我们的服务。";

NSString *const contetStr1  = @"我们依据最新的法律要求制定了隐私协议。\n\n    请您充分阅读并理解相关条款，包括但不限于：我们如何收集和使用您的个人信息；我们如何共享、转让、公开披露您的个人信息；我们如何保护和保存您的个人信息；您的权利等内容。\n\n   您可以阅读《隐私保护协议&儿童隐私保护协议》了解详细信息。如您同意，请点击“同意”开始接受我们的服务。";

@interface XYProtectionController ()<TTTAttributedLabelDelegate>

@property (nonatomic,strong)UIView  *bottomView;
@property (nonatomic,strong)UILabel *tipLab;
@property (nonatomic,strong)MGTAttributedLabel *contentLab;
@property (nonatomic,strong)UIButton *disAgreeBtn;
@property (nonatomic,strong)UIButton *agreeBtn;

@end

@implementation XYProtectionController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:175.0f/255.0f green:200.0f/255.0f blue:216.0f/255.0f alpha:1.0];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
        
    if (iPad_L) {
        self.bottomView.bounds = CGRectMake(0, 0, 600, 450);
        self.tipLab.frame = CGRectMake(0, 15, self.bottomView.frame.size.width, 40);
        self.contentLab.frame = CGRectMake(15, CGRectGetMaxY(self.tipLab.frame)+15, CGRectGetWidth(self.tipLab.frame)-30, 250);
        self.disAgreeBtn.bounds = CGRectMake(0, 0, 170, 46);
        self.agreeBtn.bounds = CGRectMake(0, 0, 170, 46);
    }
    
    self.bottomView.center = CGPointMake(self.view.center.x, self.view.center.y);
    self.disAgreeBtn.center = CGPointMake((CGRectGetWidth(self.bottomView.frame)-170)/2-10, CGRectGetMaxY(self.contentLab.frame)+55);
    self.agreeBtn.center = CGPointMake((CGRectGetWidth(self.bottomView.frame)-170)/2+180, CGRectGetMaxY(self.contentLab.frame)+55);
    
    if (iPhone_L) {
        self.bottomView.bounds = CGRectMake(0, 0, 440, 260);
        self.tipLab.frame = CGRectMake(0, 15, self.bottomView.frame.size.width, 30);
        self.contentLab.frame = CGRectMake(15, CGRectGetMaxY(self.tipLab.frame), CGRectGetWidth(self.tipLab.frame)-30, 150);
        self.disAgreeBtn.bounds = CGRectMake(0, 0, 150, 32);
        self.agreeBtn.bounds = CGRectMake(0, 0, 150, 32);
        
        self.disAgreeBtn.center = CGPointMake((CGRectGetWidth(self.bottomView.frame)-170)/2-10, CGRectGetMaxY(self.contentLab.frame)+33);
        self.agreeBtn.center = CGPointMake((CGRectGetWidth(self.bottomView.frame)-170)/2+180, CGRectGetMaxY(self.contentLab.frame)+33);
    }

    NSString *contStr = contetStr;
    if (iPhone_L) {
        contStr = contetStr1;
    }
    
    [self.contentLab setText:contStr afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
        
        NSRange lighRang = [[mutableAttributedString string] rangeOfString:@"《隐私保护协议&儿童隐私保护协议》" options:NSCaseInsensitiveSearch];
        //文字颜色
        [mutableAttributedString addAttribute:(NSString *)kCTForegroundColorAttributeName value:[UIColor colorWithRed:33.0f/255.0f green:100.0f/255.0f blue:240.0f/255.0f alpha:1.0] range:lighRang];
        
        return mutableAttributedString;
    }];
    
    NSRange addressRange = [contStr rangeOfString:@"《隐私保护协议&儿童隐私保护协议》" options:NSCaseInsensitiveSearch];
    [self.contentLab addLinkWithTextCheckingResult:[NSTextCheckingResult linkCheckingResultWithRange:addressRange URL:[NSURL URLWithString:@""]]];
//    [self.contentLab addLinkWithTextCheckingResult:[NSTextCheckingResult linkCheckingResultWithRange:addressRange URL:[NSURL URLWithString:@""]] attributes:@{}];
}

- (UIView *)bottomView{
    if (!_bottomView) {
        _bottomView = [[UIView alloc]init];
        _bottomView.backgroundColor = UIColor.whiteColor;
        _bottomView.layer.cornerRadius = 22;
        _bottomView.layer.masksToBounds = YES;
        [self.view addSubview:_bottomView];
    }
    return _bottomView;
}

- (UILabel *)tipLab{
    if (!_tipLab) {
        _tipLab = [[UILabel alloc]init];
        _tipLab.backgroundColor = UIColor.whiteColor;
        if (iPad_L) {
            _tipLab.font = [UIFont boldSystemFontOfSize:25];
        }
        if (iPhone_L) {
            _tipLab.font = [UIFont boldSystemFontOfSize:20];
        }
        _tipLab.textAlignment = NSTextAlignmentCenter;
        _tipLab.text = @"隐私协议概要";
        _tipLab.textColor = UIColor.blackColor;
        [self.bottomView addSubview:_tipLab];
    }
    return _tipLab;
}

- (UILabel *)contentLab{
    if (!_contentLab) {
        _contentLab = [[MGTAttributedLabel alloc]init];
        _contentLab.backgroundColor = UIColor.whiteColor;
        if (iPad_L) {
            _contentLab.font = [UIFont systemFontOfSize:18];
            _contentLab.text = contetStr;
        }
        if (iPhone_L) {
            _contentLab.font = [UIFont systemFontOfSize:14];
            _contentLab.text = contetStr1;
        }
        
        _contentLab.textAlignment = NSTextAlignmentLeft;
        _contentLab.textColor = UIColor.blackColor;
        _contentLab.numberOfLines = 0;
        
        _contentLab.delegate = self;
        [self.bottomView addSubview:_contentLab];
    }
    return _contentLab;
}

- (UIButton *)disAgreeBtn{
    if (!_disAgreeBtn) {
        _disAgreeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _disAgreeBtn.layer.cornerRadius = 23;
        if (iPhone_L) {
            _disAgreeBtn.layer.cornerRadius = 16;
        }
        _disAgreeBtn.layer.masksToBounds = YES;
        _disAgreeBtn.backgroundColor = [UIColor colorWithRed:135.0f/255.0f green:136.0f/255.0f blue:137.0f/255.0f alpha:1.0f];
        [_disAgreeBtn setTitle:@"暂不同意" forState:UIControlStateNormal];
        [_disAgreeBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        _disAgreeBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [_disAgreeBtn addTarget:self action:@selector(agreeProtocolUserInfo:) forControlEvents:UIControlEventTouchUpInside];
        [self.bottomView addSubview:_disAgreeBtn];
    }
    return _disAgreeBtn;
}

- (UIButton *)agreeBtn{
    if (!_agreeBtn) {
        _agreeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _agreeBtn.layer.cornerRadius = 23;
        if (iPhone_L) {
            _agreeBtn.layer.cornerRadius = 16;
        }
        _agreeBtn.layer.masksToBounds = YES;
        _agreeBtn.backgroundColor = [UIColor colorWithRed:34.0f/255.0f green:99.0f/255.0f blue:240.0f/255.0f alpha:1.0f];
        [_agreeBtn setTitle:@"同意" forState:UIControlStateNormal];
        [_agreeBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        _agreeBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [_agreeBtn addTarget:self action:@selector(agreeProtocolUserInfo:) forControlEvents:UIControlEventTouchUpInside];
        [self.bottomView addSubview:_agreeBtn];
    }
    return _agreeBtn;
}

- (void)agreeProtocolUserInfo:(UIButton *)sender{
    if (sender==self.disAgreeBtn) {
        UIWindow *window = [UIApplication sharedApplication].delegate.window;
        [UIView animateWithDuration:1.0f animations:^{
               window.alpha = 0;
               window.frame = CGRectMake(0, window.bounds.size.width, 0, 0);
           } completion:^(BOOL finished) {
               exit(0);
           }];
    }
    if (sender==self.agreeBtn) {
        if (self.agreeStatus) {
            self.agreeStatus(YES);
        }
    }
}

#pragma mark - TTTAttributedLabelDelegate

/*
@param label The label whose link was selected.
@param url The URL for the selected link.
*/
- (void)attributedLabel:(MGTAttributedLabel *)label
   didSelectLinkWithURL:(NSURL *)url{
    int privacy_version = [MGConfiguration shareConfiguration].privacy_version;
   
    if (privacy_version>0) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:[NSString stringWithFormat:@"%d",privacy_version] forKey:GDSaveDidPrivacyVersion];
        [userDefaults synchronize];
        [[MGConfiguration shareConfiguration] setShowPrivacyNew:YES];

    }
   
    MGRegisterAgreementController* agreementController = [[MGRegisterAgreementController alloc] init];
    agreementController.MGAction = MGActionLogin;
    
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.clipsToBounds = YES;
    UIImage *iv = [[MGUtility MGImageName:@"MG_navi_bg.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:40];
    [self.navigationController.navigationBar setBackgroundImage:iv forBarMetrics:UIBarMetricsDefault];
    self.navigationController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    [MGManager defaultManager].Private_URL = [NSString stringWithFormat:@"https://adapi.mg3721.com/inapi/privacy?appid=%@", [MGManager defaultManager].MG_APPID];
    [self.navigationController pushViewController:agreementController
                                         animated:YES];
}

/**
Tells the delegate that the user did select a link to an address.

@param label The label whose link was selected.
@param addressComponents The components of the address for the selected link.
*/
- (void)attributedLabel:(MGTAttributedLabel *)label
didSelectLinkWithAddress:(NSDictionary *)addressComponents{
    
}

/**
Tells the delegate that the user did select a link to a phone number.

@param label The label whose link was selected.
@param phoneNumber The phone number for the selected link.
*/
- (void)attributedLabel:(MGTAttributedLabel *)label
didSelectLinkWithPhoneNumber:(NSString *)phoneNumber{
    
    
}

/**
Tells the delegate that the user did select a link to a date.

@param label The label whose link was selected.
@param date The datefor the selected link.
*/
- (void)attributedLabel:(MGTAttributedLabel *)label
  didSelectLinkWithDate:(NSDate *)date{
    
}

/**
Tells the delegate that the user did select a link to a date with a time zone and duration.

@param label The label whose link was selected.
@param date The date for the selected link.
@param timeZone The time zone of the date for the selected link.
@param duration The duration, in seconds from the date for the selected link.
*/
- (void)attributedLabel:(MGTAttributedLabel *)label
 didSelectLinkWithDate:(NSDate *)date
              timeZone:(NSTimeZone *)timeZone
               duration:(NSTimeInterval)duration{
    
}

/**
Tells the delegate that the user did select a link to transit information

@param label The label whose link was selected.
@param components A dictionary containing the transit components. The currently supported keys are `NSTextCheckingAirlineKey` and `NSTextCheckingFlightKey`.
*/
- (void)attributedLabel:(MGTAttributedLabel *)label
didSelectLinkWithTransitInformation:(NSDictionary *)components{
  
}

/**
Tells the delegate that the user did select a link to a text checking result.

@discussion This method is called if no other delegate method was called, which can occur by either now implementing the method in `TTTAttributedLabelDelegate` corresponding to a particular link, or the link was added by passing an instance of a custom `NSTextCheckingResult` subclass into `-addLinkWithTextCheckingResult:`.

@param label The label whose link was selected.
@param result The custom text checking result.
*/
- (void)attributedLabel:(MGTAttributedLabel *)label
didSelectLinkWithTextCheckingResult:(NSTextCheckingResult *)result{
    
}




/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
