//
//  MGRandomView.h
//  MGPlatformTest
//
//  Created by ZYZ on 17/1/20.
//  Copyright © 2017年 MGzs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MGRandomView : UIView
@property (nonatomic, retain) NSArray *changeArray;
@property (nonatomic, retain) NSMutableString *changeString;
@property (nonatomic, retain) UILabel *codeLabel;

-(NSString *)changeCode;
@end
