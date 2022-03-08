//
//  MGAlertViewRootVC.m
//  MGPlatformTest
//
//  Created by wangcl on 14-8-22.
//  Copyright (c) 2014年 qmqj. All rights reserved.
//

#import "MGAlertViewRootVC.h"
#import "UIView+MGHandleFrame.h"
#import "MGIdentityVerificationAlertView.H"


#define kDialogFooterHeight                         30.f
#define kButtonsCrossHeight                         10.f


#define kButtonTagStart                             100000

@interface MGAlertViewRootVC ()


@property (nonatomic, strong) UIView *dialogView;

@end


@implementation MGAlertViewRootVC

@synthesize buttonTitles, containerView, dialogView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.6]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)startShow {
    
    dialogView = [self createContainerView];
    dialogView.clipsToBounds = YES;
    dialogView.layer.shouldRasterize = YES;
    dialogView.layer.rasterizationScale = [UIScreen mainScreen].scale;
    dialogView.layer.opacity = 0.5f;
    dialogView.layer.transform = CATransform3DMakeScale(1.3, 1.3, 1.0);
    
    self.view.layer.shouldRasterize = YES;
    self.view.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
    self.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    [self.view addSubview:dialogView];
    [UIView animateWithDuration:.2f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.4f];
        dialogView.layer.opacity = 1.0f;
        dialogView.layer.transform = CATransform3DMakeScale(1, 1, 1);
    } completion:^(BOOL finished) {
        
    }];
}

