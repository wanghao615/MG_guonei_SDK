//
//  MGToolBar.m
//  MGPlatformTest
//
//  Created by caosq on 14-7-4.
//  Copyright (c) 2014年 qmqj. All rights reserved.
//

#import "MGToolBar.h"
#import "UIView+MGHandleFrame.h"
#define k_width (I_PHONE ? 43.0 : 64.0)
#define k_height (I_PHONE ? 43.0 : 64.0)
#define k_top_y 60.0

#define k_display_width  (I_PHONE ? 414.0/2 : 596.0/2)


typedef enum {
    MGToolBarLeft = 1,
    MGToolBarRight
}MGToolBarDirection;

typedef void(^GCDTask)(BOOL cancel);
typedef void(^gcdBlock)();

@interface MGToolBar()<MGToolBarDelegate>
{
    CGFloat popY_Precent;
    BOOL bAllowPan;
    
}

@property (nonatomic, strong) UIButton *btnTb;

@property (nonatomic, assign) MGToolBarDirection direction;

//当前的延迟隐藏
@property(nonatomic,strong)GCDTask currentGCDTask;

- (CGRect) defaultFrameByPlace:(MGToolBarPlace) place;

@end


@implementation MGToolBar



- (id)initWithFrame:(CGRect)frame
{
    _direction = MGToolBarLeft;
    frame = [self defaultFrameByPlace:MGToolBarAtTopLeft];
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
        [self initNormal];
        [self registerNotification];
        
        bAllowPan = YES;
        
    }
    return self;
}

- (CGSize) currentSize
{
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    
    
    CGSize size = [UIScreen mainScreen].bounds.size;
    if (I_PHONE_X) {
        size = CGSizeMake([UIScreen mainScreen].bounds.size.width - 60, [UIScreen mainScreen].bounds.size.height);
        return size;
    }
    else if ((IPHONE_8_UP) && (__IPHONE_OS_8_0)) {
        
        return size;
    }else {
        
        if (UIInterfaceOrientationIsLandscape(orientation)) {
            CGFloat w = size.width;
            size.width = size.height;
            size.height = w;
        }
        return size;
    }
}


// 根据 MGToolBarPlace 默认frame
- (CGRect) defaultFrameByPlace:(MGToolBarPlace) place
{
    CGFloat x,y;
    CGSize size = [self currentSize];
    switch (place) {
        case MGToolBarAtTopLeft:
            x = 0;
            y = k_top_y;
            break;
        case MGToolBarAtTopRight:
            x = size.width - k_width;
            
            y = k_top_y;
            break;
        case MGToolBarAtMiddleLeft:
            x = 0; y = (size.height - k_width/2)/2;
            break;
        case MGToolBarAtMiddleRight:
            x = size.width - k_width; y = (size.height - k_width/2)/2;
            break;
        case MGToolBarAtBottomLeft:
            x = 0.0; y = size.height - k_top_y - k_height ;
            break;
        case MGToolBarAtBottomRight:
            x = size.width - k_width; y = size.height - k_top_y - k_height;
            break;
            
        default:
            break;
    }
    
    return CGRectMake(x, y, k_width, k_width);
}

- (void) registerNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(positionToolBarX:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
    [self addGestureRecognizer:panGesture];
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //    [self removeObserver:self forKeyPath:@"alpha"];
}


- (void) positionToolBarX:(NSNotification *) noti
{
    if (self.direction == MGToolBarLeft) {
        
        CGRect frame = self.frame;
        frame.origin.x  = 0;
        self.frame = frame;
        
        self.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
        
        [MGStorage storeToolBarFrame:CGRectMake(frame.origin.x, frame.origin.y, k_width, k_height)];
        
    }else{
        
        CGRect frame = self.frame;
        CGSize size =  [self currentSize]; //  self.superview.bounds.size;
        frame.origin.x  = size.width - frame.size.width;
        self.frame = frame;
        self.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
        
        [MGStorage storeToolBarFrame:CGRectMake(size.width - k_width, frame.origin.y, k_width, k_height)];
        
    }
    self.alpha = 1;
    [self changBGImaage];
    
}

