//
//  MGToolBarParent.m
//  MGPlatformTest
//
//  Created by caosq on 14-7-11.
//  Copyright (c) 2014年 qmqj. All rights reserved.
//

#import "MGToolBarParent.h"
#import "MGToolBarLeftView.h"
#import "UIView+MGHandleFrame.h"
#import "MGToolBar.h"
#import <objc/runtime.h>
@interface MGToolBarParent ()<MGToolBarDelegate>

@property(nonatomic,assign) BOOL keyBoardlsVisible;


@end

@implementation MGToolBarParent

- (MGToolBarLeftView *)leftView {
    if (_leftView == nil) {
        if (I_PHONE_X) {
            _leftView  = [[MGToolBarLeftView alloc]initWithFrame:CGRectMake(-([UIScreen mainScreen].bounds.size.width * 0.5 + 30), 0,[UIScreen mainScreen].bounds.size.width * 0.5,[UIScreen mainScreen].bounds.size.height)];
        }else{
           _leftView  = [[MGToolBarLeftView alloc]initWithFrame:CGRectMake(-([UIScreen mainScreen].bounds.size.width * 0.5), 0,[UIScreen mainScreen].bounds.size.width * 0.5,[UIScreen mainScreen].bounds.size.height)];
        }
        
        [self addSubview:_leftView];
    }
    return _leftView;
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        
        self.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin| UIViewAutoresizingFlexibleHeight| UIViewAutoresizingFlexibleWidth;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetTransform:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
        
        [self resetTransform:nil];
        [self addObserverKeyBoard];

    }
    return self;
}
- (void)addObserverKeyBoard {
    _keyBoardlsVisible = NO;
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(keyboardwillShow) name:UIKeyboardWillShowNotification object:nil];
    [center addObserver:self selector:@selector(keyboardwillHide) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardwillShow
{
    _keyBoardlsVisible =YES;
}

- (void)keyboardwillHide
{
    _keyBoardlsVisible =NO;
}


- (void)showLeftView {
    
    [UIView animateWithDuration:0.25 animations:^{
        if (I_PHONE_X) {
          [self.leftView setOriginX:-30];
        }else {
          [self.leftView setOriginX:0];
        }
        
    }];
    
}



- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    [UIView animateWithDuration:0.25 animations:^{
        if (self.keyBoardlsVisible == YES) {
            [self.leftView endEditing:YES];
            return ;
            
        }
        else {
            if (I_PHONE_X) {
                [self.leftView setOriginX:-(_leftView.frame.size.width + 30)];
            }else{
                [self.leftView setOriginX:-(_leftView.frame.size.width)];
            }
        }

    }];
    
    
}
- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    
    UIView* __tmpView = [super hitTest:point withEvent:event];
    if (I_PHONE_X) {
        if (__tmpView == nil) {
          
           
            id a = self.leftView.webView.scrollView.subviews[0];
            
            CGPoint tempoint = [self.leftView.webView convertPoint:point fromView:self];
            if (CGRectContainsPoint(self.leftView.webView.bounds, tempoint)) {
                __tmpView = a;
                 return __tmpView;
            }
        }else
            if (__tmpView == self&&self.leftView.frame.origin.x <= -31) {
            return nil;
        }
        
    }else{
        if (__tmpView == self&&self.leftView.frame.origin.x <= -1) {
            return nil;
        }
    }
    
    return __tmpView;
}



- (void)viewSafeAreaInsetsDidChange {
//    [super viewSafeAreaInsetsDidChange];
//    if (@available(iOS 11.0, *)) {
//        UIEdgeInsets safe =  self.view.safeAreaInsets;
//        [self.view setOriginX:safe.left];
//    } else {
//        // Fallback on earlier versions
//    }
}

- (void) resetTransform:(id)sender
{
    if (IPHONE_8_UP) {
        
    }
    if (@available(iOS 11.0, *)) {
    self.layoutMargins = self.safeAreaInsets;
    }
//    CGRect frme = CGRectZero;
//    if (@available(iOS 11.0, *)) {
//        frme = CGRectMake(_clearWindow.maskView.safeAreaInsets.left, _clearWindow.maskView.safeAreaInsets.top, [UIScreen mainScreen].bounds.size.width - (_clearWindow.maskView.safeAreaInsets.left * 2), [UIScreen mainScreen].bounds.size.height - _clearWindow.maskView.safeAreaInsets.bottom - _clearWindow.maskView.safeAreaInsets.top);
//    } else {
//        frme = ;
//    }
    
    if ((IPHONE_8_UP) && (__IPHONE_OS_8_0)) {
        
    }else{
        
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
        
        CGSize size = [[UIScreen mainScreen] bounds].size;
        CGRect bounds = CGRectZero;
        if (orientation == UIInterfaceOrientationLandscapeLeft) {
            [self setTransform:CGAffineTransformMake(0, -1, 1, 0, 0, 0)];
            bounds.size.width = size.height;
            bounds.size.height = size.width;
        }else if (orientation == UIInterfaceOrientationLandscapeRight){
            [self setTransform:CGAffineTransformMake(0, 1, -1, 0, 0, 0)];
            bounds.size.height = size.width;
            bounds.size.width = size.height;
            
        }else if (orientation == UIInterfaceOrientationPortrait){
            self.transform = CGAffineTransformIdentity;
            bounds.size.height = size.height;
            bounds.size.width = size.width;
        }else if (orientation == UIInterfaceOrientationPortraitUpsideDown){
            
            self.transform = CGAffineTransformMake(-1, 0, -0, -1, 0, 0);
            bounds.size.height = size.height;
            bounds.size.width = size.width;
        }
        
        self.bounds = bounds;
    }
    
}


- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
