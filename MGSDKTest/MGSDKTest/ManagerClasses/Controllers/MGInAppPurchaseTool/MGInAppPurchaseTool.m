//
//  MGInAppPurchaseTool.m
//  MGPlatformTest
//
//  Created by ZYZ on 16/8/24.
//  Copyright © 2016年 MGzs. All rights reserved.
//
//#ifdef DEBUG


//#define LoadOrderURL @"http://dev3.pay.kingnet.com/index.php"
//
//#define checkURL @"http://dev3.pay.kingnet.com/index.php"

//#else
//#define LoadOrderURL @"http://pay3beta.pay.xy.com/index.php"
//#define checkURL @"http://pay3beta.pay.xy.com/index.php"
//#define LoadOrderURL @"http://ginger.xy.com/payget/apple"
//#define checkURL @"http://ginger.xy.com/payget/applenotify"
#define LoadOrderURL @"https://a.3177wan.com/index.php"

#define checkURL @"https://a.3177wan.com/index.php"

#define OrderInfoKey @"OrderInfoKey"

//#endif

#import "MGInAppPurchaseTool.h"
#import <AdSupport/AdSupport.h>
#import "MGSimulateIDFA.h"
#import "MGHttpClient.h"
#import "MGUtility.h"
#import "MGBindAlertView.h"
#import "MGConfiguration.h"



@interface MGInAppPurchaseTool ()<SKPaymentTransactionObserver,SKProductsRequestDelegate,UIAlertViewDelegate>

/**
 *  商品字典
 */
@property(nonatomic,strong)NSMutableDictionary *productDict;



//资源id
@property(nonatomic,strong)NSString *resourceid;

//orderid
@property(nonatomic,strong)NSString *orderid;


//checkurl
@property(nonatomic,strong)NSString *checkUrl;


//当前地区
@property(nonatomic,strong)NSString *priceLocale;

//商品对应的价格
@property(nonatomic,strong)NSDictionary *pSourceDict;

//当前的商品id
@property(nonatomic,strong)NSString *cuurentPruchaseID;

@property(nonatomic,strong)UIAlertView *returnAlert;

@property(nonatomic,strong)UIAlertView *cancelAlert;
//记录当前支付是否弹过窗口
@property(nonatomic,assign)BOOL isAlerted;
@end

