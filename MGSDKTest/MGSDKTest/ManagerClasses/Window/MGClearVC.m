//
//  MGClearVC.m
//  MGPlatformTest
//
//  Created by 曹 胜全 on 14-7-29.
//  Copyright (c) 2014年 qmqj. All rights reserved.
//

#import "MGClearVC.h"

@interface MGClearView : UIView

@end

@implementation MGClearView


- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    UIView* __tmpView = [super hitTest:point withEvent:event];
    if (__tmpView == self) {
        return nil;
    }
    return __tmpView;
}

@end



@interface MGClearVC ()

@end

@implementation MGClearVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self.view setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

- (void) loadView
{
    MGClearView *v = [[MGClearView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self setView:v];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




- (BOOL) prefersStatusBarHidden
{
    return YES;
}


- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    UIInterfaceOrientation orien = [MGManager defaultManager].mInterfaceOrientation;
    
    NSInteger iOrien = orien;
    if (iOrien == UIInterfaceOrientationMaskAll) {
        
        return [self bInPlistOrientation:toInterfaceOrientation];
        
    }else{
        
        if (orien == UIInterfaceOrientationLandscapeLeft || orien == UIInterfaceOrientationLandscapeRight) {  // 横屏幕
            return UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
        }else
            return UIInterfaceOrientationIsPortrait(toInterfaceOrientation);
    }
}



- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    UIInterfaceOrientation orien = [MGManager defaultManager].mInterfaceOrientation;
    
    NSInteger iOrien = orien;
    if (iOrien == UIInterfaceOrientationMaskAll) {
        return [self interfaceOrientations];
        
        //        return UIInterfaceOrientationMaskAll;
        
    }else{
        
        if (orien == UIInterfaceOrientationLandscapeLeft || orien == UIInterfaceOrientationLandscapeRight) {
            return UIInterfaceOrientationMaskLandscape;
        }else
            return 1 << orien;
    }
}

- (NSUInteger) interfaceOrientations
{
    UIInterfaceOrientationMask mask;
    NSArray *oriens = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"UISupportedInterfaceOrientations"];
    mask = [self transformFromUIInterfaceOrientation:[oriens firstObject]];
    
    for (int i = 1; i < [oriens count]; i++) {
        mask |= [self transformFromUIInterfaceOrientation:[oriens objectAtIndex:i]];
    }
    return mask;
}

- (UIInterfaceOrientationMask) transformFromUIInterfaceOrientation:(NSString *) uiInterfaceOrientation
{
    if ([uiInterfaceOrientation isEqualToString:@"UIInterfaceOrientationPortrait"]) {
        return 1 << UIInterfaceOrientationPortrait;
    }else if ([uiInterfaceOrientation isEqualToString:@"UIInterfaceOrientationPortraitUpsideDown"]){
        return 1 << UIInterfaceOrientationPortraitUpsideDown;
    }else if ([uiInterfaceOrientation isEqualToString:@"UIInterfaceOrientationLandscapeLeft"]){
        return 1 << UIInterfaceOrientationLandscapeLeft;
    }else if ([uiInterfaceOrientation isEqualToString:@"UIInterfaceOrientationLandscapeRight"]){
        return 1 << UIInterfaceOrientationLandscapeRight;
    }else
        return 1;
}


- (BOOL) bInPlistOrientation:(UIInterfaceOrientation) orientation
{
    NSArray *oriens = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"UISupportedInterfaceOrientations"];
    
    NSString *orien_str;
    if (orientation == UIInterfaceOrientationPortrait) {
        orien_str = @"UIInterfaceOrientationPortrait";
    }else if (orientation == UIInterfaceOrientationPortraitUpsideDown){
        orien_str = @"UIInterfaceOrientationPortraitUpsideDown";
    }else if (orientation == UIInterfaceOrientationLandscapeLeft){
        orien_str = @"UIInterfaceOrientationLandscapeLeft";
    }else if (orientation == UIInterfaceOrientationLandscapeRight){
        orien_str = @"UIInterfaceOrientationLandscapeRight";
    }
    return [oriens containsObject:orien_str];
}



@end
