//
//  MGManager.h
//  MYGameManagerTest
//
//  Created by Eason on 21/04/2014.
//  MGSDK

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MGPlatformDefines.h"

#ifndef MGManager

#define MGManager JiQxIVGLBWlJxQzs
#define MGConfiguration FswCbLDJLKGdxfUm
#define MGUserCenter SbJfUMLPZeOZNORt
#define MGUserRegister GuIVURwGYpybfuqM
#define MGGameCenter YYvNbFqrURJplBTW
#define MGDataStatistics XXdpjRZicnnTqFZo
#define MGIAPBuyModel FhstICUVklTpScdA
#define MGIAPModel zvdoQYGOkYxPgMzW
#define MGIAPDelegate CgISZNfLTJDUnVNo
#define MGIAP SdttQwvQmmQgBLMF
#define MGSetScreenOrientation CHqOidlkydUrreZV
#define MGSetDebugModel eoTPwFKQGvdtZvfk
#define MGSetShowSDKLog OsaGYAMBehCAYvwp
#define MGAutoLogin dScghTefIvjlXDnP
#define MGUserLogin KdDfXHJBMkGzYFMl
#define MGIsLogined QmXvNgBOZtNAWSwu
#define MGCreateRandomAccount QhUWNpprbZvsBkAR
#define MGLogout oLHwhlSfLAlrRhtg
#define MGToken fiuPavwOAEfCZJuF
#define MGOpenUID TqmEhlLvWJzMgDkC
#define MGLoginUserAccount bifJUaLaAmmwaISD
#define MGSwitchAccount spiwIIMjNIbeQBQj
#define MGIsGuestLogined ktcQsrHecOuEWSwV
#define MGGuestRegister gKmuJFlRMfiXGkEu
#define MGCreateRole AYkXfEwsrvtxNEPy
#define MGOrderNumber yZclGxnwPgkRLwEz
#define IAPToolBeginCheckingdWithProductID wPyJMweKjwBwRled
#define IAPToolBoughtProductSuccessedWithProductID kafKcaRjkbtqMuPY
#define IAPToolCanceldWithProductID xuVfThFsaBFOnWAI
#define IAPToolCheckFailedWithProductID iqIRBGqoBStlDAMo
#define IAPToolCheckRedundantWithProductID kegDotFMfZlYlupB
#define IAPToolGotProducts uZjUMNHMIimwsLDL
#define IAPToolFailProducts jhbYJBmnlljBGKL
#define IAPToolRestoredProductID TqzeYTlYzCxnqXJn
#define IAPToolSysWrong NtbXgzXZCXGpOymJ
#define IAPToolUserProhibitedPayment ASDadsfzDzcvzS
#define MGIAPStartRequestProductsArray PWwQDWXuIBImWwuQ
#define MGBuyProduct KVXtlaAdrWSusUSY
#define restoreProduct EcpJztHovEfoUOnd
#define MGEnterBindPhone EUFXedRjxvXxecFn

#endif

#pragma mark MGManager 基本信息

@interface MGManager : NSObject

/**
 *   @brief 获取MGManager实例
 */
+ (MGManager *)defaultManager;

/**
 *   @brief 获取SDK版本号
 */
+ (NSString *)sdkVersion;

@end


#pragma mark MGManager 初始化配置

@interface MGManager (MGConfiguration)

/**
 *	@brief  平台初始化方法
 *
 *  @param  appId 游戏在接入联运分配的appId
 *
 *	@param	appkey 游戏在接入联运时分配的appkey, 用于标记一个游戏
 *
 *  @param  isAccept 检查游戏版本更新升级，若检查更新失败（网络错误或因后台报错）是否继续游戏，建议传YES(即：继续游戏，可能跳过强制更新），可根据版本需要传
 *
 *	@param	orientation	 游戏的初始方向
 */
- (void) initializeWithAppId:(NSString *) appId
                      appKey:(NSString *) appKey
isContinueWhenCheckUpdateFailed:(BOOL)isAccept;

/**
 *  @brief  Manager 初始化之后，获取 appid
 */
@property (nonatomic, strong, readonly) NSString *MG_APPID;

/**
 * @brief Manager 初始化之后，获取 appkey
 */
@property (nonatomic, strong, readonly) NSString *MG_APPKEY;


/**
 * @brief platform 初始化之后，获取 隐私政策
 */
@property (nonatomic, strong) NSString *Private_URL;

/**
 * @brief platform Resource ID
 */
@property (nonatomic, strong) NSString *MG_RESOURCE_ID;

/**
 * @brief 初始化方向
 */
@property (nonatomic, assign, readonly) UIInterfaceOrientation mInterfaceOrientation;

