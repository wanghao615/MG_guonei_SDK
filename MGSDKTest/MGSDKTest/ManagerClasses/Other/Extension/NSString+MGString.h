//
//  NSString+MGString.h
//  MGPlatformDemo
//
//  Created by Eason on 22/04/2014.
//  Copyright (c) 2014 Eason. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (MGString)

+ (NSString *)MD5String:(NSString *)string;

//! http://lldong.github.com/blog/2012/11/06/hanzi-to-pinyin/
//
+ (NSString *)pinyinFromString:(NSString *)orgString;

/** Reverse a NSString

 @return String reversed
 */
- (NSString *)reverseString;

/** 给定字体，屏幕长度，将字符串截断到指定长度

 这个方法不改变原始字符串
 @param length 屏幕长度
 @param font 计算所用字体
 @return 符合长度的字符串
 */
- (NSString *)stringTrimToWidthLength:(CGFloat)length WithFont:(UIFont *)font;

+ (BOOL )stringIsEmpty:(NSString *)aString;

@end
