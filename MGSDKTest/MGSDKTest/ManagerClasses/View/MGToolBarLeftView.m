//
//  MGToolBarLeftView.m
//  MGPlatformTest
//
//  Created by ZYZ on 2017/9/14.
//  Copyright © 2017年 MGzs. All rights reserved.
//

#import "MGToolBarLeftView.h"
#import "MGManager.h"
#import "MGSVProgressHUD.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "UIView+MGHandleFrame.h"
#import "MGHttpClient.h"
#import "MGSalesAccountView.h"


@interface MGToolBarLeftView ()<WKNavigationDelegate,WKUIDelegate,WKScriptMessageHandler>

//@property(nonatomic,strong)WKWebView *webView;


@property (nonatomic, strong) JSContext *jsContext;

@end

@implementation MGToolBarLeftView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setUP];
    }
    return self;
}

- (void)setUP {
    self.backgroundColor = [UIColor lightGrayColor];
    
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    
    WKUserContentController *userCC = config.userContentController;
    
    
    //JS调用OC 添加处理脚本
    [userCC addScriptMessageHandler:self name:@"bindPhone"];
    [userCC addScriptMessageHandler:self name:@"bindidCard"];

    
    WKWebView *webView = [[WKWebView alloc] initWithFrame:self.bounds configuration:config];
    webView.navigationDelegate = self;
    webView.opaque = NO;
    webView.UIDelegate = self;
    webView.scrollView.bounces = false;
    webView.backgroundColor = [UIColor clearColor];
    if (@available(iOS 11.0, *)) {
        [webView.scrollView setInsetsLayoutMarginsFromSafeArea:false];
        webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    
    
    [self addSubview:webView];
    
    self.webView = webView;
    
    [self load:@"https://adapi.mg3721.com/float/iframe"];
//    [self load:@"https://test.mg3721.com/float/iframe"];
    
}



- (void)load:(NSString *)url {
    
    NSString *uid = [[MGManager defaultManager]MGOpenUID];
    NSString *appid = [[MGManager defaultManager]MG_APPID];
    NSString *token =  [[MGManager defaultManager] MGToken];

    if (uid.length > 1&&appid.length > 1&&token.length >1) {
        NSDictionary *dict = @{
                               @"uid":uid,
                               @"appid":appid,
                               @"token":token,
                               @"version" : MGAPPVersion,
                               @"sdk_version" : [MGManager sdkVersion]
                               };
        NSString *sign = [self getsign:dict appKey:[MGManager defaultManager].MG_APPKEY];
        
        NSString *URL = [NSString stringWithFormat:@"%@?uid=%@&appid=%@&token=%@&version=%@&sdk_version=%@&sign=%@",url,uid,appid,token,MGAPPVersion,[MGManager sdkVersion],sign];
        
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:URL]];
        
        
        [self.webView loadRequest:request];
    }else {
        
        [MGSVProgressHUD showErrorWithStatus:@"请重新登录账号"];
    }
    
}

- (void)refreshView {
    
    [self load:@"https://adapi.mg3721.com/float/iframe"];
//    [self load:@"https://test.mg3721.com/float/iframe"];
    
}


#pragma mark -- UIWebViewDelegate


//- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
//
//    if (([error.localizedDescription isEqualToString:@"未能完成操作。"])||error.code == -999) {
//
//        return;
//
//    }else {
//         [MGSVProgressHUD showErrorWithStatus:@"请重新登录"];
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//
//            [[MGManager defaultManager] performSelector:@selector(MGSwitchAccount) withObject:nil afterDelay:0];
//
//        });
//    }
//
//}
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    if (([error.localizedDescription isEqualToString:@"未能完成操作。"])||error.code == -999) {
        
        return;
        
    }else {
        [MGSVProgressHUD showErrorWithStatus:@"请重新登录"];
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//
//            [[MGManager defaultManager] performSelector:@selector(MGSwitchAccount) withObject:nil afterDelay:0];
//
//        });
    }
}
- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    if (([error.localizedDescription isEqualToString:@"未能完成操作。"])||error.code == -999) {
        
        return;
        
    }else {
        [MGSVProgressHUD showErrorWithStatus:@"请重新登录"];
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//
//            [[MGManager defaultManager] performSelector:@selector(MGSwitchAccount) withObject:nil afterDelay:0];
//
//        });
    }
    
}

//- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
//
//    NSArray *Cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];;
//
//
//    for (NSHTTPCookie *cookie in Cookies) {
//        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
//    }
//
//    NSString *url = request.URL.absoluteString;
//
//    if ([url hasPrefix:@"mg://"]) {
//        [self getParams:url];
//
//        return false;
//    }
//
//    return YES;
//
//}

// 在发送请求之前，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    
    
    
    NSString* reqUrl = navigationAction.request.URL.absoluteString;
    
    NSArray *Cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];;
    
    
    for (NSHTTPCookie *cookie in Cookies) {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
    }
    
    
    if ([reqUrl hasPrefix:@"mg://"]) {
        [self getParams:reqUrl];
        
        decisionHandler(WKNavigationActionPolicyCancel);
    }else {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
    
}

#pragma mark - WKScriptMessageHandler

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    
    if ([message.name isEqualToString:@"bindPhone"]) {
        NSString *phone = [NSString stringWithFormat:@"%@",message.body];
        
        MGAccountSettingInfo *info = [MGStorage currentAccountSettingInfo];
        info.phoneNum = [NSString stringWithFormat:@"%@", phone];
        info.phoneStatus = @"1";
        [MGStorage setOneAccountSettingInfo:info isCurrentAccount:YES];
        
    }
    if ([message.name isEqualToString:@"bindidCard"]) {
        
        MGAccountSettingInfo *info = [MGStorage currentAccountSettingInfo];
        info.idCardBindStatus = @"1";
        NSString *adultStr = [NSString stringWithFormat:@"%@",message.body];
        info.is_adult = adultStr;
        [MGStorage setOneAccountSettingInfo:info isCurrentAccount:YES];
        
    }

}

- (void)getParams:(NSString *)paramsStr {
    NSArray *components = [paramsStr componentsSeparatedByString:@"?"];
    
    NSString *methodName = [components firstObject];
    
    methodName = [methodName stringByReplacingOccurrencesOfString:@"mg://" withString:@""];
    methodName = [methodName stringByAppendingString:@":"];
    SEL sel = NSSelectorFromString(methodName);
    
    NSString *parameter = [components lastObject];
    NSArray *params = [parameter componentsSeparatedByString:@"&"];
    
    
    if (params.count == 2) {
        if ([self respondsToSelector:sel]) {
            //登录失效
            if ([methodName isEqualToString:@"LoginError:"]) {
                [self LoginError:[[params lastObject]componentsSeparatedByString:@"="].lastObject];
            }else if ([[[params firstObject]componentsSeparatedByString:@"="].lastObject isEqualToString:@"0"]) {
                [self showSuccess:[[params lastObject]componentsSeparatedByString:@"="].lastObject];
            }else{
                [self showError:[[params lastObject]componentsSeparatedByString:@"="].lastObject];
            }
            

        }
    }else if (params.count == 3) {
        if ([[[params firstObject]componentsSeparatedByString:@"="].lastObject isEqualToString:@"0"]) {
            [self cancellationAccount: [[params lastObject]componentsSeparatedByString:@"="].lastObject];
        }
    }
}

