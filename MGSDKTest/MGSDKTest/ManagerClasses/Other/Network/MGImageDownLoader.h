//
//  MGImageDownLoader.h
//  MGPlatformTest
//
//  Created by caosq on 14-6-16.
//  Copyright (c) 2014年 Eason. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MGImageDownLoader : NSObject
{
    dispatch_queue_t _MGImageQueue;
    
//    NSMutableArray *_imageQueue;
//    NSMutableDictionary *_imageDic;
}

- (void) downLoadImageWithUrl:(NSString *) imgUrl withTag:(NSInteger) tag completion:(void (^)(UIImage *image)) cBlock;


@end
