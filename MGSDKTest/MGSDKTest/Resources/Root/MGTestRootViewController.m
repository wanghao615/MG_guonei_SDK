//
//  MGTestRootViewController.m
//  MGPlatformTest
//
//  Created by Eason on 29/04/2014.
//  Copyright (c) 2014 . All rights reserved.
//

#import "MGTestRootViewController.h"
#import "MGManager.h"
#import "MGSVProgressHUD.h"
#import "MGIAPTestViewController.h"


#define I_PAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define I_PHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)

#define I_Font (I_PAD ? [UIFont systemFontOfSize:18] : [UIFont systemFontOfSize:15])


@interface MGTestRootViewController ()<UITableViewDataSource, UITableViewDelegate>
{
    NSArray *_actionItems;
    
    UIButton *btnLogin;
    
    BOOL _isBind;
}

@end

@implementation MGTestRootViewController

- (id)initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil
                           bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.view.backgroundColor = TTHexColor(0xf7f7f9);
        
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    
    [self initialViews];
    [self addMGPlatformObservers];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

#pragma mark-- UI

- (void)initialViews
{
    
    CGFloat i_w = I_PHONE ? self.view.bounds.size.width: 524.0;
    UIView *headView = [[UIView alloc] initWithFrame: I_PHONE ? CGRectMake(0, 0, self.view.bounds.size.width, 170+49.0) : CGRectMake(0, 0, 524.0, 710/2)];
    headView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    
    UIImageView *logoIv = [[UIImageView alloc] initWithImage:[UIImage imageNamed: I_PHONE ? @"MG_logo": @"MG_logo_ipad"]];
    CGFloat w = I_PHONE ? 147.6 : 179.0, h = I_PHONE ? 107.2 : 130;
    CGFloat x = ceilf((i_w - w)/2);
    CGFloat y =  I_PHONE ? 24.0 : 65.0;
    logoIv.frame = CGRectMake(x, y, w, h);
    logoIv.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    [headView addSubview:logoIv];
    
    
    y = I_PHONE ? 170.0 : 291.0;
    h = I_PHONE ? 49.0 : 63.0;
    UIView *middleView = [[UIView alloc] initWithFrame:CGRectMake(0, y, i_w, h)];
    middleView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [headView addSubview:middleView];
    UIImageView *line1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"xline"]];
    line1.frame = CGRectMake(0, 0, middleView.bounds.size.width, 1.0);
    line1.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [middleView addSubview:line1];
    UIImageView *line2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"xline"]];
    line2.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    line2.frame = CGRectMake(0, middleView.bounds.size.height - 1.0, middleView.bounds.size.width, 1.0);
    [middleView addSubview:line2];
    UIImageView *line3 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"yline"]];
    line3.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    line3.frame = CGRectMake(ceilf(middleView.bounds.size.width/2), 5, 1.0, middleView.bounds.size.height - 10.0);
    [middleView addSubview:line3];
    
    
    btnLogin = [UIButton buttonWithType:UIButtonTypeCustom];
    btnLogin.frame = CGRectMake(0, 1, ceilf(middleView.bounds.size.width/2)-1, middleView.bounds.size.height-2);
    [btnLogin setTitle:@"登录" forState:UIControlStateNormal];
    [btnLogin setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btnLogin.titleLabel.font = I_Font;
    [btnLogin setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [middleView addSubview:btnLogin];
    btnLogin.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth;
    [btnLogin addTarget:self action:@selector(doLoginAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *coshowbtn = [UIButton buttonWithType:UIButtonTypeCustom];
    coshowbtn.frame = CGRectMake(ceilf(middleView.bounds.size.width/2)+1, 2, ceilf(middleView.bounds.size.width/2)-1, middleView.bounds.size.height-2);
    [coshowbtn setTitle:@"充值" forState:UIControlStateNormal];
    coshowbtn.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleLeftMargin;
    [coshowbtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [coshowbtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    coshowbtn.titleLabel.font = I_Font;
    [middleView addSubview:coshowbtn];
    [coshowbtn addTarget:self action:@selector(docoshowAction:) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    
    _actionItems = @[@"注册", @"切换账号",@"注销",@"创建角色",@"角色登录",@"充值统计",@"内购",@"查询用户是否绑定手机",@"查询用户是否绑身份证",@"热更新开始",@"热更新结束"];
    
    
    CGRect frame = I_PHONE ? self.view.bounds : CGRectMake(ceilf((self.view.bounds.size.width - 524.0)/2) , 0, 524, self.view.bounds.size.height);
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    tableView.tableHeaderView = headView;
    //    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 170.0+50.0, self.view.bounds.size.width, self.view.bounds.size.height-(170.0+50.0))];
    [self.view addSubview:tableView];
    
    tableView.autoresizingMask =  I_PHONE ?  UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight : UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleHeight ;
    tableView.delegate =self;
    tableView.dataSource = self;
    tableView.rowHeight = I_PHONE ? 42 : 50.0;
    tableView.separatorInset = UIEdgeInsetsMake(0, 16, 0, 0);
}

- (void) refreshLoginMark
{
    NSString *acc = [[MGManager defaultManager] MGLoginUserAccount];
    if ([acc length] > 0) {
        [btnLogin setTitle:[NSString stringWithFormat:@"登录：%@", acc] forState:UIControlStateNormal];
    }else
        [btnLogin setTitle:@"登录" forState:UIControlStateNormal];
}



- (void)removeMGPlatformObservers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark-- TableView Delegate

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_actionItems count];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"MG_demo_cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.textLabel.font = I_Font;
    cell.textLabel.text = _actionItems[indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}



#pragma mark-- －－－－－－－－－－－－－－－－－－MG Action Began－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－
#pragma mark-- MG SDK 注册通知


- (void)addMGPlatformObservers
{
    //添加MGPlatform 各类通知的观察者
    
    /*初始化结束通知, 登录等操作务必在收到该通知后调用*/
    
    /*登录通知*/
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(MGplatformLoginNoti:)
                                                 name:kMGPlatformLoginNotification
                                               object:nil];
    
    /* 注销登录通知 */
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(MGplatformLogoutFinished:)
                                                 name:kMGPlatformLogoutNotification
                                               object:nil];
    
    /*离开平台通知*/
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(MGplatformLeavedPlatform:)
                                                 name:kMGPlatformLeavedNotification
                                               object:nil];
    
    
    
}

#pragma mark-- MG SDK Action

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row == 0) {  // 注册
        
        [[MGManager defaultManager] MGUserRegister:0];
        
    }else if (indexPath.row == 1){ //切换账号
        
        [[MGManager defaultManager] MGUserLogin:0];
        
        
    }else if (indexPath.row == 2){  // 注销
        
        [[MGManager defaultManager] MGLogout:0];
        
        [self refreshLoginMark];
        
    }else if (indexPath.row == 3){ // 创建角色
        [[MGManager defaultManager] MGCreateRole:@"0462861" roleName:@"龙城霸主" gameServer:@"10327456"];
    }else if (indexPath.row == 4){ // 创建角色
        [[MGManager defaultManager] MGRoleLogin:@"0462861" roleName:@"龙城霸主" gameServer:@"10327456" level:@"045" occupation:@"战士"];
    }else if (indexPath.row == 5){ // 充值统计 单位是分
        [[MGManager defaultManager] MGOrderNumber:100 gameServer:1];
    }else if (indexPath.row == 6){
        MGIAPTestViewController *VC = [[MGIAPTestViewController alloc]init];
        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:VC];
        
        [self presentViewController:nav animated:YES completion:nil];
    }else if (indexPath.row == 7){
        [[MGManager defaultManager]MGPhoneStatus:^(NSString *phoneNum, BOOL status) {
            
            // status false -> 未绑定  yes -> 已经绑定
            //phoneNum 0  -> 未绑定    177****8123  -> 已经绑定
            NSString *temp = @"";
            if (status == YES) {
                temp = @"已经绑定";
            }else{
                temp = @"未绑定";
            }
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:temp message:phoneNum preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"绑定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [[MGManager defaultManager]MGEnterBindPhoneCompletion:^(NSString *phone, BOOL bindstatus) {
                    NSLog(@"%@%d",phone,bindstatus);
                }];
            }];
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"关闭" style:UIAlertActionStyleCancel handler:nil];
            
            [alert addAction:action];
            [alert addAction:cancel];
            [self presentViewController:alert animated:YES completion:nil];
            
        }];
        
    }else if (indexPath.row == 8){
        BOOL idCardstatus = [[MGManager defaultManager]MGidCardStatus];
        NSString *messageStr = @"";
        if (idCardstatus == YES) {
            messageStr = @"已经绑定";
        }else {
            messageStr = @"未绑定";
        }
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"是否绑身份证" message:messageStr preferredStyle:UIAlertControllerStyleAlert];
        
        
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"关闭" style:UIAlertActionStyleCancel handler:nil];
        
        
        [alert addAction:cancel];
        [self presentViewController:alert animated:YES completion:nil];
    }else if (indexPath.row == 9){
        [[MGManager defaultManager]MGGameHotStart];
    }else if (indexPath.row == 10){
        [[MGManager defaultManager]MGGameHotEnd];
    }

    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void) docoshowAction:(id)sender
{
}

