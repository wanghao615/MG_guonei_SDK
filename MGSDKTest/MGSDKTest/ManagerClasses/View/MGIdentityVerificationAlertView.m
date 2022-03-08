//
//  MGIdentityVerificationAlertView.m
//  MGPlatformTest
//
//  Created by ZYZ on 17/3/22.
//  Copyright © 2017年 MGzs. All rights reserved.
//

#import "MGIdentityVerificationAlertView.h"
#import "MGAlertViewRootVC.h"
#import "MGUtility.h"
#import "MGTAttributedLabel.h"
#import "MGUITextField_XLine.h"
#import "UIView+MGHandleFrame.h"

@interface  MGIdentityVerificationAlertView()

@property (nonatomic, strong) NSMutableArray *buttonTitles;
@end

@implementation MGIdentityVerificationAlertView


- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self.rootVC.view endEditing:YES];
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self innitUI];
    }
    return self;
}

- (id)init {
    self = [super init];
    if (self) {
        [self innitUI];
    }
    return self;
    
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [self initWithCoder:aDecoder];
    if (self) {
        [self innitUI];
    }
    return self;
}

- (id)initWithCancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ... {
    
    self = [super init];
    if (self) {
        [self innitUI];
        va_list args;
        va_start(args, otherButtonTitles);
        for (NSString *str = otherButtonTitles; str != nil; str = va_arg(args,NSString*)) {
            [self.buttonTitles addObject:str];
        }
        va_end(args);
        if (cancelButtonTitle && cancelButtonTitle.length > 0) {
            [self.buttonTitles addObject:cancelButtonTitle];
        }
    }
    return self;
    
}

- (void)innitUI {
    [self setWindowLevel:UIWindowLevelAlert];
    self.frame = [[UIScreen mainScreen] bounds];
    [self setBackgroundColor:[UIColor clearColor]];
    self.buttonTitles = [NSMutableArray arrayWithCapacity:1];
}


- (void)dismiss {
    
    [self.rootVC dismissView];
    [self removeFromSuperview];
}

- (void)show
{
    
    self.rootVC.dialogAlert = self;
    self.rootVC.buttonTitles = self.buttonTitles;
    self.rootVC.containerView = self.containerView;
    
    
    [self setRootViewController:self.rootVC];
    [self makeKeyAndVisible];
    [self.rootVC startShow];
}

+ (CGFloat)getMaxContainerViewWidth {
    CGFloat w = .0f;
    if (TT_IS_IPHONE) {
        w = kDialogViewWidthPhone;
    } else if (TT_IS_IPAD) {
        w = kDialogViewWidthPad;
    }
    return w;
}


- (void)setShouldUpdateButtonsUIWhenLandscape:(BOOL)shouldUpdateButtonsUIWhenLandscape {
    _shouldUpdateButtonsUIWhenLandscape = shouldUpdateButtonsUIWhenLandscape;
    self.rootVC.shouldUpdateButtonsUIWhenLandscape = shouldUpdateButtonsUIWhenLandscape;
}

- (MGAlertViewRootVC *)rootVC {
    if (_rootVC == nil) {
        _rootVC = [[MGAlertViewRootVC alloc] init];
    }
    
    return _rootVC;
}

@end

@interface MGIdentityVerificationContainerView () <UITextFieldDelegate>

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) UILabel *labelTitle;
@property (nonatomic, strong) UILabel *labelMessage;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) UITextField *tfAccount;
@property (nonatomic, strong) UITextField *tfSecret;

@end

@implementation MGIdentityVerificationContainerView

- (id)initWithWidth:(CGFloat)width title:(NSString *)title message:(NSString *)message {
    self = [super init];
    if (self) {
        self.frame = CGRectMake(0, 0, width, 0);
        self.backgroundColor = [UIColor clearColor];
        self.title = title;
        self.message = message;
        [self initUI];
    }
    return self;
}

- (void)initUI {
    UIFont *font1 =  I_PAD ? [UIFont boldSystemFontOfSize:17] : [UIFont boldSystemFontOfSize:16];
    UIFont *font =  I_PAD ? [UIFont systemFontOfSize:16] : [UIFont systemFontOfSize:13];
    CGFloat x = 20, y = 30, w = CGRectGetWidth(self.frame);
    UIColor *color = TTHexColor(0x000000);
    
    //    CGFloat titleHeight = [self.title sizeWithFont:font1 constrainedToSize:CGSizeMake(w, 100) lineBreakMode:NSLineBreakByTruncatingTail].height;
    CGFloat titleHeight = [self.title boundingRectWithSize:CGSizeMake(w, 100) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : font1} context:0].size.height;
    
    self.labelTitle = [MGUtility newLabel:CGRectMake(x, y, w-2*x, titleHeight) title:_title font:font1 textColor:color];
    _labelTitle.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _labelTitle.numberOfLines = 0;
    _labelTitle.lineBreakMode = NSLineBreakByTruncatingTail;
    _labelTitle.textAlignment = NSTextAlignmentCenter;
