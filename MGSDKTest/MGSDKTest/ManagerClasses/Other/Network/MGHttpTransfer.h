//
//  MGHttpTransfer.h
//  MGPlatformTest
//
//  Created by caosq on 14-6-10.
//  Copyright (c) 2014年 Eason. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Foundation/NSURLConnection.h>

typedef long MGHttpTransferIDRef;

@interface MGHttpTransfer : NSObject<NSURLSessionDelegate>
{
    NSMutableDictionary *_requestId_dic;
    NSMutableDictionary *_delegate_dic;
}

@property (nonatomic, assign) NSTimeInterval timeout;

- (MGHttpTransferIDRef) postData:(NSString *) url dataToPost:(NSData *) data delegate:(id) rDelegate;


- (void) postDataSync:(NSString *) url dataToPost:(NSData *) data didReceiveData:(void (^)(NSData *reveiveData, NSURLResponse *response, NSError *error)) rData;

@end



@protocol MGHttpTransferDelegate <NSObject>

@optional
- (void)transfer:(MGHttpTransferIDRef)connection didReceiveResponse:(NSURLResponse *)response;
- (void)transfer:(MGHttpTransferIDRef)connection didReceiveData:(NSData *) data;
- (void)transfer:(MGHttpTransferIDRef)connection didFailWithError:(NSError *)error;

@end
