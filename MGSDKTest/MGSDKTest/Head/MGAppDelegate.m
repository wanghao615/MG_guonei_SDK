//
//  MGAppDelegate.m
//  MGManagerTest
//
//  Created by Eason on 29/04/2014.
//  Copyright (c) 2014 . All rights reserved.
//

#import "MGAppDelegate.h"
#import "MGTestRootViewController.h"
#import "MGManager.h"


static NSString *const APP_ID = @"20";
static NSString *const APP_KEY = @"y6Se+mmV@^Z+LqD-";


@implementation MGAppDelegate

- (BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions
{
    
    
//    Class debugCls = NSClassFromString(@"UIDebuggingInformationOverlay");
//    [debugCls performSelector:NSSelectorFromString(@"prepareDebuggingOverlay")];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    MGTestRootViewController* testRootController = [[MGTestRootViewController alloc] init];
    [self.window setRootViewController:testRootController];
 

    [[MGManager defaultManager] initializeWithAppId:APP_ID appKey:APP_KEY  isContinueWhenCheckUpdateFailed:YES];
    /*! 设置 平台页面 屏幕方向
     * 1、其中设置的方向需要在 app plist文件Supported interface orientations 中支持，否则会Assert
     * 2、UIInterfaceOrientation, 设置 UIInterfaceOrientationLandscapeLeft 或者 UIInterfaceOrientationLandscapeRight，平台页面仅支持横屏幕。
     * 3、设置 UIInterfaceOrientationPortrait ，平台仅支持Portrait方向
     * 
     */
        [[MGManager defaultManager] MGSetScreenOrientation:UIInterfaceOrientationLandscapeLeft];


    //打印log到控制台， 设置方便查看日志，可不设置
    [[MGManager defaultManager] MGSetShowSDKLog:YES];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(MGplatformInitFinished:)
                                                 name:kMGPlatformInitDidFinishedNotification
                                               object:nil];

    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];

    
    
    
    return YES;
    
}

// init 回调
// 登录等其他sdk操作要等待该通知回调之后
- (void)MGplatformInitFinished:(NSNotification*)notification
{
    [[MGManager defaultManager] MGAutoLogin:0];
    
    
}





@end