- (void) resetToolBarDirection
{
    [self changeToFrame:self.frame];
}



// pan gesture

- (CGRect) changeToFrame:(CGRect) oldFrame
{
    CGSize size =  [self currentSize];  // self.superview.bounds.size ; //  [self topView].bounds.size;
    CGRect frame;
    
    if (ceil((oldFrame.origin.x + oldFrame.size.width/2)) <= ceil(size.width/2)) {
        frame = CGRectMake(0, oldFrame.origin.y, oldFrame.size.width, oldFrame.size.height);
        self.direction = MGToolBarLeft;
//        if (I_PHONE_X) {
//            frame = CGRectMake(-44, oldFrame.origin.y, oldFrame.size.width, oldFrame.size.height);
//        }
    }else{  // 右边
        frame = CGRectMake(size.width - oldFrame.size.width, oldFrame.origin.y, oldFrame.size.width, oldFrame.size.height);
//        if (I_PHONE_X) {
//           frame = CGRectMake(size.width - oldFrame.size.width + 44, oldFrame.origin.y, oldFrame.size.width, oldFrame.size.height);
//        }
        self.direction = MGToolBarRight;
        //        self.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    }
    return frame;
}


- (void) setTbPlace:(MGToolBarPlace)tbPlace
{
    _tbPlace = tbPlace;
    
    if (_tbPlace == MGToolBarAtBottomLeft || _tbPlace == MGToolBarAtMiddleLeft || _tbPlace == MGToolBarAtTopLeft) {
        self.direction = MGToolBarLeft;
    }else
        self.direction = MGToolBarRight;
    
    self.frame = [self defaultFrameByPlace:_tbPlace];
    self.alpha = 1;
    [self changBGImaage];
}


- (void) initNormal
{
    _btnTb = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnTb.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    _btnTb.frame = CGRectMake(0, 0, k_width, k_height);
    [_btnTb setBackgroundImage:[MGUtility MGImageName:I_PHONE ? @"MG_toolbar_clear.png" : @"MG_toolbar_clear_pad.png"] forState:UIControlStateNormal];
    [_btnTb setBackgroundImage:[MGUtility MGImageName:I_PHONE ? @"MG_toolbar_clear.png" : @"MG_toolbar_clear_pad.png"] forState:UIControlStateHighlighted];
    
    [_btnTb addTarget:self action:@selector(showView) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:_btnTb];
    //     [self addObserver:self forKeyPath:@"alpha" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    
    //    NSNumber *alph =[change objectForKey:@"new"];
    //    if (alph.doubleValue > 0.5) {
    //
    //        [_btnTb setBackgroundImage:[MGUtility MGImageName:I_PHONE ? @"MG_toolbar_clear.png" : @"MG_toolbar_clear_pad.png"] forState:UIControlStateNormal];
    //    }else {
    //
    //        if (self.direction == MGToolBarLeft) {
    //            [_btnTb setBackgroundImage:[MGUtility MGImageName:I_PHONE ? @"MG_toolbar_right.png" : @"MG_toolbar_right.png"] forState:UIControlStateNormal];
    //
    //        }else {
    //             [_btnTb setBackgroundImage:[MGUtility MGImageName:I_PHONE ? @"MG_toolbar_left.png" : @"MG_toolbar_left.png"] forState:UIControlStateNormal];
    //        }
    //
    //    }
    
}

- (void)showView {
    
    [self showLeftView];
    
    self.alpha = 1.0;
    [self changBGImaage];
    CGRect frame = self.frame;
    self.frame = [self changeToFrame:frame];
    CGFloat x = 0;
    if (self.direction == MGToolBarLeft) {
        x = self.frame.origin.x - (k_width/2);
    }else {
        x = self.frame.origin.x + (k_width/2);
    }
    
    if (self.currentGCDTask != nil) {
        [self gcdCancel:self.currentGCDTask];
    }
    
    self.currentGCDTask  = [self gcdDelay:3.0 task:^{
        [UIView animateWithDuration:0.25 animations:^{
            
            
            self.alpha = 0.5;
            [self changBGImaage];
        }];
        [self setOriginX:x];
    }];
    
    
}

- (void)changBGImaage {
    if (self.alpha > 0.5) {
        
        [_btnTb setBackgroundImage:[MGUtility MGImageName:I_PHONE ? @"MG_toolbar_clear.png" : @"MG_toolbar_clear_pad.png"] forState:UIControlStateNormal];
    }else {
        
        if (self.direction == MGToolBarLeft) {
            [_btnTb setBackgroundImage:[MGUtility MGImageName:I_PHONE ? @"MG_toolbar_right.png" : @"MG_toolbar_right.png"] forState:UIControlStateNormal];
            
        }else {
            [_btnTb setBackgroundImage:[MGUtility MGImageName:I_PHONE ? @"MG_toolbar_left.png" : @"MG_toolbar_left.png"] forState:UIControlStateNormal];
        }
        
    }
}


- (CGRect) resizeFrameDisplayItems:(BOOL) bDisplay
{
    
    CGRect frame = self.frame;
    if (bDisplay) {
        
        if (self.direction == MGToolBarLeft) {
            
            frame.size.width =   k_display_width;
            frame.size.height = k_height;
        }else{
            frame.size.width = k_display_width;
            frame.size.height = k_height;
            frame.origin.x = [self currentSize].width - frame.size.width;
        }
        
    }else{
        
        if (self.direction == MGToolBarRight) {
            frame.origin.x =  [self currentSize].width - k_width;
        }
        frame.size.width = k_width;
        frame.size.height = k_height;
    }
    return frame;
}

- (void) panGesture:(UIGestureRecognizer *) gesture
{
    self.alpha = 1.0;
    [self changBGImaage];
    CGPoint point = [gesture locationInView:self.superview];
    if (point.y <= k_height/2) {
        point.y = k_height/2;
    }
    
    CGSize size = [self currentSize];
    if (point.y >= size.height - k_height/2) {
        point.y = size.height - k_height/2;
    }
    
    self.center = point;
    if (gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateCancelled) {
        
        CGRect frame = self.frame;
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
            self.frame = [self changeToFrame:frame];
        } completion:^(BOOL finished) {
            [MGStorage storeToolBarFrame:self.frame];
            [self dissmissAnimation];
        }];
    }
}

