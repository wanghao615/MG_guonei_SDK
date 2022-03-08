//
//  MGHttpTransfer.m
//  MGPlatformTest
//
//  Created by caosq on 14-6-10.
//  Copyright (c) 2014年 Eason. All rights reserved.
//

#import "MGHttpTransfer.h"


@interface MGURLRequest : NSMutableURLRequest

@property (nonatomic, assign) MGHttpTransferIDRef tag;

@end

@implementation MGURLRequest
@end



@implementation MGHttpTransfer

static long _tag = 1;

- (instancetype) init
{
    self = [super init];
    if (self) {
        _requestId_dic = [NSMutableDictionary new];
        _delegate_dic = [NSMutableDictionary new];
        self.timeout = 120.0;
    }
    return self;
}

- (MGHttpTransferIDRef) generateIDRef
{
    return ++_tag;
}


- (void) postDataSync:(NSString *) url dataToPost:(NSData *) data didReceiveData:(void (^)(NSData *, NSURLResponse *, NSError *))rData
{
    MGURLRequest *request = [MGURLRequest requestWithURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:data];
    request.timeoutInterval = self.timeout;
    
//    NSURLResponse *response = nil;
//    NSError *error = nil;
//    NSData *httpData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
//    if (rData) {
//        rData(httpData, response, error);
//    }
    NSURLSession *seesion = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURLSessionDataTask *dataTask =[seesion dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data) {
            rData(data, response, error);
        }
    }];
    [dataTask resume];
}


- (MGHttpTransferIDRef) postData:(NSString * const) url dataToPost:(NSData *) data delegate:(id) rDelegate   // 主线程
{
    
    NSString *urlString= [NSString stringWithFormat:@"%@",url];
    
    NSString * encodedString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes( kCFAllocatorDefault, (CFStringRef)urlString, NULL, NULL,  kCFStringEncodingUTF8 ));
    
    NSURL *newUrl =[NSURL URLWithString:encodedString];
    
    MGURLRequest *request = [MGURLRequest requestWithURL:newUrl];
    
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:data];
    
    //    [request setValue:@"text/html;charset=utf-8"
    //     forHTTPHeaderField:@"Content-Type"];
    
    //    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    request.timeoutInterval = self.timeout;
//    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
//    [connection start];
    
    NSURLSession *session  = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration ] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *dataTsk = [session dataTaskWithRequest:request];
    [dataTsk resume];
    
    MGHttpTransferIDRef ID = [self generateIDRef];
    
    [_requestId_dic setObject:session forKey:[NSNumber numberWithLong:ID]];
    [_delegate_dic setObject:rDelegate forKey:[NSNumber numberWithDouble:ID]];
    return ID;
}

- (id) searchIdRefByConnection:(NSURLSession *) connection
{
    __block id theKey = nil;
    __weak NSURLSession *w_connection = connection;
    [_requestId_dic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        
        if ([obj isEqual:w_connection]) {
            theKey = key;
            *stop = YES;
        }
    }];
    return theKey;
}

- (id) findDelegateByConnection:(NSURLSession *) connection
{
    __block id theKey = nil;
    __weak NSURLSession *w_connection = connection;
    [_requestId_dic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        
        if ([obj isEqual:w_connection]) {
            theKey = key;
            *stop = YES;
        }
    }];
    return theKey ? _delegate_dic[theKey]: nil;
}

#pragma mark - NSURLSessionDataDelegate
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    id _ref = [self searchIdRefByConnection:session];
    id _delegate = _delegate_dic[_ref];
    if (_delegate && [_delegate respondsToSelector:@selector(transfer:didReceiveResponse:)]) {
        [_delegate transfer:[_ref longValue] didReceiveResponse:response];
    }
    
    completionHandler(NSURLSessionResponseAllow);
}
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    id _ref = [self searchIdRefByConnection:session];
    id _delegate = _delegate_dic[_ref];
    if (_delegate && [_delegate respondsToSelector:@selector(transfer:didReceiveData:)]) {
        [_delegate transfer:[_ref longValue] didReceiveData:data];
    }
    
    [self performSelectorOnMainThread:@selector(removeObjByKey:) withObject:_ref waitUntilDone:YES];
    
}
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    id _ref = [self searchIdRefByConnection:session];
    id _delegate = _delegate_dic[_ref];
    if (_delegate && [_delegate respondsToSelector:@selector(transfer:didFailWithError:)]) {
        [_delegate transfer:[_ref longValue] didFailWithError:error];
    }
    [self performSelectorOnMainThread:@selector(removeObjByKey:) withObject:_ref waitUntilDone:YES];
    
}


/* NSURLConnection代理方法
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    id _ref = [self searchIdRefByConnection:connection];
    id _delegate = _delegate_dic[_ref];
    if (_delegate && [_delegate respondsToSelector:@selector(transfer:didReceiveResponse:)]) {
        [_delegate transfer:[_ref longValue] didReceiveResponse:response];
    }
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    id _ref = [self searchIdRefByConnection:connection];
    id _delegate = _delegate_dic[_ref];
    if (_delegate && [_delegate respondsToSelector:@selector(transfer:didReceiveData:)]) {
        [_delegate transfer:[_ref longValue] didReceiveData:data];
    }
    
    [self performSelectorOnMainThread:@selector(removeObjByKey:) withObject:_ref waitUntilDone:YES];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    id _ref = [self searchIdRefByConnection:connection];
    id _delegate = _delegate_dic[_ref];
    if (_delegate && [_delegate respondsToSelector:@selector(transfer:didFailWithError:)]) {
        [_delegate transfer:[_ref longValue] didFailWithError:error];
    }
    [self performSelectorOnMainThread:@selector(removeObjByKey:) withObject:_ref waitUntilDone:YES];
}
*/
- (void) removeObjByKey:(id) key
{
    if (key != nil) {
        [_requestId_dic removeObjectForKey:key];
        [_delegate_dic removeObjectForKey:key];
    }
}




@end