@implementation MGInAppPurchaseTool
- (UIAlertView *)returnAlert {
    if (_returnAlert == nil) {
        _returnAlert = [[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"您的支付有风险，交易已取消，请使用中国区账号充值。" delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
    }
    return _returnAlert;
}
- (UIAlertView *)cancelAlert {
    if (_cancelAlert == nil) {
        _cancelAlert = [[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"您的支付有风险，交易已取消，请使用中国区账号充值。" delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
        _cancelAlert.tag = 10001;
    }
    return _cancelAlert;
}
- (NSString *)cuurentPruchaseID {
    if (_cuurentPruchaseID == nil) {
        _cuurentPruchaseID = @"";
    }
    return _cuurentPruchaseID;
}

- (NSDictionary *)pSourceDict {
    if (_pSourceDict == nil) {
        _pSourceDict = @{
                         @"com.kingnet.gundam.6" : @"6",
                         @"com.kingnet.gundam.30" : @"30",
                         @"com.kingnet.gundam.98" : @"98",
                         @"com.kingnet.gundam.198" : @"198",
                         @"com.kingnet.gundam.328" : @"328",
                         @"com.kingnet.gundam.648" : @"648",
                         @"com.kingnet.gundam.KB98" : @"98",
                         @"com.kingnet.gundam.BJ128" : @"128",
                         @"com.kingnet.gundam.BJ40" : @"40",
                         @"com.kingnet.gundam.KFJJ68" : @"68",
                         @"com.kingnet.gundam.KA648" : @"648",
                         @"com.kingnet.gundam.KB328" : @"328",
                         @"com.kingnet.gundam.KA388" : @"388",
                         @"com.kingnet.gundam.KA198" : @"198",
                         @"com.kingnet.gundam.KB30" : @"30",
                         @"com.kingnet.gundam.KA30" : @"30",
                         @"com.kingnet.gundam.KF128" : @"128",
                         @"com.kingnet.gundam.BJ198" : @"198",
                         @"com.kingnet.gundam.KA128" : @"128",
                         @"com.kingnet.gundam.KA68" : @"68",
                         @"com.kingnet.gundam.JSKF128" : @"128",
                         @"com.kingnet.gundam.JS198" : @"198",
                         @"com.kingnet.gundam.KB198" : @"198",
                         @"com.kingnet.gundam.KA328" : @"328",
                         @"com.kingnet.gundam.KB388" : @"388",
                         @"com.kingnet.gundam.XSTH68" : @"68",
                         @"com.kingnet.gundam.M25" : @"25",
                         @"com.kingnet.gundam.XSTH328" : @"328",
                         @"com.kingnet.gundam.XSTH30" : @"30",
                         @"com.kingnet.gundam.XSTH128" : @"128",
                         @"com.kingnet.gundam.M68" : @"68",
                         @"com.kingnet.gundam.SB40" : @"40",
                         @"com.kingnet.gundam.SB128" : @"128",
                         @"com.kingnet.gundam.SE68" : @"68",
                         @"com.kingnet.gundam.SC198" : @"198",
                         @"com.kingnet.gundam.SD128" : @"128",
                         @"com.kingnet.gundam.SC328" : @"328",
                         @"com.kingnet.gundam.SC6" : @"6",
                         @"com.kingnet.gundam.SC68" : @"68",
                         @"com.kingnet.gundam.SB1" : @"128",
                         @"com.kingnet.gundam.SB2" : @"328",
                         @"com.kingnet.gundam.SB3" : @"648",
                         @"com.kingnet.gundam.SF1" : @"18",
                         @"com.kingnet.gundam.SF2" : @"18",
                         @"com.kingnet.gundam.SF3" : @"6",
                         @"com.kingnet.gundam.SF4" : @"12",
                         @"com.kingnet.gundam.SF5" : @"12",
                         @"com.kingnet.gundam.SF6" : @"12",
                         @"com.kingnet.gundam.SF7" : @"6",
                         @"com.kingnet.gundam.SF8" : @"6",
                         @"com.kingnet.gundam.SF9" : @"6",
                         @"com.kingnet.gundam.SF10" : @"18",
                         @"com.kingnet.gundam.SF11" : @"40",
                         @"com.kingnet.gundam.SF12" : @"12",
                         @"com.kingnet.gundam.SF13" : @"25",
                         @"com.kingnet.gundam.SF14" : @"60",
                         @"com.kingnet.gundam.SF15" : @"40",
                         @"com.kingnet.gundam.SF16" : @"12",
                         @"com.kingnet.gundam.SF17" : @"6",
                         @"com.kingnet.gundam.SF18" : @"6",
                         @"com.kingnet.gundam.SF19" : @"12" ,
                         @"com.kingnet.gundam.SF20" : @"12" ,
                         @"com.kingnet.gundam.SF21" : @"12" ,
                         @"com.kingnet.gundam.SF22" : @"6" ,
                         @"com.kingnet.gundam.SF23" : @"12" ,
                         @"com.kingnet.gundam.SF24" : @"12" ,
                         @"com.kingnet.gundam.SF25" : @"12" ,
                         @"com.kingnet.gundam.SF26" : @"12" ,
                         @"com.kingnet.gundam.SF27" : @"12" ,
                         @"com.kingnet.gundam.SF28" : @"12" ,
                         @"com.kingnet.gundam.SF29" : @"12" ,
                         @"com.kingnet.gundam.SF30" : @"6" ,
                         @"com.kingnet.gundam.SF31" : @"12" ,
                         @"com.kingnet.gundam.SF32" : @"12" ,
                         @"com.kingnet.gundam.SF33" : @"12" ,
                         @"com.kingnet.gundam.SF34" : @"12" ,
                         @"com.kingnet.gundam.SF35" : @"6" ,
                         @"com.kingnet.gundam.SF36" : @"12" ,
                         @"com.kingnet.gundam.SF37" : @"12" ,
                         @"com.kingnet.gundam.SF38" : @"6" ,
                         @"com.kingnet.gundam.SF39" : @"12" ,
                         @"com.kingnet.gundam.SF40" : @"6" ,
                         @"com.kingnet.gundam.SF41" : @"40" ,
                         @"com.kingnet.gundam.SF42" : @"40" ,
                         @"com.kingnet.gundam.SF43" : @"40" ,
                         @"com.kingnet.gundam.SF44" : @"40" ,
                         @"com.kingnet.gundam.SF45" : @"25" ,
                         @"com.kingnet.gundam.SF46" : @"25" ,
                         @"com.kingnet.gundam.SF47" : @"60" ,
                         @"com.kingnet.gundam.SF48" : @"40" ,
                         @"com.kingnet.gundam.SF49" : @"40" ,
                         @"com.kingnet.gundam.SF50" : @"25" ,
                         @"com.kingnet.gundam.SF51" : @"68" ,
                         @"com.kingnet.gundam.SF52" : @"128",
                         @"com.kingnet.gundam.SF53" : @"198",
                         @"com.kingnet.gundam.SF54" : @"68" ,
                         @"com.kingnet.gundam.SF55" : @"648",
                         @"com.kingnet.gundam.SF56" : @"128",
                         @"com.kingnet.gundam.SF57" : @"128",
                         @"com.kingnet.gundam.SF58" : @"128",
                         @"com.kingnet.gundam.SF59" : @"168",
                         @"com.kingnet.gundam.SF60" : @"188",
                         @"com.kingnet.gundam.SF61" : @"18",
                         @"com.kingnet.gundam.SF62" : @"18",
                         @"com.kingnet.gundam.ZLS328" : @"328",
                         @"com.kingnet.gundam.ZLS648" : @"648",
                         @"com.kingnet.gundam.FIX6":@"6",
                         @"com.kingnet.gundam.FIX12":@"12",
                         @"com.kingnet.gundam.FIX30":@"30",
                         @"com.kingnet.gundam.FIX68":@"68",
                         @"com.kingnet.gundam.FIX98":@"98",
                         @"com.kingnet.gundam.FIX128":@"128",
                         @"com.kingnet.gundam.FIX198":@"198",
                         @"com.kingnet.gundam.FIX328":@"328",
                         @"com.kingnet.gundam.Pose128":@"128",
                         @"com.kingnet.gundam.Pose328":@"328",
                         @"com.kingnet.gundam.Pose648":@"648",
                         };
    }
    return _pSourceDict;
}


- (NSString *)priceLocale {
    if (_priceLocale == nil) {
        _priceLocale = @"";
    }
    return _priceLocale;
}


static MGInAppPurchaseTool *storeTool;

//单例
+(MGInAppPurchaseTool *)defaultTool{
    if(!storeTool){
        storeTool = [MGInAppPurchaseTool new];
        [storeTool setup];
    }
    return storeTool;
}

#pragma mark  初始化
/**
 *  初始化
 */
-(void)setup{
    
    // 设置购买队列的监听器
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    
    
    //如果中途程序 崩溃，再次运行会先跑这个订单 所以先取订单号
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults]objectForKey:OrderInfoKey];
    if (dict != nil) {
        self.orderid = dict[@"order_id"];
        self.resourceid = dict[@"resource_id"];
    }
}




#pragma mark 询问苹果的服务器能够销售哪些商品
/**
 *  询问苹果的服务器能够销售哪些商品
 */
- (void)getProductArray:(NSArray *)products WithDelegate:(id) delegate
{
    if (delegate != nil) {
        //设置代理
        self.delegate = delegate;
    }
    
    if ([products isKindOfClass:[NSArray class]]) {

        TTDEBUGLOG(@"开始请求可销售商品");
        
        // 能够销售的商品
        NSSet *set = [[NSSet alloc] initWithArray:products];
        
        // "异步"询问苹果能否销售
        SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:set];
        
        request.delegate = self;
        
        // 启动请求
        [request start];
        
        //    [MGSVProgressHUD showWithStatus:@"加载商品中..."];
    }else {
        [MGSVProgressHUD showErrorWithStatus:@"获取商品失败"];
        if ([self.delegate respondsToSelector:@selector(IAPToolFailProducts)]) {
            [self.delegate IAPToolFailProducts];
        }
    }
    
}

#pragma mark 获取询问结果，成功采取操作把商品加入可售商品字典里
/**
 *  获取询问结果，成功采取操作把商品加入可售商品字典里
 *
 *  @param request  请求内容
 *  @param response 返回的结果
 */
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    if (self.productDict == nil) {
        self.productDict = [NSMutableDictionary dictionaryWithCapacity:response.products.count];
    }
    
    NSMutableArray *productArray = [NSMutableArray array];
    
    for (SKProduct *product in response.products) {
        //TTDEBUGLOG(@"%@", product.productIdentifier);
        
        // 填充商品字典
        [self.productDict setObject:product forKey:product.productIdentifier];
        
        MGIAPModel *model = [[MGIAPModel alloc]init];
        model.productIdentifier = product.productIdentifier;
        model.localizedDescription = product.localizedDescription;
        model.localizedTitle = product.localizedTitle;
        model.real_price = [NSString stringWithFormat:@"%@",product.price];
        model.price = self.pSourceDict[product.productIdentifier];
        self.priceLocale = product.priceLocale.localeIdentifier;
        [productArray addObject:model];
    }
    
    if (productArray.count > 0) {
        [self sortProductArray:productArray];
    }else {
     
        [self alerMsg];
        return;
    }
}
//去自己服务获取商品数据 暂时没用
-(void)serverCreatePruchaseWithArray:(NSMutableArray *)productArray {
    //去服务器获取商品
    [[MGHttpClient shareMGHttpClient]getProductInfo:^(NSDictionary *responseDic) {
        if ([[responseDic objectForKey:@"ret"] integerValue] ==0) {
            if ([[responseDic objectForKey:@"data"] count] > 0) {
                NSArray *data = [responseDic objectForKey:@"data"];
                for (NSInteger i=0; i<data.count; i++) {
                    
                    MGIAPModel *model = [[MGIAPModel alloc] init];
                    model.localizedDescription = [NSString stringWithFormat:@"%@",data[i][@"description"]];
                    model.localizedTitle = [NSString stringWithFormat:@"%@",data[i][@"title"]];
                    model.price = [NSString stringWithFormat:@"%@",data[i][@"price"]];
                    model.productIdentifier = [NSString stringWithFormat:@"%@",data[i][@"product_id"]];
                    model.real_price = [NSString stringWithFormat:@"%@",data[i][@"price"]];
                    
                    [productArray addObject:model];
                    
                    // 填充商品字典
                    [self.productDict setObject:model forKey:model.productIdentifier];
                }
                if (productArray.count > 0) {
                    [self sortProductArray:productArray];
                }else {
                    [self locationCreatePruchase:productArray];
                }
            }
        }
    } failed:^(NSInteger ret, NSString *errMsg) {
        
        [self locationCreatePruchase:productArray];
    }];
}