- (void) doLoginAction:(id)sender
{
    [[MGManager defaultManager] MGUserLogin:0];
}

#pragma mark-- 登录注册 回调通知

- (void)MGplatformLoginNoti:(NSNotification*)notification
{
    // 登录完成, 提供token 以及 openuid 给游戏校验
    NSDictionary *userInfo = notification.userInfo;
    if ([userInfo[kMGPlatformErrorKey] intValue] == MG_PLATFORM_NO_ERROR) {
        //登录成功 isbind 1已经绑定手机号 0未绑定手机号
        NSInteger isbind = [userInfo[@"isbind"] integerValue];
        [self doSomeThingAfterLoginOrRegister:isbind];
    }
}

- (void) doSomeThingAfterLoginOrRegister:(NSInteger)isbind
{
    // 登录成功，开发者可继续游戏逻辑
    
    NSString* token = [[MGManager defaultManager] MGToken];       // token
    NSString* openuid = [[MGManager defaultManager] MGOpenUID];   // uid
    NSString *isbangStr = @"";
    if (isbind == 1) {
        isbangStr = @"已经绑定手机号";
        _isBind = YES;
    }else {
        isbangStr = @"未绑定手机号";
        _isBind = false;
    }
    
    NSString* total = [NSString stringWithFormat:@"openUid:%@ \ntoken:%@\nbind:%@", openuid, token,isbangStr];
    
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"登录成功" message:total preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
        [self alertViewCancel];
        [self MGShowToolBar:nil];
        [self refreshLoginMark];
        
    }];
    [alert addAction:action];
    
    [self presentViewController:alert animated:YES completion:nil];
    
}


