//
//  MGWebViewController.m
//  MGPlatformTest
//
//  Created by 曹 胜全 on 7/14/14.
//

#import "MGWebViewController.h"
#import "MGManager+MGUserInfo.h"
#import <WebKit/WebKit.h>

@interface MGWebViewController ()<WKNavigationDelegate,WKUIDelegate,WKScriptMessageHandler, UIAlertViewDelegate>
{
    BOOL bEnable;
    BOOL bCanOpen;
}

@property(nonatomic,strong)WKWebView *webView;

@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *naviTitle;

@end

@implementation MGWebViewController

- (instancetype) initWithUrl:(NSString *) url andTitle:(NSString *) title
{
    self = [super init];
    if (self) {
        self.url = url;
        self.naviTitle = title;
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (TT_IS_IOS7_AND_UP) {
        self.title = self.naviTitle;
    }else{
        [self.navigationItem setTitleView:[MGUtility naviTitle:self.naviTitle]];
        [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:[MGUtility newBackItemButtonIos6Target:self action:@selector(back:)]]];
    }
    
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
      
      WKUserContentController *userCC = config.userContentController;
            
      WKWebView *webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:config];
      webView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
      webView.navigationDelegate = self;
      webView.opaque = NO;
      webView.UIDelegate = self;
      webView.scrollView.bounces = false;
//      webView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:webView];
      
      self.webView = webView;
    
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.url]];
         
         
         [self.webView loadRequest:request];
    
//    _webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
//    _webView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
//    [self.view addSubview:self.webView];
//    self.webView.delegate = self;
//    self.webView.scalesPageToFit = YES;
//
//    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.url]];
//    [self.webView loadRequest:request];
    [MGSVProgressHUD showWithStatus:@"正在加载..."];
    
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (TT_IS_IOS7_AND_UP) {
        bEnable = self.navigationController.interactivePopGestureRecognizer.enabled;
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}

- (void) viewWillDisappear:(BOOL)animated
{
    if (TT_IS_IOS7_AND_UP) {
        self.navigationController.interactivePopGestureRecognizer.enabled = bEnable;
    }
    
    if (self.bindEmailMarkAction) {  //若是绑定邮箱
        [[MGManager defaultManager] MGGetUserInfos];
    }
    
    [MGSVProgressHUD dismiss];
    [super viewWillDisappear:animated];
}

- (void) back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    bCanOpen = YES;
    [MGSVProgressHUD dismiss];
}

//- (void) webViewDidFinishLoad:(UIWebView *)webView{
//
//
//}

//- (void) webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
//{
//    [MGSVProgressHUD dismiss];
//    bCanOpen = NO;
//    [self performSelector:@selector(wait5s:) withObject:webView.request.URL afterDelay:4.0];
//}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    if (([error.localizedDescription isEqualToString:@"未能完成操作。"])||error.code == -999) {
        
        return;
        
    }else {
          [MGSVProgressHUD dismiss];
            bCanOpen = NO;
        [self performSelector:@selector(wait5s:) withObject:nil afterDelay:4.0];
    }
}

- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    if (([error.localizedDescription isEqualToString:@"未能完成操作。"])||error.code == -999) {
        
        return;
        
    }else {
         [MGSVProgressHUD dismiss];
                 bCanOpen = NO;
        [self performSelector:@selector(wait5s:) withObject:nil afterDelay:4.0];
    }
    
}

- (void) wait5s:(id)sender
{
    if (!bCanOpen) {
        //        [[[UIAlertView alloc] initWithTitle:@"邮箱打开失败" message:@"请使用其他方式打开邮箱进行绑定验证" delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil, nil] show];
        MGAlertCustomView *alerView = [[MGAlertCustomView alloc]alerViewWithMessige:@"邮箱打开失败,请使用其他方式打开邮箱进行绑定验证" withType:AlertTypeWithSure];
        __weak typeof(alerView) weakalert = alerView;
        alerView.handler = ^(NSInteger index){
            if (index == 1) {
                [weakalert dissmiss];
            }
        };
        [alerView show];
    }
}


#pragma mark -
#pragma mark UIWebViewDelegate
//- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType
//{
//
//    NSString *url = [[request URL] absoluteString];
//
//    if ([url hasPrefix:@"MGzsapp"]){
//
//        NSArray *coms = [url componentsSeparatedByString:@":"];
//        if ([coms count] >= 1) {
//
//            NSString *staus = [coms objectAtIndex:1];
//            if ([staus isEqualToString:@"success"]) {
//
//                [self backToRoot];
//
//            }else if ([staus isEqualToString:@"fail"] || [staus isEqualToString:@"retry"]){
//
//                [[[UIAlertView alloc] initWithTitle:@"密码重置失败" message:@"建议使用其他方式打开邮箱重试" delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil, nil] show];
//            }
//        }
//        return NO;
//    }
//    else
//        return YES;
//}


// 在发送请求之前，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {


    NSString* reqUrl = navigationAction.request.URL.absoluteString;

    NSArray *Cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    
    
        for (NSHTTPCookie *cookie in Cookies) {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
        }
    
        if ([reqUrl hasPrefix:@"MGzsapp"]) {
            NSArray *coms = [reqUrl componentsSeparatedByString:@":"];
            if ([coms count] >= 1) {
                
                NSString *staus = [coms objectAtIndex:1];
                if ([staus isEqualToString:@"success"]) {
                    
                    [self backToRoot];
                    
                }else if ([staus isEqualToString:@"fail"] || [staus isEqualToString:@"retry"]){
                    
                    [[[UIAlertView alloc] initWithTitle:@"密码重置失败" message:@"建议使用其他方式打开邮箱重试" delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil, nil] show];
                }
            }
    
            decisionHandler(WKNavigationActionPolicyCancel);
        }else {
           decisionHandler(WKNavigationActionPolicyAllow);
        }
 
}


- (void) backToRoot
{
    [self.navigationController popToRootViewControllerAnimated:NO];
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self performSelector:@selector(backToRoot) withObject:nil afterDelay:0.2];
}




/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