- (UIView *)createContainerView {
    CGSize screenSize = [self countScreenSize];
    CGSize dialogSize = [self countDialogSize];
    if (containerView == nil) {
        containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, dialogSize.width, 150)];
    }
    UIView *dialogContainer = [[UIView alloc] initWithFrame:CGRectMake((screenSize.width - dialogSize.width) / 2, (screenSize.height - dialogSize.height) / 2, dialogSize.width, dialogSize.height)];
    [dialogContainer setBackgroundColor:[UIColor clearColor]];
    dialogContainer.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin |
                                      UIViewAutoresizingFlexibleRightMargin |
                                        UIViewAutoresizingFlexibleTopMargin |
                                      UIViewAutoresizingFlexibleBottomMargin;
    
    UIImageView *backImageView = [[UIImageView alloc] initWithImage:[[MGUtility MGImageName:@"MG_alertview_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)]];
    backImageView.frame = dialogContainer.bounds;
    backImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [dialogContainer insertSubview:backImageView atIndex:0];
    
    [dialogContainer addSubview:containerView];
    
    [self addButtonsToView:dialogContainer];

    return dialogContainer;
}

- (void)addButtonsToView:(UIView *)dialogTempView {
    CGFloat b_h = I_PAD ? 50.0 : 42.0;
    CGFloat x = 20.f;
    CGFloat y = self.containerView.frame.size.height;
    UIFont *font =  I_PAD ? [UIFont systemFontOfSize:17] : [UIFont systemFontOfSize:15];
    for (int i = 0; i < self.buttonTitles.count; i ++) {
        UIButton *btn = [MGUtility newBlueButton:CGRectMake(x, y, [self countDialogSize].width - 2 * x, b_h) withTitle:buttonTitles[i] target:self action:@selector(buttonClicked:)];
        btn.titleLabel.font = font;
        [btn setTag:i + kButtonTagStart];
        if (i == self.buttonTitles.count - 1 && self.buttonTitles.count != 1) {
            [btn setBackgroundImage:[[MGUtility MGImageName:@"MG_btn_gray.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(8, 8, 8, 8) ] forState:UIControlStateNormal];
        }
        
        [dialogTempView addSubview:btn];
        y += b_h + 10.0;
    }
}

- (CGSize)countDialogSize
{
    CGFloat dialogWidth = kDialogViewWidthPhone;
    if (TT_IS_IPAD) {
        dialogWidth = kDialogViewWidthPad;
    }
    CGFloat b_h = I_PAD ? 50.0 : 42.0;
    CGFloat dialogHeight = .0f;
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (UIInterfaceOrientationIsLandscape(interfaceOrientation) && self.shouldUpdateButtonsUIWhenLandscape && TT_IS_IPHONE) {
        dialogHeight = containerView.frame.size.height + b_h  + kDialogFooterHeight;
    } else {
        dialogHeight = containerView.frame.size.height + b_h * self.buttonTitles.count + kButtonsCrossHeight * (self.buttonTitles.count - 1) + kDialogFooterHeight;
    }
    return CGSizeMake(dialogWidth, dialogHeight);
}


- (CGSize)countScreenSize {
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    /*
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
        CGFloat tmp = screenWidth;
        screenWidth = screenHeight;
        screenHeight = tmp;
    }
    */
    return CGSizeMake(screenWidth, screenHeight);
}

- (void)getTextFieldsValue {
    UITextField *tfFirst = (UITextField *)[self.view viewWithTag:kDialogFirstTextFieldTag];
    UITextField *tfSec = (UITextField *)[self.view viewWithTag:kDialogSecTextFieldTag];
    NSMutableArray *tempArr = [NSMutableArray array];
    if (tfFirst && tfFirst.text) {
        [tempArr addObject:tfFirst.text];
    } else {
        [tempArr addObject:@""];
    }
    if (tfSec && tfSec.text) {
        [tempArr addObject:tfSec.text];
    } else {
        [tempArr addObject:@""];
    }
    _dialogAlert.textFieldsTexts = [NSArray arrayWithArray:tempArr];
}

- (void)buttonClicked:(UIButton *)sender {
    [self.view endEditing:YES];
    [self getTextFieldsValue];
    
    if ([_dialogAlert isKindOfClass:[MGShowTipsView class]]) {
        if (_dialogAlert.alertDelegate && [_dialogAlert.alertDelegate respondsToSelector:@selector(MGDialogAlertView:clickedButtonAtIndex:)]) {
            [_dialogAlert.alertDelegate MGDialogAlertView:_dialogAlert clickedButtonAtIndex:sender.tag - kButtonTagStart];
        }
    }else{
        //身份验证
           MGIdentityVerificationAlertView *IDNumAlertView  = (MGIdentityVerificationAlertView *)_dialogAlert;
        if (IDNumAlertView.alertDelegate && [IDNumAlertView.alertDelegate respondsToSelector:@selector(MGIdentityVerificationAlertView:clickedButtonAtIndex:)]) {
            [IDNumAlertView.alertDelegate MGIdentityVerificationAlertView:IDNumAlertView clickedButtonAtIndex:sender.tag - kButtonTagStart];
        }
    }
    
    
    if (_dialogAlert.onButtonTouchInside) {
        _dialogAlert.onButtonTouchInside(_dialogAlert, sender.tag - kButtonTagStart);
    }
}

- (void)containerViewEndEditing {
    [self getTextFieldsValue];
    
    if ([_dialogAlert isKindOfClass:[MGShowTipsView class]]) {
        if (_dialogAlert.alertDelegate && [_dialogAlert.alertDelegate respondsToSelector:@selector(MGDialogAlertviewEndTextFieldsEditing:)]) {
            [_dialogAlert.alertDelegate MGDialogAlertviewEndTextFieldsEditing:_dialogAlert];
        }
    }else{
        //身份验证
        MGIdentityVerificationAlertView *IDNumAlertView  = (MGIdentityVerificationAlertView *)_dialogAlert;
        if (IDNumAlertView.alertDelegate && [IDNumAlertView.alertDelegate respondsToSelector:@selector(MGIdentityVerificationAlertViewEndTextFieldsEditing:)]) {
            [IDNumAlertView.alertDelegate MGIdentityVerificationAlertViewEndTextFieldsEditing:IDNumAlertView];
        }
    }
    
}

- (void)dismissView {
    [UIView animateWithDuration:0.2f delay:0 options:UIViewAnimationOptionTransitionNone animations:^{
        self.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    } completion:^(BOOL finished) {
        for (UIView *view in [self.view subviews]) {
            [view removeFromSuperview];
        }
        [self.view removeFromSuperview];
        [self.dialogAlert setHidden:YES];
        [self.dialogAlert removeFromSuperview];                
    }];
}

#pragma mark - Keyboard Notification

- (void)keyboardWillShow:(NSNotification *)notification {
    
    CGSize screenSize = [self currentSize];
    CGSize dialogSize = [self countDialogSize];
    CGRect rect = CGRectZero;
    CGFloat b_h = I_PAD ? 50.0 : 42.0;
    if (self.shouldUpdateButtonsUIWhenLandscape) {
        b_h += 15;
    }
    if (iPhone_P) {
        rect = CGRectMake((screenSize.width - dialogSize.width) / 2, (screenSize.height - dialogSize.height) / 2 - (b_h + 10), dialogSize.width, dialogSize.height);
    } else if (iPhone_L) {
        rect = CGRectMake((screenSize.width - dialogSize.width) / 2, (screenSize.height - dialogSize.height) / 2 - (b_h + 15 + 34), dialogSize.width, dialogSize.height);
    } else if (iPad_P) {
        return;
    } else if (iPad_L) {
        rect = CGRectMake((screenSize.width - dialogSize.width) / 2, (screenSize.height - dialogSize.height) / 2 - (b_h + 15 + 34), dialogSize.width, dialogSize.height);
    }
    [UIView animateWithDuration:.2f animations:^{
        dialogView.frame = rect;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification {

    CGSize screenSize = [self currentSize];
    CGSize dialogSize = [self countDialogSize];
    CGRect rect = CGRectZero;
    if (iPhone_P) {
        rect = CGRectMake((screenSize.width - dialogSize.width) / 2, (screenSize.height - dialogSize.height) / 2, dialogSize.width, dialogSize.height);
    } else if (iPhone_L) {
        rect = CGRectMake((screenSize.width - dialogSize.width) / 2, (screenSize.height - dialogSize.height) / 2, dialogSize.width, dialogSize.height);
    } else if (iPad_P) {
        return;
    } else if (iPad_L) {
        rect = CGRectMake((screenSize.width - dialogSize.width) / 2, (screenSize.height - dialogSize.height) / 2, dialogSize.width, dialogSize.height);
    }
    [UIView animateWithDuration:.2f animations:^{
        dialogView.frame = rect;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    } else {
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
    }
    [super viewWillAppear:animated];
    
}


- (BOOL)prefersStatusBarHidden {
    
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

#pragma mark - 转屏布局

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self resizeUI];
}

- (void)resizeUI {
    if (iPhone_L) {
        [self resizeWhenLandscape];
    }else if (iPhone_P){
        [self resizeWhenPortrait];
    }else if (iPad_P){
        [self resizeWhenIpadPortrait];
    } else if (iPad_L) {
        [self resizeWhenIpadLandscape];
    }
}

- (CGSize) currentSize
{
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    CGSize size = [UIScreen mainScreen].bounds.size;
    
    
    if ((IPHONE_8_UP) && (__IPHONE_OS_8_0)) {
        return size;
    }else{
        
        if (UIInterfaceOrientationIsLandscape(orientation)) {
            CGFloat w = size.width;
            size.width = size.height;
            size.height = w;
        }
        return size;
    }
}


- (void)resizeWhenLandscape {

    CGSize screenSize = [self currentSize];
    CGSize dialogSize = [self countDialogSize];

    dialogView.frame = CGRectMake((screenSize.width - dialogSize.width) / 2, (screenSize.height - dialogSize.height) / 2, dialogSize.width, dialogSize.height);

//    dialogView.frame = CGRectMake((screenSize.height - dialogSize.width) / 2, (screenSize.width - dialogSize.height) / 2, dialogSize.width, dialogSize.height);
    
    
    if (self.shouldUpdateButtonsUIWhenLandscape) {
        [self updateButtonOnLine];
    }
    if ([self isKeyboardShowing]) {
        [self keyboardWillShow:nil];
    }
}

- (void)resizeWhenPortrait {

    CGSize screenSize = [self currentSize];
    CGSize dialogSize = [self countDialogSize];
    dialogView.frame = CGRectMake((screenSize.width - dialogSize.width) / 2, (screenSize.height - dialogSize.height) / 2, dialogSize.width, dialogSize.height);
    if (self.shouldUpdateButtonsUIWhenLandscape) {
        [self updateButtonOnMultipleLines];
    }
    if ([self isKeyboardShowing]) {
        [self keyboardWillShow:nil];
    }
}

- (void)resizeWhenIpadPortrait {
    
    CGSize screenSize = [self currentSize];
    CGSize dialogSize = [self countDialogSize];
    dialogView.frame = CGRectMake((screenSize.width - dialogSize.width) / 2, (screenSize.height - dialogSize.height) / 2, dialogSize.width, dialogSize.height);
    if ([self isKeyboardShowing]) {
        [self keyboardWillShow:nil];
    }
}

- (void)resizeWhenIpadLandscape {
    CGSize screenSize = [self currentSize];
    CGSize dialogSize = [self countDialogSize];
    dialogView.frame = CGRectMake((screenSize.width - dialogSize.width) / 2, (screenSize.height - dialogSize.height) / 2, dialogSize.width, dialogSize.height);
    if ([self isKeyboardShowing]) {
        [self keyboardWillShow:nil];
    }
}

- (BOOL)isKeyboardShowing {
    UITextField *tfFirst = (UITextField *)[self.view viewWithTag:kDialogFirstTextFieldTag];
    UITextField *tfSec = (UITextField *)[self.view viewWithTag:kDialogSecTextFieldTag];
    if ((tfFirst && tfFirst.isFirstResponder) || (tfSec && tfSec.isFirstResponder)) {
        return YES;
    }
    return NO;
}

#pragma mark - 重新对alert button排列

- (void)updateButtonOnLine {
    if (self.buttonTitles.count == 1) {
        return;
    }
    CGFloat b_h = I_PAD ? 50.0 : 42.0;
    CGFloat x = 20.f;
    CGFloat y = self.containerView.frame.size.height;
    CGFloat w = (dialogView.frame.size.width - 2 * x - 10 * (self.buttonTitles.count - 1)) / self.buttonTitles.count;
    UIFont *font =  I_PAD ? [UIFont systemFontOfSize:19] : [UIFont systemFontOfSize:17];
    UIButton *cancleButton = (UIButton *)[self.view viewWithTag:self.buttonTitles.count - 1 + kButtonTagStart];
    cancleButton.titleLabel.font = font;
    cancleButton.frame = CGRectMake(x, y, w, b_h);
    x += 10 + w;
    for (int i = 0 ; i < self.buttonTitles.count - 1; i ++) {
        UIButton *button = (UIButton *)[self.view viewWithTag:i + kButtonTagStart];
        button.titleLabel.font = font;
        button.frame = CGRectMake(x, y, w, b_h);
    }
}

- (void)updateButtonOnMultipleLines {
    CGFloat b_h = I_PAD ? 50.0 : 42.0;
    CGFloat x = 20.f;
    CGFloat y = self.containerView.frame.size.height;
    for (int i = 0; i < self.buttonTitles.count; i ++) {
        UIFont *font =  I_PAD ? [UIFont systemFontOfSize:17] : [UIFont systemFontOfSize:15];
        UIButton *button = (UIButton *)[self.view viewWithTag:i + kButtonTagStart];
        button.titleLabel.font = font;
        button.frame = CGRectMake(x, y, dialogView.frame.size.width - 2 * x, b_h);
        y += b_h + 10.0;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



- (void) fitTransform
{
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    CGSize size = [[UIScreen mainScreen] bounds].size;
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        CGFloat w = size.width;
        size.width = size.height;
        size.height = w;
    }
    if (orientation == UIInterfaceOrientationLandscapeLeft) {
        [self.view setTransform:CGAffineTransformMake(0, -1, 1, 0, 0, 0)];
    }else if (orientation == UIInterfaceOrientationLandscapeRight){
        [self.view setTransform:CGAffineTransformMake(0, 1, -1, 0, 0, 0)];
    }else if (orientation == UIInterfaceOrientationPortrait){
        self.view.transform = CGAffineTransformIdentity;
    }else if (orientation == UIInterfaceOrientationPortraitUpsideDown){
        self.view.transform = CGAffineTransformMake(-1, 0, -0, -1, 0, 0);
    }
    
    //    self.frame = CGRectMake(0, 0, size.width, size.height);
}






#pragma mark-- 方式适配 add csq



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
