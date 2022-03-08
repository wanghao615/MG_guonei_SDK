//
//  MGIAPTestViewController.m
//  MGPlatformTest
//
//  Created by ZYZ on 2017/5/24.
//  Copyright © 2017年 MGzs. All rights reserved.
//

#import "MGIAPTestViewController.h"
#import "MGManager.h"

@interface MGIAPTestViewController ()<MGIAPDelegate,UITableViewDataSource,UITableViewDelegate>


@property (nonatomic,strong) UITableView    *tabV;

@property (nonatomic,strong) NSMutableArray *productArray;

@end

@implementation MGIAPTestViewController

-(NSMutableArray *)productArray{
    if(!_productArray){
        _productArray = [NSMutableArray array];
    }
    return _productArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupViews];
    
  
    //询问哪些商品能够购买 //设置代理
    
    [[MGManager defaultManager]MGIAPStartRequestProductsArray:@[@"com.overseasgm.testnum.gifta1200",
                                                                @"com.overseasgm.testnum.gifta119000"
        
//                                                                @"com.kingnet.gundam.6",
//                                                                @"com.kingnet.gundam.30",
//                                                                @"com.kingnet.gundam.98",
//                                                                @"com.kingnet.gundam.198",
//                                                                @"com.kingnet.gundam.328",
//                                                                @"com.kingnet.gundam.648",
//                                                                @"com.kingnet.gundam.KB98",
//                                                                @"com.kingnet.gundam.BJ128",
//                                                                @"com.kingnet.gundam.BJ40",
//                                                                @"com.kingnet.gundam.KFJJ68",
//                                                                @"com.kingnet.gundam.KA648",
//                                                                @"com.kingnet.gundam.KB328",
//                                                                @"com.kingnet.gundam.KA388",
//                                                                @"com.kingnet.gundam.KA198",
//                                                                @"com.kingnet.gundam.KB30",
//                                                                @"com.kingnet.gundam.KA30",
//                                                                @"com.kingnet.gundam.KF128",
//                                                                @"com.kingnet.gundam.BJ198",
//                                                                @"com.kingnet.gundam.KA128",
//                                                                @"com.kingnet.gundam.KA68",
//                                                                @"com.kingnet.gundam.JSKF128",
//                                                                @"com.kingnet.gundam.JS198",
//                                                                @"com.kingnet.gundam.KB198",
//                                                                @"com.kingnet.gundam.KA328",
//                                                                @"com.kingnet.gundam.KB388",
//                                                                @"com.kingnet.gundam.XSTH68",
//                                                                @"com.kingnet.gundam.M25",
//                                                                @"com.kingnet.gundam.XSTH328",
//                                                                @"com.kingnet.gundam.XSTH30",
//                                                                @"com.kingnet.gundam.XSTH128",
//                                                                @"com.kingnet.gundam.M68",
//                                                                @"com.kingnet.gundam.SB40",
//                                                                @"com.kingnet.gundam.SB128",
//                                                                @"com.kingnet.gundam.SE68",
//                                                                @"com.kingnet.gundam.SC198",
//                                                                @"com.kingnet.gundam.SD128",
//                                                                @"com.kingnet.gundam.SC328",
//                                                                @"com.kingnet.gundam.SC6",
//                                                                @"com.kingnet.gundam.SC68",
//                                                                @"com.kingnet.gundam.SB1",
//                                                                @"com.kingnet.gundam.SB2",
//                                                                @"com.kingnet.gundam.SB3",
//                                                                @"com.kingnet.gundam.SF1",
//                                                                @"com.kingnet.gundam.SF2",
//                                                                @"com.kingnet.gundam.SF3",
//                                                                @"com.kingnet.gundam.SF4",
//                                                                @"com.kingnet.gundam.SF5",
//                                                                @"com.kingnet.gundam.SF6",
//                                                                @"com.kingnet.gundam.SF7",
//                                                                @"com.kingnet.gundam.SF8",
//                                                                @"com.kingnet.gundam.SF9",
//                                                                @"com.kingnet.gundam.SF10",
//                                                                @"com.kingnet.gundam.SF11",
//                                                                @"com.kingnet.gundam.SF12",
//                                                                @"com.kingnet.gundam.SF13",
//                                                                @"com.kingnet.gundam.SF14",
//                                                                @"com.kingnet.gundam.SF15",
//                                                                @"com.kingnet.gundam.SF16",
//                                                                @"com.kingnet.gundam.SF17",
//                                                                @"com.kingnet.gundam.SF18",
//                                                                @"com.kingnet.gundam.SF19",
//                                                                @"com.kingnet.gundam.SF20",
//                                                                @"com.kingnet.gundam.SF21",
//                                                                @"com.kingnet.gundam.SF22",
//                                                                @"com.kingnet.gundam.SF23",
//                                                                @"com.kingnet.gundam.SF24",
//                                                                @"com.kingnet.gundam.SF25",
//                                                                @"com.kingnet.gundam.SF26",
//                                                                @"com.kingnet.gundam.SF27",
//                                                                @"com.kingnet.gundam.SF28",
//                                                                @"com.kingnet.gundam.SF29",
//                                                                @"com.kingnet.gundam.SF30",
//                                                                @"com.kingnet.gundam.SF31",
//                                                                @"com.kingnet.gundam.SF32",
//                                                                @"com.kingnet.gundam.SF33",
//                                                                @"com.kingnet.gundam.SF34",
//                                                                @"com.kingnet.gundam.SF35",
//                                                                @"com.kingnet.gundam.SF36",
//                                                                @"com.kingnet.gundam.SF37",
//                                                                @"com.kingnet.gundam.SF38",
//                                                                @"com.kingnet.gundam.SF39",
//                                                                @"com.kingnet.gundam.SF40",
//                                                                @"com.kingnet.gundam.SF41",
//                                                                @"com.kingnet.gundam.SF42",
//                                                                @"com.kingnet.gundam.SF43",
//                                                                @"com.kingnet.gundam.SF44",
//                                                                @"com.kingnet.gundam.SF45",
//                                                                @"com.kingnet.gundam.SF46",
//                                                                @"com.kingnet.gundam.SF47",
//                                                                @"com.kingnet.gundam.SF48",
//                                                                @"com.kingnet.gundam.SF49",
//                                                                @"com.kingnet.gundam.SF50",
//                                                                @"com.kingnet.gundam.SF51",
//                                                                @"com.kingnet.gundam.SF52",
//                                                                @"com.kingnet.gundam.SF53",
//                                                                @"com.kingnet.gundam.SF54",
//                                                                @"com.kingnet.gundam.SF55",
//                                                                @"com.kingnet.gundam.SF56",
//                                                                @"com.kingnet.gundam.SF57",
//                                                                @"com.kingnet.gundam.SF58",
//                                                                @"com.kingnet.gundam.SF59",
//                                                                @"com.kingnet.gundam.SF60",
//                                                                @"com.kingnet.gundam.SF61",
//                                                                @"com.kingnet.gundam.SF62",
//                                                                @"com.kingnet.gundam.ZLS328",
//                                                                @"com.kingnet.gundam.ZLS648"
                                                                ]WithDelegate:self];
   
