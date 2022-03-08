//
//  AppDelegate.m
//  MGSDKDemo
//
//  Created by ZYZ on 2017/10/22.
//  Copyright © 2017年 MG. All rights reserved.
//

#import "AppDelegate.h"
#import <AWSDK/MGManager.h>
#import "MGTestRootViewController.h"
@interface AppDelegate ()

@end


static NSString *const APP_ID = @"20";
static NSString *const APP_KEY = @"y6Se+mmV@^Z+LqD-";


@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
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
    [[MGManager defaultManager] MGSetScreenOrientation:UIInterfaceOrientationLandscapeRight];
    
    // 获取用户实名状态
    NSString *adultState = [[MGManager defaultManager] MGIDCardAdult];
    
    
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

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
