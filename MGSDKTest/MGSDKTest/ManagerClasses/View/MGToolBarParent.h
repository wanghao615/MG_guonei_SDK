//
//  MGToolBarParent.h
//  MGPlatformTest
//
//  Created by caosq on 14-7-11.
//  Copyright (c) 2014年 qmqj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGToolBar.h"
@class MGToolBarLeftView;
@interface MGToolBarParent : UIView <MGToolBarDelegate>

@property (nonatomic, strong) MGToolBarLeftView *leftView;

@end