//本地生成商品数据 暂时没用
- (void)locationCreatePruchase:(NSMutableArray *)productArray {
    NSArray *arrayItem = @[@"1",@"8",@"28",@"288",@"6",@"30",@"68",@"198",@"328",@"648"];
    
    NSMutableArray *arrayProducts = [[NSMutableArray alloc] init];
    for (NSInteger i=0; i<arrayItem.count; i++) {
        
        MGIAPModel *model = [[MGIAPModel alloc] init];
        model.localizedDescription = [NSString stringWithFormat:@"使用即可获得%@00元宝",arrayItem[i]];
        model.localizedTitle = [NSString stringWithFormat:@"%@00元宝",arrayItem[i]];
        model.price = arrayItem[i];
        model.real_price = arrayItem[i];
        model.productIdentifier = [NSString stringWithFormat:@"%@.%@",MGAPPBundleId,arrayItem[i]];
        
        [arrayProducts addObject:model];
        // 填充商品字典
        [self.productDict setObject:model forKey:model.productIdentifier];
    }
    [self sortProductArray:arrayProducts];
}


//商品排序
- (void)sortProductArray:(NSMutableArray *)productArray {
    //排序
    [productArray sortUsingComparator:^NSComparisonResult(MGIAPModel * obj1, MGIAPModel * obj2) {
        
        if ([obj1.price integerValue] < [obj2.price integerValue])
        {
            return NSOrderedAscending;
        }
        else
        {
            return NSOrderedDescending;
        }
    }];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        //通知代理
        if ([self.delegate respondsToSelector:@selector(IAPToolGotProducts:)]) {
            [self.delegate IAPToolGotProducts:productArray];
        }
        [MGSVProgressHUD dismiss];
    });

}


#pragma mark - SKPaymentTransaction Observer
#pragma mark 购买队列状态变化,,判断购买状态是否成功
/**
 *  监测购买队列的变化
 *
 *  @param queue        队列
 *  @param transactions 交易
 */
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    
    // 处理结果
    for (SKPaymentTransaction *transaction in transactions) {
        TTDEBUGLOG(@"队列状态变化 %@", transaction);
        // 如果小票状态是购买完成
        if (SKPaymentTransactionStatePurchased == transaction.transactionState) {
            //TTDEBUGLOG(@"购买完成 %@", transaction.payment.productIdentifier);
                [MGSVProgressHUD showWithStatus:@"购买成功，正在验证购买"];
                //需要向苹果服务器验证一下
                //通知代理
            if ([self.delegate respondsToSelector:@selector(IAPToolBeginCheckingdWithProductID:)]) {
              [self.delegate IAPToolBeginCheckingdWithProductID:transaction.payment.productIdentifier];
            }
            
                // 验证购买凭据
                [self verifyPruchaseWithID:transaction];
           
            
            
        } else if (SKPaymentTransactionStateRestored == transaction.transactionState) {
            //TTDEBUGLOG(@"恢复成功 :%@", transaction.payment.productIdentifier);
            [MGSVProgressHUD showSuccessWithStatus:@"成功恢复了商品"];
            // 通知代理
            if ([self.delegate respondsToSelector:@selector(IAPToolRestoredProductID:)]) {
               [self.delegate IAPToolRestoredProductID:transaction.payment.productIdentifier];
            }
            
            
            // 将交易从交易队列中删除
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
            
        } else if (SKPaymentTransactionStateFailed == transaction.transactionState){
            
            // 将交易从交易队列中删除
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
            //TTDEBUGLOG(@"交易失败");
            if ([self.delegate respondsToSelector:@selector(IAPToolCanceldWithProductID:)]) {
              [self.delegate IAPToolCanceldWithProductID:transaction.payment.productIdentifier];
            }
            
            [MGSVProgressHUD showErrorWithStatus:@"购买失败"];
            
            
        }else if(SKPaymentTransactionStatePurchasing == transaction.transactionState){
            TTDEBUGLOG(@"正在购买");
        }else{
            TTDEBUGLOG(@"state:%ld",(long)transaction.transactionState);
            TTDEBUGLOG(@"已经购买");
            // 将交易从交易队列中删除
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
        }
    }
    
}


