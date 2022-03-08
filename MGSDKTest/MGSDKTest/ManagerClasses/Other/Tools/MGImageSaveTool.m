//
//  MGImageSaveTool.m
//  MGSDKTest
//
//  Created by ZYZ on 2017/12/14.
//  Copyright © 2017年 MG. All rights reserved.
//

#import "MGImageSaveTool.h"
#import <Photos/Photos.h>
//PHAuthorizationStatusNotDetermined = 0, // 默认还没做出选择
//PHAuthorizationStatusRestricted,        // 此应用程序没有被授权访问的照片数据
//PHAuthorizationStatusDenied,            // 用户已经明确否认了这一照片数据的应用程序访问
//PHAuthorizationStatusAuthorized         //  用户已经授权应用访问照片数据
@implementation MGImageSaveTool



+ (BOOL)isCanUsePhotos {
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusRestricted ||
        status == PHAuthorizationStatusDenied||status == PHAuthorizationStatusNotDetermined) {
        return NO;
    }
    return YES;
}



// 通过PhotoKit保存图片(原始数据NSData)
+(void)saveImageDataWithPhotoKit:(NSData*)data completion:(SaveCompletion)completion{
    [self p_saveDataWithPhtotoKit:data completion:completion];
}

// 通过PhotoKit保存图片(UIImage)
+(void)saveImageWithPhotoKit:(UIImage*)image completion:(SaveCompletion)completion{
    [self p_saveDataWithPhtotoKit:image completion:completion];
}


/**
 通过PhtotoKit保存图片，根据传入data的类型进行不同处理
 
 @param data 图片数据，可为UIImage/NSData类型
 @param completion 完成回调
 */
+(void)p_saveDataWithPhtotoKit:(id)data completion:(SaveCompletion)completion{
    // 判断数据是否有效：data必须为NSData 或者 UIImage类
    BOOL dataValid = data && ([data isKindOfClass:NSData.class]||[data isKindOfClass:UIImage.class]);
    if (!dataValid) {
        completion(NO,nil);
        return;
    }
    __block NSString* localIdentifier;
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        PHAssetCreationRequest *createRequest = nil;
        if ([data isKindOfClass:NSData.class]) {
            PHAssetResourceCreationOptions *options = [[PHAssetResourceCreationOptions alloc] init];
            createRequest = [PHAssetCreationRequest creationRequestForAsset];
            [createRequest addResourceWithType:PHAssetResourceTypePhoto data:data options:options];
        }else{
            createRequest = [PHAssetCreationRequest creationRequestForAssetFromImage:data];
        }
        
        localIdentifier = createRequest.placeholderForCreatedAsset.localIdentifier;
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        if (success && localIdentifier) {
            //成功后取相册中的图片对象
            PHFetchResult *result = [PHAsset fetchAssetsWithLocalIdentifiers:@[localIdentifier] options:nil];
            PHAsset* asset = [result firstObject];
            completion(success,asset);
        }else{
            completion(success,nil);
        }
        
    }];
}
@end
