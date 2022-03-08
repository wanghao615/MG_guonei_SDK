//
//  MGAlertCustomView.h
//  MGSDKTest
//
//  Created by ZYZ on 2017/12/22.
//  Copyright © 2017年 MG. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, AlertType) {
    AlertTypeWithSure,
    AlertTypeWithSureandCancel,
};

typedef void(^Handler)(NSInteger index);


@interface MGAlertCustomView : UIView

@property(nonatomic,strong)Handler handler;


- (instancetype)alerViewWithMessige:(NSString *)messige withType:(AlertType)type;

- (void)show;

- (void)dissmiss;

//- (void)resultHandel:(Handle)

@end