- (BOOL)isShowAlertView {
    
    // auth_pay 0开启(非强制) 1开启(强制) 2关闭
    if ([[MGConfiguration shareConfiguration].auth_pay isEqualToString:@"2"]) {
        return false;
    }else if([[MGConfiguration shareConfiguration].auth_pay isEqualToString:@"0"]){
        if(self.isAlerted == YES) {
            return false;
        }else {
            return [self isAllAlert];
        }
   }else if([[MGConfiguration shareConfiguration].auth_pay isEqualToString:@"1"]){
       return [self isAllAlert];
   }
    else {
        return YES;
    }
    
}

//根据参数判断是否弹出全部用户
- (BOOL)isAllAlert {
    MGAccountSettingInfo *info = [MGStorage currentAccountSettingInfo];
    
    if([info.phoneStatus isEqualToString:@"1"]&&[info.idCardBindStatus isEqualToString:@"1"]){
        return false;
    }
    if([[MGConfiguration shareConfiguration].isAll isEqualToString:@"1"]){
        //非绑定手机用户
        if([info.phoneStatus isEqualToString:@"0"]&&[info.idCardBindStatus isEqualToString:@"0"]){
            return YES;
        }else {
            return false;
        }

    }else {
       //全部用户
        if([info.idCardBindStatus isEqualToString:@"1"]){
            return false;
        }else {
            return YES;
        }
        
    }
}





#pragma mark - 用户决定购买商品
/**
 *  用户决定购买商品
 *
 *  @param productID 商品ID
 */
- (void)orderForProduct:(NSString *)productID sid:(NSString *)sid rmb:(NSString *)rmb product_id:(NSString *)product_id product_name:(NSString *)product_name openuid:(NSString *)openuid app_name:(NSString *)app_name app_order_id:(NSString *)app_order_id app_user_name:(NSString *)app_user_name resource_id:(NSString *)resource_id package_name:(NSString *)package_name device_type:(NSString *)device_type app_key:(NSString *)app_key callback_url:(NSString *)callback_url appuser_id:(NSString *)appuser_id real_price:(NSString *)real_price
{
    if ([self isShowAlertView] == YES) {
        
        self.isAlerted = YES;
        //判断是否需要绑定手机
        MGBindAlertView *alerView = [[MGBindAlertView alloc]alerViewWithMessige:@"为了您的账号安全，请尽快绑定"];
        __weak typeof(self) weakSelf = self;
        alerView.closeSelf = ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [MGSVProgressHUD dismiss];
                if ([weakSelf.delegate respondsToSelector:@selector(IAPToolCanceldWithProductID:)]) {
                    [weakSelf.delegate IAPToolCanceldWithProductID:self.cuurentPruchaseID];
                }
            });
            [[MGHttpClient shareMGHttpClient].statistics closeAlertView];
        };
        alerView.handler = ^(NSInteger index) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [MGSVProgressHUD dismiss];
                if ([weakSelf.delegate respondsToSelector:@selector(IAPToolCanceldWithProductID:)]) {
                    [weakSelf.delegate IAPToolCanceldWithProductID:self.cuurentPruchaseID];
                }
            });
        };
        [alerView show];
        return ;
    }
    
    
    //统计购买
    [[MGHttpClient shareMGHttpClient]statisticsPaymentCompletion:^(NSDictionary *responseDic) {
        
    } failed:^(NSInteger ret, NSString *errMsg) {
        
    }];

    [MGSVProgressHUD showWithStatus:@"正在购买商品" maskType:MGSVProgressHUDMaskTypeClear];
    
    //参数
    NSMutableDictionary *partDict = [NSMutableDictionary
                                     dictionaryWithDictionary:@{
                                                                @"sid" : sid,
                                                                @"pay_rmb" : rmb == nil ? @"0":rmb,
                                                                @"product_id" : product_id,
                                                                @"product_name" : product_name,
                                                                @"openuid" : openuid,
                                                                @"app_name" : app_name,
                                                                @"app_order_id" : app_order_id,
                                                                @"app_user_name" : app_user_name,
                                                                @"resource_id" : resource_id,
                                                                @"package_name" : package_name,
                                                                @"device_type" : device_type,
                                                                @"app_key" : app_key,
                                                                @"imei" : [NSString IDFAORSimulateIDFA],
                                                                @"app_callback_url" : callback_url,
                                                                @"location" : [self changelocale],
                                                                @"real_loc" : self.priceLocale
                                                                }];
    
    [self beginGetOrder:partDict productID:productID resource_id:resource_id];

}
//判断当前地区 根据情况传参
- (NSString *)changelocale {
    NSString *temp = @"";
    if (self.priceLocaleInCheck != nil) {
        //审核中
        temp = @"en_CN@currency=CNY";
    }else {
        //审核后只有中国可以购买
        temp = self.priceLocale;
    }
    return temp;
}


#pragma mark - discarded code
/** =========== discarded code=========== */

