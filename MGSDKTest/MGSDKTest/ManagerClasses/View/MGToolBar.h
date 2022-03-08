//
//  MGToolBar.h
//  MGPlatformTest
//
//  Created by caosq on 14-7-4.
//  Copyright (c) 2014年 qmqj. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MGToolBar;

typedef NS_ENUM(NSUInteger, MGToolBarItem){
    MGToolBarItem_UserCenter,
    MGToolBarItem_BBS
};


@protocol MGToolBarDelegate <NSObject>

- (void)showLeftView;


@end



@interface MGToolBar : UIView

@property (nonatomic, weak)id<MGToolBarDelegate> delegate;

@property (nonatomic, assign) MGToolBarPlace tbPlace;

@property (nonatomic, assign) CGRect currentFrame;

- (void) resetToolBarDirection;



@end
