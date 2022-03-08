//
//  NSString+MGString.m
//  MGPlatformDemo
//
//  Created by Eason on 22/04/2014.
//  Copyright (c) 2014 Eason. All rights reserved.
//

#import "NSString+MGString.h"
#import <CommonCrypto/CommonDigest.h>

#ifndef _RFKit_RFARC_h_
#define _RFKit_RFARC_h_

#pragma mark -
#pragma mark ARC Compatible Macro

#if __has_feature(objc_arc)
#define RF_AUTORELEASE(exp) exp
#define RF_RELEASE(exp) exp
#define RF_RETAIN(exp) exp
#define RF_DEALLOC(exp) exp

#define RF_AUTORELEASE_OBJ(obj)
#define RF_RELEASE_OBJ(obj)
#define RF_RETAIN_OBJ(obj)
#define RF_DEALLOC_OBJ(obj)
#else
#define RF_AUTORELEASE(exp) [exp autorelease]
#define RF_RELEASE(exp) [exp release]
#define RF_RETAIN(exp) [exp retain]
#define RF_DEALLOC(exp) [exp dealloc]

#define RF_AUTORELEASE_OBJ(obj) [obj autorelease];
#define RF_RELEASE_OBJ(obj) [obj release];
#define RF_RETAIN_OBJ(obj) [obj retain];
#define RF_DEALLOC_OBJ(obj) [obj dealloc];
#endif

#ifndef RF_STRONG
#if __has_feature(objc_arc)
#define RF_STRONG strong
#else
#define RF_STRONG retain
#endif
#endif

#ifndef RF_WEAK
#if __has_feature(objc_arc_weak)
#define RF_WEAK weak
#elif __has_feature(objc_arc)
#define RF_WEAK unsafe_unretained
#else
#define RF_WEAK assign
#endif
#endif

#if !__has_feature(objc_arc)
#define RF_IF_NO_ARC
#define RF_IF_NO_ARC_END
#else
#define RF_IF_NO_ARC if (0) {
#define RF_IF_NO_ARC_END }
#endif

#pragma mark - GCD

#ifndef RF_dispatch_retain
#if OS_OBJECT_USE_OBJC
#define RF_dispatch_retain(expr)
#else
#define RF_dispatch_retain(expr) dispatch_retain(expr)
#endif
#endif

#ifndef RF_dispatch_release
#if OS_OBJECT_USE_OBJC
#define RF_dispatch_release(expr)
#else
#define RF_dispatch_release(expr) dispatch_release(expr)
#endif
#endif

#endif

@implementation NSString (MGString)

+ (NSString *)pinyinFromString:(NSString *)orgString {
  NSMutableString *string = [orgString mutableCopy];
  CFStringTransform((__bridge CFMutableStringRef)string, NULL,
                    kCFStringTransformMandarinLatin, NO);
  CFStringTransform((__bridge CFMutableStringRef)string, NULL,
                    kCFStringTransformStripDiacritics, NO);
  return RF_AUTORELEASE(string);
}

- (NSString *)reverseString {
  NSMutableString *reversedStr;
  NSUInteger len = [self length];

  // Auto released string
  reversedStr = [NSMutableString stringWithCapacity:len];

  // Probably woefully inefficient...
  while (len > 0)
    [reversedStr
        appendString:[NSString stringWithFormat:@"%C",
                                                [self characterAtIndex:--len]]];

  return reversedStr;
}

- (NSString *)stringTrimToWidthLength:(CGFloat)length WithFont:(UIFont *)font {
  NSString *tmp = self;
  CGFloat ctLength;
  NSUInteger charNumToRemove;
//  CGFloat aLetterWidthSafe = [@"汉" sizeWithFont:font].width * 1.5;
    CGFloat aLetterWidthSafe = [@"汉" sizeWithAttributes:@{NSFontAttributeName : font}].width * 1.5;
  bool trimed = false;

//  while ((ctLength = [tmp sizeWithFont:font].width) > length) {
     while ((ctLength = [tmp sizeWithAttributes:@{NSFontAttributeName : font}].width) > length) {
    charNumToRemove = (ctLength - length) / aLetterWidthSafe;
    if (charNumToRemove == 0) {
      charNumToRemove = 1;
    }
    tmp = [tmp substringToIndex:([tmp length] - charNumToRemove)];
    trimed = true;
  }

  return trimed ? [NSString stringWithFormat:@"%@...", tmp]
                : RF_AUTORELEASE([self copy]);
}

+ (NSString *)MD5String:(NSString *)string {
  // Borrowed from:
  // http://stackoverflow.com/questions/652300/using-md5-hash-on-a-string-in-cocoa
  const char *cStr = [string UTF8String];
  unsigned char result[CC_MD5_DIGEST_LENGTH];
  CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
  return [NSString
      stringWithFormat:
          @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
          result[0], result[1], result[2], result[3], result[4], result[5],
          result[6], result[7], result[8], result[9], result[10], result[11],
          result[12], result[13], result[14], result[15]];
}

+ (BOOL )stringIsEmpty:(NSString *)aString
{
    if ((NSNull *)aString == [NSNull null]) {
        return YES;
    }
    
    if (aString == nil) {
        return YES;
    } else if ([aString length] == 0) {
        return YES;
    } else {
        aString = [aString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if ([aString length] == 0) {
            return YES;
        }
    }
    
    return NO;
}

@end
