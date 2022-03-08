//
//  MGBindPhone.h
//  MGPlatformTest
//
//  Created by caosq on 14-7-3.
//  Copyright (c) 2014年 qmqj. All rights reserved.
//

#import "MGBaseViewController.h"
@class MGBind;

typedef NS_ENUM(NSInteger, MGBindType) {
    MGBindTypePhone     = 0,
    MGFindTypePhone     = 1
};


@protocol MGBindDelegate <NSObject>

- (void) MGBind:(MGBind *) bind bNeedReloadUserInfos:(BOOL) bReload;

@end



@interface MGBind : MGBaseViewController

- (instancetype) initWithBindType:(MGBindType) bindType;

@property (nonatomic, weak) id<MGBindDelegate> delegate;
@property (nonatomic, strong) NSString *account;
@property (nonatomic, setter = setQAndA:) NSDictionary *qAs;

@property(nonatomic,strong)NSString  *phone;
@property(nonatomic,strong)NSString  *email;
@property(nonatomic,copy)resultBlock Completion;
@end
