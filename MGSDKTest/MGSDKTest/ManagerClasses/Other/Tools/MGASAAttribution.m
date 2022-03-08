//
//  MGASAAttribution.m
//  MGSDKTest
//
//  Created by admin on 2021/9/1.
//  Copyright © 2021 xyzs. All rights reserved.
//

#import "MGASAAttribution.h"
#import <AppTrackingTransparency/AppTrackingTransparency.h>
#import <iAd/iAd.h>
#import <AdServices/AdServices.h>
#import "MGNetworkReachabilityManager.h"
#import "MGStatistics.h"
#import "MGHttpClient.h"

@implementation MGASAAttribution


/// 请求ATT权限，回调后再进行归因操作
+(void)requestTrackingAuthorization{
    if (@available(iOS 14, *)) {
        [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
            [self listenNetWorkingStatus];
        }];
    } else {
        [self listenNetWorkingStatus];
    }
}


/// 创建网络监听者，在有网络情况下进行ASA归因操作
+(void)listenNetWorkingStatus{
    MGNetworkReachabilityManager *manager = [MGNetworkReachabilityManager sharedManager];
    [manager setReachabilityStatusChangeBlock:^(MGNetworkReachabilityStatus status) {
        if(status == MGNetworkReachabilityStatusReachableViaWWAN || status == MGNetworkReachabilityStatusReachableViaWiFi){
            [self asaAttribution];
        }
    }];

    //开启网络监听
    [manager startMonitoring];
}


/// 获取token或归因数据，需要保证联网的情况下进行
/// 1.判断是否已经上传
/// 2.获取token，上传至app后台
/// 3.获取token失败，直接获取归因数据，上传至app后台
+(void)asaAttribution{
    //判断token或归因数据是否已经上传，防止重复上传
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    BOOL isUploaded = [ud boolForKey:@"is_asa_uploaded"];
    if(isUploaded){
        return;
    }

    //获取token
    NSString *token;
    if (@available(iOS 14.3, *)) {
        NSError *error;
        token = [AAAttribution attributionTokenWithError:&error];
    }
    if(token != nil){
        //通过token请求苹果api获取归因数据，然后将归因数据与设备id一起上传到app后台
        //也可将token直接上传给app后台，由app后台请求苹果api获取归因数据
        //上传成功后，需要缓存成功记录，防止重复归因；失败则根据错误信息进行容错处理。
        [self attributionWithToken:token];
        return;
    }

    //token获取失败则直接获取旧方案的归因数据
    Boolean attributionEnable = true;
    if (@available(iOS 14, *)) {
        ATTrackingManagerAuthorizationStatus status = [ATTrackingManager trackingAuthorizationStatus];
        attributionEnable = status == ATTrackingManagerAuthorizationStatusNotDetermined || status == ATTrackingManagerAuthorizationStatusAuthorized;
        if (@available(iOS 14.5, *)) {
            attributionEnable = status == ATTrackingManagerAuthorizationStatusAuthorized;
        }
    }

    if(attributionEnable){
        if([[ADClient sharedClient]respondsToSelector:@selector(requestAttributionDetailsWithBlock:)]){
            [[ADClient sharedClient]requestAttributionDetailsWithBlock:^(NSDictionary<NSString *,NSObject *> * _Nullable attributionDetails, NSError * _Nullable error) {

                if(attributionDetails != nil){
                    for(NSString* key in attributionDetails){
                        if([key hasPrefix:@"Version"]){
                            //将归因数据和设备id上传至app后台
                            //上传成功后，需要缓存成功记录，防止重复归因；失败则根据错误信息进行容错处理。
                            [[MGHttpClient shareMGHttpClient]statisticsDanaToken:@"" asaData:attributionDetails ASACompletion:^(NSDictionary *responseDic) {
                                
                                    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
                                    [ud setBool:YES forKey:@"is_asa_uploaded"];
                                    [ud synchronize];
                                    
                                } failed:^(NSInteger ret, NSString *errMsg) {
                                    
                                    
                                }];
                         
                            
//                            return;
                        }
                    }
                }

            }];
        }
    }

}

/// 通过token获取归因数据
/// @param token token
+ (void) attributionWithToken:(NSString *)token {
    NSURLSession *session = [NSURLSession sharedSession];
    NSURL *url = [NSURL URLWithString:@"https://api-adservices.apple.com/api/v1/"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    NSData* postData = [token dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:postData];
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSInteger resultCode = ((NSHTTPURLResponse*)response).statusCode;
        if(resultCode == 200){
            NSError *resError;
            NSMutableDictionary *resDic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&resError];
            if ([resDic isKindOfClass:[NSDictionary class]] && resDic.allKeys>0) {
                
                [[MGHttpClient shareMGHttpClient]statisticsDanaToken:token asaData:resDic ASACompletion:^(NSDictionary *responseDic) {
                    
                        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
                        [ud setBool:YES forKey:@"is_asa_uploaded"];
                        [ud synchronize];
                    
                    } failed:^(NSInteger ret, NSString *errMsg) {
                        
                    }];
                
            }
            
           
            
//            NSLog(@"%@====",resDic);
            //将归因数据和设备id上传至app后台，
            //在上传成功后，需要缓存成功记录，防止重复归因；失败则根据错误信息做容错处理
        }
    }];
    [postDataTask resume];
}

@end