//   [[MGManager defaultManager] MGIAPStartRequestProductsArray:nil WithDelegate:self];
}

#pragma mark --------YQInAppPurchaseToolDelegate
//用户禁止应用内付费购买
- (void)IAPToolUserProhibitedPayment {
    
}
//IAP工具已获得可购买的商品
-(void)IAPToolGotProducts:(NSMutableArray *)products {
    NSLog(@"GotProducts:%@",products);
    
    self.productArray = products;
    
    [self.tabV reloadData];
    
    [MGSVProgressHUD showSuccessWithStatus:@"成功获取到可购买的商品"];
}
//获取商品失败
- (void)IAPToolFailProducts {
    [MGSVProgressHUD showSuccessWithStatus:@"获取商品失败"];
}

//支付失败/取消
-(void)IAPToolCanceldWithProductID:(NSString *)productID {
    NSLog(@"canceld:%@",productID);
}
//支付成功了，并开始向苹果服务器进行验证
-(void)IAPToolBeginCheckingdWithProductID:(NSString *)productID {
    NSLog(@"BeginChecking:%@",productID);
    
   
}
//商品被重复验证了
-(void)IAPToolCheckRedundantWithProductID:(NSString *)productID {
    NSLog(@"CheckRedundant:%@",productID);
    
    [MGSVProgressHUD showWithStatus:@"重复验证了"];
}
//商品完全购买成功且验证成功了。
-(void)IAPToolBoughtProductSuccessedWithProductID:(NSString *)productID
                                          andInfo:(NSDictionary *)infoDic {
    NSLog(@"BoughtSuccessed:%@",productID);
    NSLog(@"successedInfo:%@",infoDic);
    
    
}
//商品购买成功了，但向苹果服务器验证失败了
//2种可能：
//1，设备越狱了，使用了插件，在虚假购买。
//2，验证的时候网络突然中断了。（一般极少出现，因为购买的时候是需要网络的）
-(void)IAPToolCheckFailedWithProductID:(NSString *)productID
                               andInfo:(NSData *)infoData {
    NSLog(@"CheckFailed:%@",productID);
    
    [MGSVProgressHUD showErrorWithStatus:@"验证失败了"];
}
//恢复了已购买的商品（仅限永久有效商品）
-(void)IAPToolRestoredProductID:(NSString *)productID {
    NSLog(@"Restored:%@",productID);
    

}
//内购系统错误了
-(void)IAPToolSysWrong {
    NSLog(@"SysWrong");
    [MGSVProgressHUD showErrorWithStatus:@"内购系统出错"];
}


