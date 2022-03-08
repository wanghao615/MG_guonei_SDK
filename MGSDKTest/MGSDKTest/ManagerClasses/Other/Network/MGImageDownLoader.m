//
//  MGImageDownLoader.m
//  MGPlatformTest
//
//  Created by caosq on 14-6-16.
//  Copyright (c) 2014年 Eason. All rights reserved.
//

#import "MGImageDownLoader.h"

@interface MGImageDownLoader()

//@property (nonatomic, strong) NSMutableArray *imageQueue;

@end

@implementation MGImageDownLoader

- (instancetype) init
{
    if (self = [super init]) {
        _MGImageQueue = dispatch_queue_create("com.mg.sdk.imagequeue", DISPATCH_QUEUE_CONCURRENT);
//        _imageQueue = [NSMutableArray new];
//        _imageDic = [NSMutableDictionary new];
    }
    return self;
}

- (void) dealloc
{
#if !OS_OBJECT_USE_OBJC
    dispatch_release(_MGImageQueue);
#endif
    _MGImageQueue = NULL;
}

- (void) downLoadImageWithUrl:(NSString *) imgUrl withTag:(NSInteger) tag completion:(void (^)(UIImage *image)) cBlock;
{
    __block NSString *_block_image_url = imgUrl;
//    __block NSInteger _block_tag = tag;

    NSUInteger cpuCount = [[NSProcessInfo processInfo] processorCount];
    dispatch_semaphore_t MG_semaphore = dispatch_semaphore_create(cpuCount * 2);
    NSString *extension = [[_block_image_url pathExtension] lowercaseString];
    if ([extension isEqualToString:@"jpg"] || [extension isEqualToString:@"png"]) {
        
        dispatch_semaphore_wait(MG_semaphore, DISPATCH_TIME_FOREVER);

        dispatch_async(_MGImageQueue, ^{

            NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:_block_image_url]];
            UIImage *decodeImage = [self decodedImageWithImage:[UIImage imageWithData:imgData]];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (cBlock) {
                    cBlock(decodeImage);
                }
                dispatch_semaphore_signal(MG_semaphore);
            });
        });
    }
}

- (UIImage *)decodedImageWithImage:(UIImage *)image {
    if (image.images) {
        // Do not decode animated images
        return image;
    }
    
    CGImageRef imageRef = image.CGImage;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imageRef), CGImageGetHeight(imageRef));
    CGRect imageRect = (CGRect){.origin = CGPointZero, .size = imageSize};
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
    
    int infoMask = (bitmapInfo & kCGBitmapAlphaInfoMask);
    BOOL anyNonAlpha = (infoMask == kCGImageAlphaNone ||
                        infoMask == kCGImageAlphaNoneSkipFirst ||
                        infoMask == kCGImageAlphaNoneSkipLast);
    
    // CGBitmapContextCreate doesn't support kCGImageAlphaNone with RGB.
    // https://developer.apple.com/library/mac/#qa/qa1037/_index.html
    if (infoMask == kCGImageAlphaNone && CGColorSpaceGetNumberOfComponents(colorSpace) > 1) {
        // Unset the old alpha info.
        bitmapInfo &= ~kCGBitmapAlphaInfoMask;
        
        // Set noneSkipFirst.
        bitmapInfo |= kCGImageAlphaNoneSkipFirst;
    }
    // Some PNGs tell us they have alpha but only 3 components. Odd.
    else if (!anyNonAlpha && CGColorSpaceGetNumberOfComponents(colorSpace) == 3) {
        // Unset the old alpha info.
        bitmapInfo &= ~kCGBitmapAlphaInfoMask;
        bitmapInfo |= kCGImageAlphaPremultipliedFirst;
    }
    
    // It calculates the bytes-per-row based on the bitsPerComponent and width arguments.
    CGContextRef context = CGBitmapContextCreate(NULL,
                                                 imageSize.width,
                                                 imageSize.height,
                                                 CGImageGetBitsPerComponent(imageRef),
                                                 0,
                                                 colorSpace,
                                                 bitmapInfo);
    CGColorSpaceRelease(colorSpace);
    
    // If failed, return undecompressed image
    if (!context) return image;
    
    CGContextDrawImage(context, imageRect, imageRef);
    CGImageRef decompressedImageRef = CGBitmapContextCreateImage(context);
    
    CGContextRelease(context);
    
    UIImage *decompressedImage = [UIImage imageWithCGImage:decompressedImageRef scale:image.scale orientation:image.imageOrientation];
    CGImageRelease(decompressedImageRef);
    return decompressedImage;
}




@end
