//
//  SqliteObjc.h
//  MGZB_DEMO_2
//
//  Created by caosq on 14-8-18.
//  Copyright (c) 2014年 qmqj. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MGUserDefault : NSObject

@end


@interface MGUserDefault(Convenience)

+ (MGUserDefault *) defaultUserDefaults;

- (void)setObject:(id)value forKey:(NSString *)defaultName;
- (void) setBoolValue:(BOOL)aBoolValue forKey:(NSString *) defaultName;
- (void) setIntVaule:(NSInteger)aIntValue forKey:(NSString *) defaultName;

//sqlite中该方法返回二进制
- (id) objectForKey:(NSString *)defaultName;
- (NSString *) stringValueForKey:(NSString *)defaultName;
- (BOOL) boolValueForKey:(NSString *) defaultName;
- (NSInteger) intValueForKey:(NSString *) defaultName;


- (void)removeObjectForKey:(NSString *)defaultName;

@end