- (void)dissmissAnimation {
    
    
    
    CGRect frame = self.frame;
    self.frame = [self changeToFrame:frame];
    CGFloat x = 0;
    if (self.direction == MGToolBarLeft) {
        x = self.frame.origin.x - (k_width/2);
    }else {
        x = self.frame.origin.x + (k_width/2);
    }
    
    
    if (self.currentGCDTask != nil) {
        [self gcdCancel:self.currentGCDTask];
    }
    self.currentGCDTask  = [self gcdDelay:3.0 task:^{
        [UIView animateWithDuration:0.25 animations:^{
            
            
            self.alpha = 0.5;
            [self changBGImaage];
        }];
        [self setOriginX:x];
    }];
    
    
    
    
}

//- (UIView *) topView
//{
//    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
//    return [keyWindow.subviews firstObject];
//}





#pragma MARK -- Delegate
- (void)showLeftView {
    if ([self.delegate respondsToSelector:@selector(showLeftView)]) {
        [self.delegate showLeftView];
    }
}

#pragma MARK -- GCD

- (void)gcdLater:(NSTimeInterval)time block:(gcdBlock)block
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), block);
}

- (GCDTask)gcdDelay:(NSTimeInterval)time task:(gcdBlock)block
{
    __block dispatch_block_t closure = block;
    __block GCDTask result;
    GCDTask delayedClosure = ^(BOOL cancel){
        if (closure) {
            if (!cancel) {
                dispatch_async(dispatch_get_main_queue(), closure);
            }
        }
        closure = nil;
        result = nil;
    };
    result = delayedClosure;
    [self gcdLater:time block:^{
        if (result)
            result(NO);
    }];
    
    return result;
}

- (void)gcdCancel:(GCDTask)task
{
    task(YES);
}


@end