- (void)cancellationAccount:(NSString *)accountStr {
    
    MGSalesAccountView *salesAccountV = [MGSalesAccountView salesAccountViewWithAccount:accountStr];
    [[UIApplication sharedApplication].keyWindow addSubview:salesAccountV];
    
//    MGAlertCustomView *alerView = [[MGAlertCustomView alloc]alerViewWithMessige:@"确认注销账号吗？一旦确认，账号将永久注销！" withType:AlertTypeWithSureandCancel];
//    alerView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.35];
//    __weak typeof(alerView) weakalert = alerView;
//    alerView.handler = ^(NSInteger index){
//        if (index == 0) {
//            [weakalert dissmiss];
//        }else {
//            [weakalert dissmiss];
//
//            [MGSVProgressHUD showWithStatus:@"正在销户中..." maskType:MGSVProgressHUDMaskTypeClear];
//
//            [[MGHttpClient shareMGHttpClient] cancellationAccountCompletion:^(NSDictionary *responseDic) {
//
//                [MGSVProgressHUD showWithStatus:@"销户成功" maskType:MGSVProgressHUDMaskTypeClear];
//
//                [MGStorage removeAccountSettingInfoByAccount:accountStr];
//                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.35 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                    [[MGManager defaultManager] performSelector:@selector(MGSwitchAccount) withObject:nil afterDelay:0];
//                });
//
//                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                    [MGSVProgressHUD dismiss];
//                });
//
//            } failed:^(NSInteger ret, NSString *errMsg) {
//
//                NSString *err = [NSString stringWithFormat:@"账号销户失败，%@", errMsg];
//                [MGSVProgressHUD showErrorWithStatus:err];
//
//            }];
//
//        }
//    };
//    [alerView show];
}


- (void)LoginError:(NSString *)Str {
    
    NSString *infoStr = [Str stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [MGSVProgressHUD showErrorWithStatus:infoStr];
    
    
    
   
   
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//
//            [[MGManager defaultManager] performSelector:@selector(MGSwitchAccount) withObject:nil afterDelay:0];
//
//        });
    
    
}



- (void)showSuccess:(NSString *)Str {
    
    //判断如果是修改密码 成功重新登录
    
    NSString *infoStr = [Str stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    if ([infoStr isEqualToString:@"修改成功"]) {
        
         [MGSVProgressHUD showSuccessWithStatus:infoStr];
        
       
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [[MGManager defaultManager] performSelector:@selector(MGSwitchAccount) withObject:nil afterDelay:0];
            
        });
        
    }else if ([infoStr isEqualToString:@"切换账号"]){
        
        [MGSVProgressHUD showSuccessWithStatus:infoStr];
        
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [[MGManager defaultManager] performSelector:@selector(MGSwitchAccount) withObject:nil afterDelay:0];
           
         });
        
    }else {
      [MGSVProgressHUD showSuccessWithStatus:[Str stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }
    
    
    
}

- (void)showError:(NSString *)Str {
    
//    [MGSVProgressHUD showErrorWithStatus:[Str stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
//  [self refreshView];
//    [UIView animateWithDuration:0.25 animations:^{
//        [self setOriginX:-(self.frame.size.width)];
//    }completion:^(BOOL finished) {
//        if ([self.delegate respondsToSelector:@selector(showErrorWithAlert:completion:)]) {
//            [self.delegate showErrorWithAlert:[Str stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] completion:^{
//                [self refreshView];
//            }];
//        }
//    }];
    if ([[Str stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] isEqualToString:@"账号错误"]) {
         [self refreshView];
    }
}


#pragma mark -- 参数

-(NSString*)encodeString:(NSString*)unencodedString{
    NSString *encodedString = (NSString *)
    CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                              (CFStringRef)unencodedString,
                                                              NULL,
                                                              (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                              kCFStringEncodingUTF8));
    
    return encodedString;
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

//- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
//
//    UIView* __tmpView = [super hitTest:point withEvent:event];
//    if (I_PHONE_X) {
//        if (__tmpView == nil) {
//            CGPoint tempoint = [self.webView convertPoint:point fromView:self];
//            if (CGRectContainsPoint(self.webView.bounds, tempoint)) {
//                __tmpView = self.webView;
//
//            }
//    }
//    }
//    return __tmpView;
//}


- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
