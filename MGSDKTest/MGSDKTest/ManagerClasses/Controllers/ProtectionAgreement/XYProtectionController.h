//
//  XYProtectionController.h
//  MGSDKTest
//
//  Created by 王浩2 on 2020/12/22.
//  Copyright © 2020 xyzs. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^AgreeStatusBlock)(BOOL agreeStatus);

@interface XYProtectionController : UIViewController

@property (nonatomic,copy)AgreeStatusBlock agreeStatus;

@end

NS_ASSUME_NONNULL_END