- (void)orderForProduct:(NSString *)productID sid:(NSString *)sid rmb:(NSString *)rmb product_id:(NSString *)product_id product_name:(NSString *)product_name openuid:(NSString *)openuid app_name:(NSString *)app_name app_order_id:(NSString *)app_order_id app_user_name:(NSString *)app_user_name resource_id:(NSString *)resource_id package_name:(NSString *)package_name device_type:(NSString *)device_type app_key:(NSString *)app_key callback_url:(NSString *)callback_url {
    [MGSVProgressHUD showWithStatus:@"正在购买商品" maskType:MGSVProgressHUDMaskTypeClear];
    
    //参数
    NSMutableDictionary *partDict = [NSMutableDictionary
                                     dictionaryWithDictionary:@{
                                                                @"sid" : sid,
                                                                @"pay_rmb" : rmb,
                                                                @"product_id" : product_id,
                                                                @"product_name" : product_name,
                                                                @"openuid" : openuid,
                                                                @"app_name" : app_name,
                                                                @"app_order_id" : app_order_id,
                                                                @"app_user_name" : app_user_name,
                                                                @"resource_id" : resource_id,
                                                                @"package_name" : package_name,
                                                                @"device_type" : device_type,
                                                                @"app_key" : app_key,
                                                                @"imei" : [NSString IDFAORSimulateIDFA],
                                                                @"app_callback_url" : callback_url
                                                                }];
    
    
    
    [self beginGetOrder:partDict productID:productID resource_id:resource_id];
}

- (void)orderForProduct:(NSString *)productID sid:(NSString *)sid rmb:(NSString *)rmb product_id:(NSString *)product_id product_name:(NSString *)product_name openuid:(NSString *)openuid app_name:(NSString *)app_name app_order_id:(NSString *)app_order_id app_user_name:(NSString *)app_user_name resource_id:(NSString *)resource_id package_name:(NSString *)package_name device_type:(NSString *)device_type app_key:(NSString *)app_key {
    [MGSVProgressHUD showWithStatus:@"正在购买商品" maskType:MGSVProgressHUDMaskTypeClear];
    
    //参数
    NSMutableDictionary *partDict = [NSMutableDictionary
                                     dictionaryWithDictionary:@{
                                                                @"sid" : sid,
                                                                @"pay_rmb" : rmb,
                                                                @"product_id" : product_id,
                                                                @"product_name" : product_name,
                                                                @"openuid" : openuid
                                                                }];
    
    [self beginGetOrder:partDict productID:productID resource_id:resource_id];
}

- (void)orderForProduct:(NSString *)productID sid:(NSString *)sid rmb:(NSString *)rmb product_id:(NSString *)product_id product_name:(NSString *)product_name openuid:(NSString *)openuid app_name:(NSString *)app_name app_order_id:(NSString *)app_order_id resource_id:(NSString *)resource_id package_name:(NSString *)package_name device_type:(NSString *)device_type app_key:(NSString *)app_key {
    [MGSVProgressHUD showWithStatus:@"正在购买商品" maskType:MGSVProgressHUDMaskTypeClear];
    
    //参数
    NSMutableDictionary *partDict = [NSMutableDictionary
                                     dictionaryWithDictionary:@{
                                                                @"sid" : sid,
                                                                @"pay_rmb" : rmb,
                                                                @"product_id" : product_id,
                                                                @"product_name" : product_name,
                                                                @"openuid" : openuid
                                                                }];
    
    [self beginGetOrder:partDict productID:productID resource_id:resource_id];
}

- (void)orderForProduct:(NSString *)productID sid:(NSString *)sid rmb:(NSString *)rmb product_id:(NSString *)product_id product_name:(NSString *)product_name openuid:(NSString *)openuid app_name:(NSString *)app_name app_order_id:(NSString *)app_order_id app_user_name:(NSString *)app_user_name package_name:(NSString *)package_name device_type:(NSString *)device_type app_key:(NSString *)app_key {
    [MGSVProgressHUD showWithStatus:@"正在购买商品" maskType:MGSVProgressHUDMaskTypeClear];
    
    //参数
    NSMutableDictionary *partDict = [NSMutableDictionary
                                     dictionaryWithDictionary:@{
                                                                @"sid" : sid,
                                                                @"pay_rmb" : rmb,
                                                                @"product_id" : product_id,
                                                                @"product_name" : product_name,
                                                                @"openuid" : openuid
                                                                }];
    
    [self beginGetOrder:partDict productID:productID resource_id:nil];
}

- (void)orderForProduct:(NSString *)productID sid:(NSString *)sid rmb:(NSString *)rmb product_id:(NSString *)product_id product_name:(NSString *)product_name openuid:(NSString *)openuid app_name:(NSString *)app_name app_order_id:(NSString *)app_order_id app_user_name:(NSString *)app_user_name resource_id:(NSString *)resource_id package_name:(NSString *)package_name device_type:(NSString *)device_type {
    [MGSVProgressHUD showWithStatus:@"正在购买商品" maskType:MGSVProgressHUDMaskTypeClear];
    
    //参数
    NSMutableDictionary *partDict = [NSMutableDictionary
                                     dictionaryWithDictionary:@{
                                                                @"sid" : sid,
                                                                @"pay_rmb" : rmb,
                                                                @"product_id" : product_id,
                                                                @"product_name" : product_name,
                                                                @"openuid" : openuid
                                                                }];
    
    [self beginGetOrder:partDict productID:productID resource_id:resource_id];
}

- (void)orderForProduct:(NSString *)productID sid:(NSString *)sid rmb:(NSString *)rmb product_id:(NSString *)product_id product_name:(NSString *)product_name openuid:(NSString *)openuid app_name:(NSString *)app_name app_order_id:(NSString *)app_order_id app_user_name:(NSString *)app_user_name {
    [MGSVProgressHUD showWithStatus:@"正在购买商品" maskType:MGSVProgressHUDMaskTypeClear];
    
    //参数
    NSMutableDictionary *partDict = [NSMutableDictionary
                                     dictionaryWithDictionary:@{
                                                                @"sid" : sid,
                                                                @"pay_rmb" : rmb,
                                                                @"product_id" : product_id,
                                                                @"product_name" : product_name,
                                                                @"openuid" : openuid
                                                                }];
    
    [self beginGetOrder:partDict productID:productID resource_id:nil];
}


/** =========== discarded code=========== */

//开始购买
- (void)beginGetOrder:(NSMutableDictionary *)partDict productID:(NSString *)productID resource_id:(NSString *)resource_id {
    
    //获取订单号
    NSMutableDictionary *newDict = [NSMutableDictionary dictionaryWithDictionary:partDict];
     NSMutableDictionary *tempDict = [NSMutableDictionary dictionaryWithDictionary:newDict];
    [newDict setObject:[self getSignWithParams:tempDict] forKey:@"sign"];
    TTDEBUGLOG(@"%@",newDict);
    NSString *urlParms = [self loadDataParmstoString:newDict];
    
    [self getOrderId:urlParms PruchaseID:productID resourceid:resource_id checkUrl:LoadOrderURL again:NO];
    
}



