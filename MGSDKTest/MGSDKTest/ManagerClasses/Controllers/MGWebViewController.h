//
//  MGWebViewController.h
//  MGPlatformTest
//
//  Created by 曹 胜全 on 7/14/14.
//

#import "MGBaseViewController.h"

@interface MGWebViewController : MGBaseViewController

- (instancetype) initWithUrl:(NSString *) url andTitle:(NSString *) title;

@property (nonatomic, assign) BOOL bindEmailMarkAction;

@end
