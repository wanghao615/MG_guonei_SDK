//
//  MGCheckBox.h
//  MGPlatformTest
//
//  Created by Eason on 21/05/2014.
//  Copyright (c) 2014 Eason. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MGCheckBoxDelegate;
@interface MGCheckBox : UIButton

typedef NS_ENUM(NSUInteger, fromControllerType) {
    fromControllerIphoneRegister  = 2,
    fromControllerRegister,
    fromControllerLogin
};

@property (nonatomic, weak) id<MGCheckBoxDelegate> delegate;

@property (nonatomic, assign) fromControllerType fromConType;

@property (nonatomic, assign) BOOL checked;

@property (nonatomic, retain) id userInfo;

- (id)initWithDelegate:(id)delegate fromCon:(fromControllerType )conType;

@end

@protocol MGCheckBoxDelegate <NSObject>

@optional

- (void)didSelectedCheckBox:(MGCheckBox*)checkbox checked:(BOOL)checked;

@end