- (void)alertViewCancel {
    if (_isBind == false) {
        //调用绑定方法
        [[MGManager defaultManager]MGEnterBindPhoneCompletion:^(NSString *phoneNum, BOOL status) {
            NSLog(@"%@%d",phoneNum,status);
        }];
    }
    
}


#pragma mark-- 注销

- (void)MGplatformLogoutFinished:(NSNotification*)notification
{
    [self refreshLoginMark];
    NSLog(@"logout finished.");
}


#pragma mark-- LevedPlatform Notification

- (void)MGplatformLeavedPlatform:(NSNotification*)notification
{
    NSNumber* leavedType = (NSNumber*)notification.object;
    
    switch ([leavedType integerValue]) {
        case MGPlatformLeavedDefault: {
            TTDEBUGLOG(@"用户离开平台－－> MGPlatformLeavedDefault");
            break;
        }
        case MGPlatformLeavedFromLogin: {
            TTDEBUGLOG(@"用户离开平台－－> MGPlatformLeavedFromLogin");
            
            [[MGManager defaultManager] MGIsLogined:^(BOOL isLogined) {
                if (!isLogined) {
                    [[MGManager defaultManager] MGUserLogin:0];
                }
            }];
            
            break;
        }
        case MGPlatformLeavedFromRegister: {
            TTDEBUGLOG(@"用户离开平台－－> MGPlatformLeavedFromRegister");
            
            [[MGManager defaultManager] MGIsLogined:^(BOOL isLogined) {
                if (!isLogined) {
                    [[MGManager defaultManager] MGUserLogin:0];
                }
            }];
            
            break;
        }
        case MGPlatformLeavedFromcoshow: {
            TTDEBUGLOG(@"用户离开平台－－> MGPlatformLeavedFromcoshow");
            break;
        }
        case MGPlatformLeavedFromSNSCenter:{
            TTDEBUGLOG(@"用户离开平台－－> MGPlatformLeavedFromUserCenter");
            break;
        }
            
        default:
            TTDEBUGLOG(@"用户离开平台－－> NULL");
            break;
    }
}

- (void) MGPlatformGuestTurnOffical:(id)sender
{
    [self refreshLoginMark];
}

#pragma mark-- －－－－－－－－－－－－－－－－－－MG Action END－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－









#pragma mark-- Other Action

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [self removeMGPlatformObservers];
}

- (BOOL) prefersStatusBarHidden
{
    return YES;
}

- (void)MGShowToolBar:(id)sender
{
    //   [[MGPlatform defaultPlatform] MGShowToolBar:MGToolBarAtTopLeft isUseOldPlace:YES];
}

- (void) viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
}








- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return [self bInPlistOrientation:toInterfaceOrientation];
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


- (BOOL)shouldAutorotate
{
    return YES;
}



- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

@end