/**
 * @brief 是否 debug 模式
 */
@property (nonatomic, assign, readonly) BOOL isDebugModel;

/**
 *  @brief 设定初始时游戏的方向
 *      1、其中设置的方向需要在 app plist文件Supported interface orientations 中支持，否则会Assert
 *      2、UIInterfaceOrientation, 设置 UIInterfaceOrientationLandscapeLeft 或者 UIInterfaceOrientationLandscapeRight，平台页面仅支持横屏幕。
 *      3、设置 UIInterfaceOrientationPortrait ，平台仅支持Portrait方向
 *      
 */
- (void)MGSetScreenOrientation:(UIInterfaceOrientation)orientation;

/**
 *  @brief 设置调试模式
 *
 *  @param debug YES 为测试环境, NO为 正式环境
 */
- (void)MGSetDebugModel:(BOOL)debug;


/**
 * @brief 打印log到控制台
 */
- (void)MGSetShowSDKLog:(BOOL)isShow;



@end


#pragma mark-- 用户部分，登录、注册、登出、token、uid 等

typedef void (^resultCompletion)(NSString *phoneNum,BOOL status);

@interface MGManager (MGUserCenter)

/**
 *  @brief 检查用户登录状态，如不再登录状态，自动登录
 *
 *  @param iflag 默认传0
 *
 *  @result 预留，默认为0
 */
- (int) MGAutoLogin:(int) iflag;


/**
 *  @brief MGManager 登录界面入口, 进入登录 or 注册页面
 *
 *  @param lFlag 标识(按位标识)预留, 默认为0
 *
 *  @result 错误码, 预留, 默认为0
 */
- (int)MGUserLogin:(int)lFlag;



/**
 *  @brief MGManager 注册界面入口
 *
 *  @param rFlag 标识(按位标识)预留, 默认为0
 *
 *  @result 错误码, 预留, 默认为0
 */
- (int)MGUserRegister:(int)rFlag;


/*
 * @brief 判断玩家登录状态，异步回调
 */
- (void)MGIsLogined:(void (^)(BOOL isLogined)) bLogined;


/**
 * 创建一个随机用户
 */
- (int)MGCreateRandomAccount:(int) cFlag;


/**
 *  @brief MGManager 注销, 即退出登录
 *
 *  @param lFlag 标识(按位标识), 0: 表示注销但保存本地信息;   1:表示注销, 并清除自动登录
 *
 *  @result 错误码, 预留, 默认为0
 */
- (int)MGLogout:(int)lFlag;


/**
 *  @brief 获取本次登录的token, 登录或注册之后返回, 有效期为7天
 */
- (NSString*) MGToken;

/**
 *  @brief 获取登录的openuid, 用于标记一个用户
 */
- (NSString*)MGOpenUID;

/**
 *  @brief 当前登录用户名
 */
- (NSString *) MGLoginUserAccount;

/**
 * status false -> 未绑定  yes -> 已经绑定
 * phoneNum 0  -> 未绑定    177****8123  -> 已经绑定
 */

- (void)MGPhoneStatus:(resultCompletion)Completion;

/**
 * @brief 检查当前用户是否绑定身份证
 * @return 0 未绑定 1 已绑定
 */
- (BOOL) MGidCardStatus;


/**
* @brief 检查当前用户是否成年
* @return 0 未成年 1 已成年、未开启  2未绑定身份证
*/
- (NSString *)MGIDCardAdult;

/**
 * @brief 切换账号
 */
- (void) MGSwitchAccount;

/**
 *  检查当前是否为游客登录状态
 *
 *  @return 当前是否为游客登录。
 */
- (BOOL) MGIsGuestLogined;


/**
 * @brief 游客账户注册。注册完毕，游客账户变为正式账户，UID不会变，游戏方可以在比如用户升级到一定级别或者其他需要时强制玩家注册
 *
 * @param rFlag
 *
 * @result 默认返回0  返回1表示当前不是游客账户或者没有登录，不弹出游客注册页面
 */

- (int) MGGuestRegister:(int)rFlag;


@end




#pragma mark-- GameCenter

@interface MGManager (MGGameCenter)

@end


#pragma mark-- 数据统计 创角+充值

@interface MGManager (MGDataStatistics)

/*
 * 热更新开始
 */
- (void)MGGameHotStart;

/*
 * 热更新结束
 */
- (void)MGGameHotEnd;

/**
 * @brief 数据统计 创角
 *
 * @param role: 角色id  roleName: 角色名称 server: 区服(一般是数字)
 *
 */

- (void) MGCreateRole:(NSString *)role roleName:(NSString *)roleName gameServer:(NSString *)server;

