//
//  MGBindAlertView.h
//  MGSDKTest
//
//  Created by ZYZ on 2018/1/31.
//  Copyright © 2018年 MG. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^Handler)(NSInteger index);
typedef void(^closeSelf)();

@interface MGBindAlertView : UIView

@property(nonatomic,copy)Handler handler;
@property(nonatomic,copy)closeSelf closeSelf;




- (instancetype)alerViewWithMessige:(NSString *)messige;

- (void)show;

- (void)dissmiss;
@end
