//
//  MGRegisterAgreementController.m
//  MGPlatformTest
//
//  Created by Eason on 03/05/2014.
//  Copyright (c) 2014 Eason. All rights reserved.
//

#import "MGRegisterAgreementController.h"
#import <WebKit/WebKit.h>

@interface MGRegisterAgreementController ()

@property (nonatomic, strong) WKWebView *webView;

@end

@implementation MGRegisterAgreementController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (TT_IS_IOS7_AND_UP) {
        if ([MGManager defaultManager].Private_URL.length) {
            self.title = @"隐私保护协议&儿童隐私保护协议";
        }else {
            self.title = @"用户协议";
        }
    }else{
        if ([MGManager defaultManager].Private_URL.length) {
            [self.navigationItem setTitleView:[MGUtility naviTitle:@"隐私保护协议&儿童隐私保护协议"]];
        }else {
            [self.navigationItem setTitleView:[MGUtility naviTitle:@"用户协议"]];
        }
        
        [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:[MGUtility newBackItemButtonIos6Target:self action:@selector(back:)]]];
        
    }

    if (I_PHONE_X) {
        _webView = [[WKWebView alloc] initWithFrame:CGRectMake(30, 0, self.view.frame.size.width - 60, self.view.frame.size.height - 32)];
    }else {
        _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 10, self.view.frame.size.width, self.view.frame.size.height - 42)];
    }
    [self.view addSubview:self.webView];
    NSString *timeSp = [NSString stringWithFormat:@"%ld",(long)[[NSDate date]timeIntervalSince1970]];
    NSDictionary *dict = @{
        @"appid":[MGManager defaultManager].MG_APPID,
        @"ts":timeSp
    };
    NSString *sign = [self getsign:dict appKey:[MGManager defaultManager].MG_APPKEY];
    
    if ([MGManager defaultManager].Private_URL.length) {
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[MGManager defaultManager].Private_URL]]];
    }else {
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://adapi.mg3721.com/inapi/getProtocol?appid=%@&sign=%@&ts=%@",[MGManager defaultManager].MG_APPID,sign,timeSp]]]];
//        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://dev.mg3721.com/inapi/getProtocol?appid=%@&sign=%@&ts=%@",[MGManager defaultManager].MG_APPID,sign,timeSp]]]];
    }
    
    
    self.webView.scrollView.showsHorizontalScrollIndicator = false;
    self.webView.scrollView.bounces = false;
    if (@available(iOS 11.0, *)) {
        [self.webView.scrollView setInsetsLayoutMarginsFromSafeArea:false];
        self.webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
}


- (NSString *) getsign:(NSDictionary *) params appKey:(id) appkey
{
    
    
    NSMutableArray *pairs = [NSMutableArray new];
    NSArray *keys = [[params allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2];
    }];
    
    for (NSString *key in keys) {
        [pairs addObject:[NSString stringWithFormat:@"%@=%@", key, params[key]]];
    }
    NSString *query = [pairs componentsJoinedByString:@"&"];
    
    NSString *query_key = [NSString stringWithFormat:@"%@%@", appkey, query];
    
    NSString *sign = [MGUtility md5:query_key];
    
    return sign;
}
- (void) viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self.webView reload];
}

- (void)dismissself:(UIButton *)btn {
    //    [super dismissself:btn];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