/**
 * @brief 数据统计 角色登录
 *
 * @param role: 角色id  roleName: 角色名称 server: 区服(一般是数字)  level: 角色等级 occupation: 职业
 *
 */

- (void) MGRoleLogin:(NSString *)role roleName:(NSString *)roleName gameServer:(NSString *)server level:(NSString *)level occupation:(NSString *)occupation;

/**
 * @brief 数据统计 充值
 *
 * @param money: (必须为数字类型，单位为分)  server: 服务器(必须为数字类型)
 *
 */
- (void) MGOrderNumber:(int)money gameServer:(int)server;

@end


//内购
#pragma mark-- IAP

//----------MGIAPBugModel--内购购买模型
@interface MGIAPBuyModel : NSObject

@property(nonatomic,strong)NSString *amount;
@property(nonatomic,strong)NSString *real_price;
@property(nonatomic,strong)NSString *appName;
@property(nonatomic,strong)NSString *appOrderID;
@property(nonatomic,strong)NSString *appUserID;
@property(nonatomic,strong)NSString *appUserName;
@property(nonatomic,strong)NSString *openUID;
@property(nonatomic,strong)NSString *productId;
@property(nonatomic,strong)NSString *productName;
@property(nonatomic,strong)NSString *SID;
@property(nonatomic,strong)NSString *packageName;
@property(nonatomic,strong)NSString *deviceType;
@property(nonatomic,strong)NSString *appkey;
@property(nonatomic,strong)NSString *callback_url;
@property(nonatomic,strong)NSString *url;
@end

//----------MGIAPModel--内购模型
@interface MGIAPModel : NSObject

@property(nonatomic,strong)NSString *localizedDescription;
@property(nonatomic,strong)NSString *localizedTitle;
@property(nonatomic,strong)NSString *price;
@property(nonatomic,strong)NSString *real_price;
@property(nonatomic,strong)NSString *productIdentifier;

@end

//----------MGIAPDelegate--内购代理

/**
 *  内购工具的代理
 */
@protocol MGIAPDelegate <NSObject>

/**
 *  代理：系统错误
 */
-(void)IAPToolSysWrong;
/**
 *  代理：用户禁止应用内付费购买
 */
- (void)IAPToolUserProhibitedPayment;

/**
 *  代理：已刷新可购买商品
 *
 *  @param products 商品数组
 */
-(void)IAPToolGotProducts:(NSMutableArray *)products;

/**
 *  代理：获取商品失败
 *
 */
-(void)IAPToolFailProducts;

/**
 *  代理：购买成功
 *
 *  @param productID 购买成功的商品ID
 */
-(void)IAPToolBoughtProductSuccessedWithProductID:(NSString *)productID
                                          andInfo:(NSDictionary *)infoDic;;

/**
 *  代理：取消购买
 *
 *  @param productID 商品ID
 */
-(void)IAPToolCanceldWithProductID:(NSString *)productID;

/**
 *  代理：购买成功，开始验证购买
 *
 *  @param productID 商品ID
 */
-(void)IAPToolBeginCheckingdWithProductID:(NSString *)productID;

/**
 *  代理：重复验证
 *
 *  @param productID 商品ID
 */
-(void)IAPToolCheckRedundantWithProductID:(NSString *)productID;

/**
 *  代理：验证失败
 *
 *  @param productID 商品ID
 */
-(void)IAPToolCheckFailedWithProductID:(NSString *)productID
                               andInfo:(NSData *)infoData;

/**
 *  恢复了已购买的商品（永久性商品）
 *
 *  @param productID 商品ID
 */
-(void)IAPToolRestoredProductID:(NSString *)productID;


@end



@interface MGManager (MGIAP)
/**
 * @brief 进入内购页面
 *
 *
 *
 */
- (void)MGIAPStartRequestProductsArray:(NSArray *)array WithDelegate:(id <MGIAPDelegate>)delegate;

/**
 * @brief 购买
 *
 * @param product 传入product 唯一表示
 *
 */
-(void)MGBuyProduct:(MGIAPModel *)product withBuyModel:(MGIAPBuyModel *)model;

/**
 * @brief 恢复已购买的商品
 *
 * @param product 传入product 唯一表示
 *
 */

-(void)restoreProduct;




@end

#pragma mark-- 各种中心

typedef void (^resultBlock)(NSString *phoneNum,BOOL status);

@interface MGManager(Center)




/**
 * @brief 进入手机绑定
 * status false -> 未绑定  yes -> 已经绑定
 * phoneNum 0  -> 未绑定    177****8123  -> 已经绑定
 *
 */

- (void) MGEnterBindPhoneCompletion:(resultBlock)Completion;



@end










