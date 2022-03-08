//
//  MGPullDown.h
//  MGPlatformTest
//
//  Created by caosq on 14-7-3.
//  Copyright (c) 2014年 qmqj. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MGPullDown;

@protocol MGPullDownDelegate <NSObject>

- (void) MGPullDown:(MGPullDown *) pulldown selectedItem:(id) item;

- (void) MGPullDown:(MGPullDown *)pulldown removeItem:(id)item;

@end


@interface MGPullDown : UITableViewController

@property (nonatomic, assign) CGFloat rowHeight;

@property (nonatomic, strong) NSArray *pulldownLists;

@property (nonatomic, weak) id<MGPullDownDelegate> delegate;

//- (void) presentPullDownFromRect:(CGRect) rect inView:(UIView *) view;

- (void) presentPullDownFromRect:(CGRect) rect inView:(UIView *) view;

- (void) presentPullDownFromView:(UIView *) fromView inView:(UIView *) view;

/**
 *  添加下拉pullDown到目标view的rect中
 *
 *  @param rect pullDown所在的Rect坐标系
 *  @param view pulld将要add的superView
 */
- (void)presentPullDownToRect:(CGRect)rect inView:(UIView *)view;

- (CGRect)calculateRectWith:(CGRect)rect inView:(UIView *)view;

- (void)dismissPullDown;

@property (nonatomic, assign) BOOL bShowCancelActionButton;

@property (nonatomic, copy) NSString *realAccountStr;

@end
