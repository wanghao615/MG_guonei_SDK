/**********************************************************\
|                                                          |
| MGXXTEA.h                                                  |
|                                                          |
| MGXXTEA encryption algorithm library for Objective-C.      |
|                                                          |
| Encryption Algorithm Authors:                            |
|      David J. Wheeler                                    |
|      Roger M. Needham                                    |
|                                                          |
| Code Authors: Chen fei <cf850118@163.com>                |
|               Ma Bingyao <mabingyao@gmail.com>           |
| LastModified: Mar 10, 2015                               |
|                                                          |
\**********************************************************/

#import <Foundation/Foundation.h>

@interface MGXXTEA : NSObject

+ (NSData *) MGencrypt:(NSData *)data key:(NSData *)key;
+ (NSData *) MGencrypt:(NSData *)data stringKey:(NSString *)key;

+ (NSString *) MGencryptToBase64String:(NSData *)data key:(NSData *)key;
+ (NSString *) MGencryptToBase64String:(NSData *)data stringKey:(NSString *)key;

+ (NSData *) MGencryptString:(NSString *)data key:(NSData *)key;
+ (NSData *) MGencryptString:(NSString *)data stringKey:(NSString *)key;

+ (NSString *) MGencryptStringToBase64String:(NSString *)data key:(NSData *)key;
+ (NSString *) MGencryptStringToBase64String:(NSString *)data stringKey:(NSString *)key;

+ (NSData *) MGdecrypt:(NSData *)data key:(NSData *)key;
+ (NSData *) MGdecrypt:(NSData *)data stringKey:(NSString *)key;

+ (NSData *) MGdecryptBase64String:(NSString *)data key:(NSData *)key;
+ (NSData *) MGdecryptBase64String:(NSString *)data stringKey:(NSString *)key;

+ (NSString *) MGdecryptToString:(NSData *)data key:(NSData *)key;
+ (NSString *) MGdecryptToString:(NSData *)data stringKey:(NSString *)key;

+ (NSString *) MGdecryptBase64StringToString:(NSString *)data key:(NSData *)key;
+ (NSString *) MGdecryptBase64StringToString:(NSString *)data stringKey:(NSString *)key;

@end

@interface NSData (MGXXTEA)

- (NSData *) MGxxteaEncrypt:(NSData *)key;
- (NSData *) MGxxteaDecrypt:(NSData *)key;

@end
