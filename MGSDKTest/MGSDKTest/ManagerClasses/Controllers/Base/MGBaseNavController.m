//
//  MGBaseNavController.m
//  MGPlatformDemo
//
//  Created by Eason on 21/04/2014.
//  Copyright (c) 2014 Eason. All rights reserved.
//

#import "MGBaseNavController.h"

@interface MGBaseNavController ()
{
    BOOL statusBarHidden;
}

@end

@implementation MGBaseNavController


- (BOOL) prefersStatusBarHidden
{
    return YES;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    statusBarHidden = [UIApplication sharedApplication].statusBarHidden;
    if (!statusBarHidden) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    }
}

- (void) viewWillDisappear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:statusBarHidden withAnimation:UIStatusBarAnimationNone];
    [super viewWillDisappear:animated];
}




- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    UIInterfaceOrientation orien = [MGManager defaultManager].mInterfaceOrientation;
    
    NSInteger iOrien = orien;
    if (iOrien == UIInterfaceOrientationMaskAll) {
        
        BOOL bIn = [self bInPlistOrientation:toInterfaceOrientation];
        return bIn;
        
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
        BOOL bin = [self interfaceOrientations];

        return bin;
        
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