//获取订单号
- (void)getOrderId:(NSString *)urlParms PruchaseID:(NSString *)PruchaseID resourceid:(NSString *)resourceid checkUrl:(NSString *)checkurl again:(BOOL)again {
    [MGSVProgressHUD showWithStatus:@"获取订单号中..." maskType:MGSVProgressHUDMaskTypeClear];
    
    __weak typeof(self) weakSelf = self;
    [self getOrderWithUrl:urlParms pruchaseID:PruchaseID resourceid:resourceid checkUrl:checkurl again:again success:^(NSDictionary *dict) {
        if ([[NSString stringWithFormat:@"%@",dict[@"code"]] isEqualToString:@"0"]) {
            NSString *order_id = dict[@"data"][@"order_id"];
            NSString *resource_id = dict[@"data"][@"resource_id"];
            
            weakSelf.orderid = order_id;
            weakSelf.resourceid = resource_id;
            
            [weakSelf setOrderNum:resourceid order_id:order_id];
            
            [weakSelf buyWithProductID:PruchaseID];
        }else {
            dispatch_async(dispatch_get_main_queue(), ^{
                //失败
                [MGSVProgressHUD showErrorWithStatus:@"购买失败，请稍后再试"];
                if ([weakSelf.delegate respondsToSelector:@selector(IAPToolCanceldWithProductID:)]) {
                   [weakSelf.delegate IAPToolCanceldWithProductID:PruchaseID];
                }
                
            });
        }

    } fail:^(NSString *error) {
        if (again) {
            dispatch_async(dispatch_get_main_queue(), ^{
                //失败
                [MGSVProgressHUD showErrorWithStatus:error];
                if ([weakSelf.delegate respondsToSelector:@selector(IAPToolCanceldWithProductID:)]) {
                   [weakSelf.delegate IAPToolCanceldWithProductID:PruchaseID];
                }
                
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [MGSVProgressHUD showWithStatus:error maskType:MGSVProgressHUDMaskTypeClear];
            });
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf getOrderId:urlParms PruchaseID:PruchaseID resourceid:resourceid checkUrl:checkurl again:YES];
            });
        }
    }];
}

//储存订单信息
- (void)setOrderNum:(NSString *)resource_id  order_id:(NSString *)order_id {
    
    
    [[NSUserDefaults standardUserDefaults]setObject:@{@"resource_id" : resource_id ,
                                                      @"order_id" : order_id
                                                      } forKey:OrderInfoKey];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

- (void)getOrderWithUrl:(NSString *)urlParms pruchaseID:(NSString *)PruchaseID resourceid:(NSString *)resourceid checkUrl:(NSString *)checkurl again:(BOOL)again success:(void (^)(NSDictionary * dict))success fail:(void (^)(NSString *error))fail {
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@?action=applemg&resource_id=%@%@",checkurl,resourceid,urlParms]]];
    
    
    NSURLSessionDataTask *dask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        TTDEBUGLOG(@"%@",[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]);
        NSString *errInfo = nil;
        if (error == nil) {
            NSError *err = nil;
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&err];
            
            if (dict != nil) {
                //获取订单失败
                if ([[NSString stringWithFormat:@"%@",dict[@"code"]] isEqualToString:@"1"]||[dict[@"msg"]isEqualToString:@"create order id fail"]) {
                        //失败
                    if ([dict[@"msg"]isEqualToString:@"无法购买，请使用规定货币支付"]) {
                        [self alerMsg:PruchaseID];
                        return;
                    }else {
                         errInfo = [NSString stringWithFormat:@"购买失败，请稍后再试(%@)",dict[@"msg"]];
                    }
                    
                }
            }else {
                errInfo = @"购买失败，请稍后再试";
            }
            
            if (errInfo) {
                if (!again) {
                    errInfo = @"获取订单号失败,重试中...";
                }
                fail(errInfo);
            } else {
                success(dict);
            }
        }else {
            if ([error.localizedDescription isEqualToString:@"似乎已断开与互联网的连接。"]) {
                errInfo = error.localizedDescription;
            }else {
                errInfo = @"购买失败，请稍后再试";
            }
            if (!again) {
                errInfo = @"获取订单号失败,重试中...";
            }
            fail(errInfo);
        }
    }];
    
    [dask resume];
}

- (void)alerMsg {
    dispatch_async(dispatch_get_main_queue(), ^{
        [MGSVProgressHUD dismiss];
        [self.cancelAlert show];
    });
    
}

- (void)alerMsg:(NSString *)PruchaseID {
    dispatch_async(dispatch_get_main_queue(), ^{
        [MGSVProgressHUD dismiss];
        self.cuurentPruchaseID = PruchaseID;
        [self.returnAlert show];
    });
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        if (alertView.tag == 10001) {
            if ([self.delegate respondsToSelector:@selector(IAPToolFailProducts)]) {
                [self.delegate IAPToolFailProducts];
            }
        }else {
            if ([self.delegate respondsToSelector:@selector(IAPToolCanceldWithProductID:)]) {
                [self.delegate IAPToolCanceldWithProductID:self.cuurentPruchaseID];
            }
        }
        
    }
    
}



