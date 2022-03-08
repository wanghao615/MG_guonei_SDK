//
//  MGBaseViewController.m
//  MGPlatformDemo
//
//  Created by Eason on 21/04/2014.
//  Copyright (c) 2014 Eason. All rights reserved.
//

#import "MGBaseViewController.h"
#import "UIView+MGHandleFrame.h"

NSString* const kMGPlatformLeavedNotification = @"MGPlatformLeavedNotification";
NSString* const kMGPlatformLoginNotification = @"MGPlatformLoginNotification";


@interface MGBaseViewController ()

@property (nonatomic, strong) UIButton* rightButton;

@end

@implementation MGBaseViewController
@synthesize rightButton = _rightButton;


// hide statusBar for ios7 , cannnot add in UINavigationController
- (BOOL) prefersStatusBarHidden
{
    return YES;
}

- (void) loadView
{
    [super loadView];
    
    [self initializeView];
}

- (void) initializeView {}  // virtual function


- (id)initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil
                           bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[self rightButton]];

    if (TT_IS_IOS7_AND_UP) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    self.view.backgroundColor = TTHexColor(0xf7f7f9);
        
}

- (UIButton*)rightButton
{
    if (!_rightButton) {
        _rightButton = [[UIButton alloc] initWithFrame:CGRectMake(20.f, 0.f, 50.f, 35.f)];
        [_rightButton setImage:[MGUtility MGImageName:@"MG_nav_close.png"]
                      forState:UIControlStateNormal];
        [_rightButton addTarget:self
                         action:@selector(dismissself:)
               forControlEvents:UIControlEventTouchUpInside];
    }

    return _rightButton;
}

- (void) dismissself:(UIButton *) btn
{
    [self.view endEditing:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:kMGPlatform_Dismiss_Noti object:[NSNumber numberWithInt:self.MGAction] userInfo:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (float)getStartOriginY
{
    float originY = 0.f;
    if (TT_IS_IOS7_AND_UP) {
        originY = 64.f; // navigationBar
    } else {
        originY = 0.f;
    }
    return originY;
}

- (UIInterfaceOrientation)getScreenOrientation
{
    return [MGManager defaultManager].mInterfaceOrientation;
}

- (float)getScreenWidth
{
    UIInterfaceOrientation orientation = [self getScreenOrientation];

    if (UIInterfaceOrientationIsPortrait(orientation)) {
        return [UIScreen mainScreen].bounds.size.width;
    } else if (UIInterfaceOrientationIsPortrait(orientation)) {
        return [UIScreen mainScreen].bounds.size.height;
    }

    return [UIScreen mainScreen].bounds.size.width;
}

- (float)getScreenHeight
{
    UIInterfaceOrientation orientation = [self getScreenOrientation];

    if (UIInterfaceOrientationIsPortrait(orientation)) {
        return [UIScreen mainScreen].bounds.size.height;
    } else if (UIInterfaceOrientationIsPortrait(orientation)) {
        return [UIScreen mainScreen].bounds.size.width;
    }

    return [UIScreen mainScreen].bounds.size.height;
}

- (int)getDeviceType
{
    NSString *deviceType = [[UIDevice currentDevice] devicetype];
    return [deviceType intValue];
}


//
//- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
//{
//    return YES;
//}
//
//- (BOOL)shouldAutorotate
//{
//    UIInterfaceOrientation io = [self getScreenOrientation];
//    if (UIInterfaceOrientationIsLandscape(io) && UIInterfaceOrientationIsPortrait(io)) {
//        return YES;
//    }else
//        return NO;
//}
//
//- (NSUInteger)supportedInterfaceOrientations
//{
//    return  [self getScreenOrientation];
//}




@end
