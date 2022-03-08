//
//  MGToolBarLeftView.h
//  MGPlatformTest
//
//  Created by ZYZ on 2017/9/14.
//  Copyright © 2017年 MGzs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@protocol MGToolBarLeftViewDelegate <NSObject>


@end

@interface MGToolBarLeftView : UIView
@property(nonatomic,strong)WKWebView *webView;
- (void)refreshView;



@end