// 发起购买
- (void)buyWithProductID:(NSString *)ProductID {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [MGSVProgressHUD showWithStatus:@"购买中..." maskType:MGSVProgressHUDMaskTypeClear];
        
    });

    if ([SKPaymentQueue canMakePayments])
    {
        SKProduct *product = self.productDict[ProductID];
        if (product == nil) {
            //通知代理
            dispatch_async(dispatch_get_main_queue(), ^{
                [MGSVProgressHUD dismiss];
                if ([self.delegate respondsToSelector:@selector(IAPToolCanceldWithProductID:)]) {
                    [self.delegate IAPToolCanceldWithProductID:self.cuurentPruchaseID];
                }
            });
            
            return;
        }

        // 要购买产品(店员给用户开了个小票)
        SKPayment *payment = [SKPayment paymentWithProduct:product];
        if (payment == nil) {
            //通知代理
            dispatch_async(dispatch_get_main_queue(), ^{
                [MGSVProgressHUD dismiss];
                if ([self.delegate respondsToSelector:@selector(IAPToolCanceldWithProductID:)]) {
                    [self.delegate IAPToolCanceldWithProductID:self.cuurentPruchaseID];
                }
            });
            
            return;
        }
        if ([product isKindOfClass:[MGIAPModel class]]) {
            self.priceLocale = @"";
        }else {
            self.priceLocale = product.priceLocale.localeIdentifier;
        }
        // 去收银台排队，准备购买(异步网络)
        [[SKPaymentQueue defaultQueue] addPayment:payment];
    }else{
        //用户禁止应用内付费购买
        dispatch_async(dispatch_get_main_queue(), ^{
            [MGSVProgressHUD showErrorWithStatus:@"用户禁止应用内付费购买"];
            if ([self.delegate respondsToSelector:@selector(IAPToolUserProhibitedPayment)]) {
                [self.delegate IAPToolUserProhibitedPayment];
            }
        });
        
    }
}




#pragma mark 验证购买凭据
/**
 *  验证购买凭据
 *
 *  @param ProductID 商品ID
 */
- (void)verifyPruchaseWithID:(SKPaymentTransaction *)Product
{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [MGSVProgressHUD showWithStatus:@"验证中..." maskType:MGSVProgressHUDMaskTypeClear];
        
    });
    
    // 验证凭据，获取到苹果返回的交易凭据
    // appStoreReceiptURL iOS7.0增加的，购买交易完成后，会将凭据存放在该地址
    NSURL *receiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
    // 从沙盒中获取到购买凭据
    NSData *receiptData = [NSData dataWithContentsOfURL:receiptURL];
    
    // 发送网络POST请求，对购买凭据进行验证
    
    NSString *checkurl = @"";
    if (self.checkUrl.length > 0) {
        checkurl = self.checkUrl;
    }else {
        checkurl = checkURL;
    }
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?action=applenotifymg&resource_id=%@",checkurl,self.resourceid]];
    
    TTDEBUGLOG(@"URL:%@",url);
    
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20.0f];
    
    request.HTTPMethod = @"POST";
    
    //BASE64
    
    NSString *encodeStr = [receiptData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    
    NSString *sign = [MGUtility md5:[NSString stringWithFormat:@"%@%@%@cf9b337069cb5dec34d1b3f266306bd8",self.orderid,Product.transactionIdentifier,encodeStr]];
    
    NSString *dataStr = [NSString stringWithFormat:@"{\"receipt-data\" : \"%@\" ,\"order_id\" : \"%@\",\"location\" : \"%@\",\"real_loc\" : \"%@\" ,\"sign\" : \"%@\",\"apple_order_id\" : \"%@\"}", encodeStr,self.orderid,[self changelocale],self.priceLocale,sign,Product.transactionIdentifier];
    NSData *postData = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
    
    request.HTTPBody = postData;
    
    
    // 提交验证请求，并获得官方的验证JSON结果
    NSURLResponse *Response = nil;
    NSError *error = nil;
    NSData *result = [NSURLConnection sendSynchronousRequest:request returningResponse:&Response error:&error];
    
    
    
    // 服务器结果为空
    if (result == nil) {
        //TTDEBUGLOG(@"验证失败");
        //失败重连
        dispatch_async(dispatch_get_main_queue(), ^{
            [MGSVProgressHUD showWithStatus:@"验证失败,重试中..." maskType:MGSVProgressHUDMaskTypeClear];
        });
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self verifyPruchaseWithIDAgain:Product];
        });
        
        return;
    }
    
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:result
                                                         options:NSJSONReadingAllowFragments error:nil];
    
     NSLog(@"000000000---------status:%@-----msg:%@", dict[@"status"], dict[@"msg"]);
    
    //    status  0 成功 1 失败 msg
    if (dict != nil) {
        
        if ([[NSString stringWithFormat:@"%@",dict[@"status"]] isEqualToString:@"0"]||[dict[@"msg"]isEqualToString:@"支付成功"]) {
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                //成功
                [MGSVProgressHUD showSuccessWithStatus:@"已经成功购买，谢谢"];
                
                // 验证成功,通知代理
                if ([self.delegate respondsToSelector:@selector(IAPToolBoughtProductSuccessedWithProductID:andInfo:)]) {
                    [self.delegate IAPToolBoughtProductSuccessedWithProductID:Product.payment.productIdentifier
                                                                      andInfo:dict];
                }
                
                
                // 将交易从交易队列中删除
                [[SKPaymentQueue defaultQueue] finishTransaction:Product];
            });
            
        }else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [MGSVProgressHUD showWithStatus:@"验证失败,重试中..." maskType:MGSVProgressHUDMaskTypeClear];
            });
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self verifyPruchaseWithIDAgain:Product];
            });
            
        }
    }else{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [MGSVProgressHUD showWithStatus:@"验证失败,重试中..." maskType:MGSVProgressHUDMaskTypeClear];
        });
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self verifyPruchaseWithIDAgain:Product];
        });
        
        
    }
    
}

