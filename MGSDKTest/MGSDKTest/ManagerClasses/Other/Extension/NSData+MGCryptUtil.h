//
//  NSData+MGCryptUtil.h
//  MGManagerTest
//
//  Created by caosq on 14-6-23.
//  Copyright (c) 2014年 qmqj. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CommonCrypto/CommonCryptor.h>  


@interface NSData (MGCryptUtil)

- (NSData*)AES256EncryptWithKey:(NSString*)key;

- (NSData*)AES256DecryptWithKey:(NSString*)key;

@end


@interface NSString (MGCryptUtil)

+ (NSData*)AES256Encrypt:(NSString*)strSource withKey:(NSString*)key;

+ (NSString*)AES256Decrypt:(NSData*)dataSource withKey:(NSString*)key;


@end