//    [_labelTitle setMinimumFontSize:12];
    //    [_labelTitle setMinimumScaleFactor:1.0];
    [self addSubview:self.labelTitle];
    
    y += titleHeight + 10;
    //    titleHeight = [self.message sizeWithFont:font constrainedToSize:CGSizeMake(w, 150) lineBreakMode:NSLineBreakByWordWrapping].height;
    titleHeight = [self.message boundingRectWithSize:CGSizeMake((w - 2 * x), 150) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : font} context:0].size.height;
    
    self.labelMessage = [MGUtility newLabel:CGRectMake(x, y, (w - 2 * x), titleHeight) title:_message font:font textColor:TTHexColor(0x868891)];
    _labelMessage.numberOfLines = 0;
    _labelMessage.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _labelMessage.lineBreakMode = NSLineBreakByTruncatingTail;
    _labelMessage.textAlignment = NSTextAlignmentLeft;
    [_labelMessage setFont:[UIFont systemFontOfSize:13]];
//    [_labelMessage setMinimumFontSize:12];
    [self addSubview:self.labelMessage];
    
    y += titleHeight + 20;
    CGRect frame = self.frame;
    frame.size.height = y;
    self.frame = frame;
}

- (void)setTitleColor:(UIColor *)color {
    [self.labelTitle setTextColor:color];
}

- (void)setMessageColor:(UIColor *)color {
    [self.labelMessage setTextColor:color];
}

- (void)setTitleAlignment:(NSTextAlignment)alignment {
    [self.labelTitle setTextAlignment:alignment];
}

- (void)setMessageAlignment:(NSTextAlignment)alignment {
    [self.labelMessage setTextAlignment:alignment];
}


- (UIView *)addVerifyIdentidyView {
    CGRect frame = CGRectMake(20, self.frame.size.height - 5, self.labelMessage.frame.size.width, 70);
    UIView *inputView = [[UIView alloc] initWithFrame:frame];
    inputView.layer.borderWidth = TT_IS_RETINA ? 0.6f : 1.0f;
    inputView.layer.borderColor = TTHexColor(0xd5d5db).CGColor;
    inputView.layer.cornerRadius = 7.0;
    inputView.clipsToBounds = YES;
    inputView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    CGFloat x = 6.0;
    _tfAccount = [[MGUITextField_XLine alloc] initWithFrame:CGRectMake(x, 0, frame.size.width-2*x , frame.size.height/2)];
    _tfAccount.placeholder = @"请输入您的真实姓名";
    [MGUtility setTextField:_tfAccount leftTitle:@"姓  名 :" leftWidth:I_PAD ? 60.0 : 50.0];
    _tfAccount.font =  I_PAD ? iPad_Font16 : iPhone_Font13;
    
    _tfAccount.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _tfAccount.keyboardType = UIKeyboardTypeDefault;
    _tfAccount.autocorrectionType = UITextAutocorrectionTypeNo;
    _tfAccount.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _tfAccount.returnKeyType = UIReturnKeyNext;
    _tfAccount.delegate = self;
    _tfAccount.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight;
    [_tfAccount setTag:kDialogFirstTextFieldTag];
    [inputView addSubview:_tfAccount];
    
    _tfSecret = [[UITextField alloc] initWithFrame:CGRectMake(x, frame.size.height/2, frame.size.width - 2*x, frame.size.height/2)];
    _tfSecret.placeholder = @"请输入您的身份证号";
//    _tfSecret.secureTextEntry = YES;
    _tfSecret.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _tfSecret.returnKeyType = UIReturnKeyDone;
    _tfSecret.delegate = self;
    _tfSecret.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleHeight;
    _tfSecret.font = I_PAD ? iPad_Font16 : iPhone_Font13;
    [_tfSecret setTag:kDialogSecTextFieldTag];
    
    [MGUtility setTextField:_tfSecret leftTitle:@"身份证 :" leftWidth:I_PAD ? 60.0 : 50.0];
    [inputView addSubview:self.tfSecret];
    [self addSubview:inputView];
    
    
    CGRect frame1 = self.frame;
    frame1.size.height = inputView.frame.origin.y + inputView.frame.size.height + 15;
    self.frame = frame1;
    return inputView;
}


- (void)dealloc {
    self.tfAccount.delegate = nil;
    self.tfSecret.delegate = nil;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.tfAccount) {
        [self.tfSecret becomeFirstResponder];
    } else if (textField == self.tfSecret) {
        [textField resignFirstResponder];
        [self.alertVC containerViewEndEditing];
    }
    return YES;
}

@end