- (void)verifyPruchaseWithIDAgain:(SKPaymentTransaction *)Product
{
    [MGSVProgressHUD showWithStatus:@"再次验证中..." maskType:MGSVProgressHUDMaskTypeClear];
    
    // 验证凭据，获取到苹果返回的交易凭据
    // appStoreReceiptURL iOS7.0增加的，购买交易完成后，会将凭据存放在该地址
    NSURL *receiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
    // 从沙盒中获取到购买凭据
    NSData *receiptData = [NSData dataWithContentsOfURL:receiptURL];
    
    // 发送网络POST请求，对购买凭据进行验证
    
    NSString *checkurl = @"";
    if (self.checkUrl.length > 0) {
        checkurl = self.checkUrl;
    }else {
        checkurl = checkURL;
    }
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?action=applenotifymg&resource_id=%@",checkurl,self.resourceid]];
    
    TTDEBUGLOG(@"URL:%@",url);
    
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20.0f];
    
    request.HTTPMethod = @"POST";
    
    
    //BASE64
    
    NSString *encodeStr = [receiptData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    
     NSString *sign = [MGUtility md5:[NSString stringWithFormat:@"%@%@%@cf9b337069cb5dec34d1b3f266306bd8",self.orderid,Product.transactionIdentifier,encodeStr]];
    
    NSString *datastr = [NSString stringWithFormat:@"{\"receipt-data\" : \"%@\" ,\"order_id\" : \"%@\",\"location\" : \"%@\" ,\"real_loc\" : \"%@\" ,\"sign\" : \"%@\",\"apple_order_id\" : \"%@\"}", encodeStr,self.orderid,[self changelocale],self.priceLocale,sign,Product.transactionIdentifier];
    NSData *postData = [datastr dataUsingEncoding:NSUTF8StringEncoding];
    
    request.HTTPBody = postData;
    
    
    // 提交验证请求，并获得官方的验证JSON结果
    NSURLResponse *Response = nil;
    NSError *error = nil;
    NSData *result = [NSURLConnection sendSynchronousRequest:request returningResponse:&Response error:&error];
    
    
    
    // 服务器结果为空
    if (result == nil) {
        //TTDEBUGLOG(@"验证失败");
        //失败重连
        dispatch_async(dispatch_get_main_queue(), ^{
            
            //失败
            [MGSVProgressHUD showErrorWithStatus:@"购买失败，请稍后再试"];
            
            //验证失败,通知代理
            if ([self.delegate respondsToSelector:@selector(IAPToolCheckFailedWithProductID:andInfo:)]) {
                [self.delegate IAPToolCheckFailedWithProductID:Product.payment.productIdentifier
                                                       andInfo:result];
            }
            
            
            // 将交易从交易队列中删除
            [[SKPaymentQueue defaultQueue] finishTransaction:Product];
        });
        
        return;
    }
    
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:result
                                                         options:NSJSONReadingAllowFragments error:nil];
    
    NSLog(@"1111111---------status:%@-----msg:%@", dict[@"status"], dict[@"msg"]);
    
    //    status  0 成功 1 失败 msg
    if (dict != nil) {
        
        if ([[NSString stringWithFormat:@"%@",dict[@"status"]] isEqualToString:@"0"]||[dict[@"msg"]isEqualToString:@"支付成功"]) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                //成功
                [MGSVProgressHUD showSuccessWithStatus:@"已经成功购买，谢谢"];
                
                // 验证成功,通知代理
                if ([self.delegate respondsToSelector:@selector(IAPToolBoughtProductSuccessedWithProductID:andInfo:)]) {
                    [self.delegate IAPToolBoughtProductSuccessedWithProductID:Product.payment.productIdentifier
                                                                      andInfo:dict];
                }
                
                
                // 将交易从交易队列中删除
                [[SKPaymentQueue defaultQueue] finishTransaction:Product];
            });
            
        }else {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                //失败
                [MGSVProgressHUD showErrorWithStatus:@"购买失败，请稍后再试"];
                
                //验证失败,通知代理
                if ([self.delegate respondsToSelector:@selector(IAPToolCheckFailedWithProductID:andInfo:)]) {
                    [self.delegate IAPToolCheckFailedWithProductID:Product.payment.productIdentifier
                                                           andInfo:result];
                }
                
                
                
                // 将交易从交易队列中删除
                [[SKPaymentQueue defaultQueue] finishTransaction:Product];
                
            });
            
        }
    }else{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            
            if ([error.localizedDescription isEqualToString:@"请求超时。"]) {
                [MGSVProgressHUD showErrorWithStatus:error.localizedDescription];
            }else {
                //失败
                [MGSVProgressHUD showErrorWithStatus:@"购买失败，请稍后再试"];
                
            }
            
            
            //验证失败,通知代理
            if ([self.delegate respondsToSelector:@selector(IAPToolCheckFailedWithProductID:andInfo:)]) {
                [self.delegate IAPToolCheckFailedWithProductID:Product.payment.productIdentifier
                                                       andInfo:result];
            }
            
            
            // 将交易从交易队列中删除
            [[SKPaymentQueue defaultQueue] finishTransaction:Product];
        });
        
        
    }
    
    
}







#pragma mark - 恢复商品
/**
 *  恢复商品
 */
- (void)restorePurchase
{
    [MGSVProgressHUD showWithStatus:@"正在恢复商品"];
    // 恢复已经完成的所有交易.（仅限永久有效商品）
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
    
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue {
    [MGSVProgressHUD dismiss];
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error {
    [MGSVProgressHUD showErrorWithStatus:@"恢复失败"];
}









#pragma mark 整理参数的一些方法


//连接参数
- (NSString *)loadDataParmstoString:(NSMutableDictionary *)dict {
    
    
    NSArray *keyArray = [dict allKeys];
    NSArray *valueArray = [dict allValues];
    NSMutableString *str = [NSMutableString string];
    
    [keyArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [str appendString:[NSString stringWithFormat:@"&%@=%@",obj,[self encodeToPercentEscapeString:valueArray[idx]]]];
    }];
    
    return str;
}


//sign
- (NSString *)getSignWithParams:(NSMutableDictionary *) params
{
    NSMutableString *pairs = [NSMutableString string];
    NSArray *unsetArray = @[@"sign",@"key",@"paid",@"action",@"resource_id",@"extra_currency",@"cash_type",@"callback_url",@"jump_url",@"app_name",@"app_name",@"app_user_name",@"product_name",@"user_ip"];
    
    [params removeObjectsForKeys:unsetArray];
    
    NSArray *values = [[params allValues]sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 compare:obj2];
    }];
    
    for (NSString *value in values) {
        [pairs appendString:[NSString stringWithFormat:@"%@",value]];
    }
    
    NSString *sign = [MGUtility md5:[NSString stringWithFormat:@"582df15de91b3f12d8e710073e43f4f8%@",pairs]];
    
    return sign;
}

- (NSString *)encodeToPercentEscapeString: (NSString *) input
{
    NSString *outputStr = (NSString *)
    CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                              (CFStringRef)input,
                                                              NULL,
                                                              (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                              kCFStringEncodingUTF8));
    return outputStr;
}




@end