#pragma mark --------Functions
//初始化界面显示
-(void)setupViews{
    self.tabV = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tabV.delegate = self;
    self.tabV.dataSource = self;
    
    [self.view addSubview:self.tabV];
    
    //注册重用单元格
    [self.tabV registerClass:[UITableViewCell class] forCellReuseIdentifier:@"MyCell"];
    
    UIBarButtonItem *BTN = [[UIBarButtonItem alloc]initWithTitle:@"说明"
                                                           style:UIBarButtonItemStylePlain
                                                          target:self
                                                          action:@selector(ShowInfo)];
    UIBarButtonItem *DissBTN = [[UIBarButtonItem alloc]initWithTitle:@"关闭"
                                                           style:UIBarButtonItemStylePlain
                                                          target:self
                                                          action:@selector(dissvc)];
    
    self.navigationItem.rightBarButtonItems = @[BTN,DissBTN];
    
    self.navigationItem.leftBarButtonItem =({
        UIBarButtonItem *BTN = [[UIBarButtonItem alloc]initWithTitle:@"恢复已购买商品"
                                                               style:UIBarButtonItemStylePlain
                                                              target:self
                                                              action:@selector(restoreProduct)];
        BTN;
    });
    
   
}
- (void)dissvc{
    [self dismissViewControllerAnimated:YES completion:nil];
}
//显示说明
-(void)ShowInfo{
    UIAlertView *alertDialog;
    alertDialog = [[UIAlertView alloc]
                   initWithTitle:@"说明！"
                   message:@"请使用真机进行测试\n\n请使用以下账号进行购买：\n账号：zyz635825226@qq.com\n密码：123456 \n bunlde id请修改为:com.ShengHe.wangzhechuanqi"
                   delegate:nil
                   cancelButtonTitle:@"OK"
                   otherButtonTitles: nil];
    [alertDialog show];
}

//恢复已购买的商品
-(void)restoreProduct{
    
    [[MGManager defaultManager]restoreProduct];
    
}

//购买商品
-(void)BuyProduct:(MGIAPModel *)product{
    
    MGIAPBuyModel *buyModel = [[MGIAPBuyModel alloc]init];
//    buyModel.amount = product.price;
    buyModel.amount = product.real_price;
    buyModel.real_price = product.real_price;
    buyModel.appName = @"测试demo";
    buyModel.appOrderID = [NSString stringWithFormat:@"YZ%d",(int)[[NSDate date]timeIntervalSince1970]];
    buyModel.appUserID = @"3";
    buyModel.appUserName = @"无敌战";
    buyModel.SID = @"3";
    buyModel.openUID = [[MGManager defaultManager]MGOpenUID];
    buyModel.productId = product.productIdentifier;
    buyModel.productName =  product.localizedTitle;
    buyModel.packageName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    buyModel.deviceType = @"iOS";
    buyModel.appkey = [[MGManager defaultManager]MG_APPID];
    buyModel.callback_url = @"http://apios3.gundambattle.com/gd_gmws/charge/paycallback_ios.php";
    
    [[MGManager defaultManager]MGBuyProduct:product withBuyModel:buyModel buyStatus:^(NSInteger buyStatus) {
        if (buyStatus==10000) {
            NSLog(@"法律允许购买");
        }else{
            NSLog(@"法律不允许购买");
        }
    }];
}


#pragma mark --------UITableViewDataSource,UITableViewDelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.productArray.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 220;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    //自动从重用队列中取得名称是MyCell的注册对象,如果没有，就会生成一个
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyCell" forIndexPath:indexPath];
    
    //清除cell上的原有view
    NSArray *subviews = [[NSArray alloc] initWithArray:cell.contentView.subviews];
    for (UIView *subview in subviews) {
        [subview removeFromSuperview];
    }
    
    MGIAPModel *product = self.productArray[indexPath.section];
    
    //cell的设置
    cell.textLabel.text = [NSString stringWithFormat:@"本地化商品描述:%@\n\n本地化商品标题:%@\n\n价格:%@\n\n商品ID:%@",
                           product.localizedDescription,
                           product.localizedTitle,
                           product.price,
                           product.productIdentifier];
    
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [self.tabV deselectRowAtIndexPath:indexPath animated:YES];
    
    [self BuyProduct:self.productArray[indexPath.section]];
}

@end
