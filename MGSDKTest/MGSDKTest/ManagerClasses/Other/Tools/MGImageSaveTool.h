//
//  MGImageSaveTool.h
//  MGSDKTest
//
//  Created by ZYZ on 2017/12/14.
//  Copyright © 2017年 MG. All rights reserved.
//

#import <Foundation/Foundation.h>
@class UIImage;
@class NSData;
@class PHAsset;





/**
 保存完成回调
 
 @param success YES:保存成功；NO:保存失败
 @param asset PHAsset,通过其可获取到已保存到相册中的图片
 */
typedef void (^SaveCompletion)(BOOL success,PHAsset *asset);


@interface MGImageSaveTool : NSObject
/*
 *是否有权限添加照片
 *
 */
+ (BOOL)isCanUsePhotos;

/**
 使用PhotoKit框架保存图片UIImage
 
 @param image 要保存的图片
 @param completion 完成回调
 */
+(void)saveImageWithPhotoKit:(UIImage*)image completion:(SaveCompletion)completion;


/**
 使用PhotoKit框架保存图片(原始数据NSData)
 
 @param data 要保存的图片data
 @param completion 完成回调
 */
+(void)saveImageDataWithPhotoKit:(NSData*)data completion:(SaveCompletion)completion;

@end
