//
//  UpdateAlertView.m
//  Installer
//
//  Created by 彭胜军 on 14-5-7.
//

#import "MGUpdateAlertView.h"
#import <QuartzCore/QuartzCore.h>
#import <WebKit/WebKit.h>

@implementation MGUpdateAlertView

#define maxHight 200.0f
#define minHight 40.0f
#define ScreenHeight [[UIScreen mainScreen] bounds].size.height
#define ScreenWidth [[UIScreen mainScreen] bounds].size.width
#define StateBarHeight 20
#define MainHeight (ScreenHeight - StateBarHeight)
#define MainWidth ScreenWidth


-(instancetype) init
{
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recieveStatusBarOriNoti:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
        
    }
    return self;
}


- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (instancetype)initWithAlertView:(NSString *)title
                          message:(NSString *)message
                           cancel:(NSString *)cancelBtnTitle
                           action:(NSString *)actionBtnTitle
                     cancelAction:(SEL)cMethod
                      relodMethod:(SEL)method
                          objects:(id)object
{
    self = [self init];
    if (self) {
        cancelAction = cMethod;
        [self initWithAlertViewX:title message:message cancel:cancelBtnTitle action:actionBtnTitle relodMethod:method objects:object];
    }
    return self;
}


- (instancetype)initWithAlertView:(NSString *)title
                          message:(NSString *)message
                           cancel:(NSString *)cancelBtnTitle
                           action:(NSString *)actionBtnTitle
                      relodMethod:(SEL)method
                          objects:(id)object
{
    self = [self init];
    if (self) {
        [self initWithAlertViewX:title message:message cancel:cancelBtnTitle action:actionBtnTitle relodMethod:method objects:object];
    }
    return self;
}


- (instancetype)initWithAlertViewCancel:(NSString *)title
                                message:(NSString *)message
                                 cancel:(NSString *)cancelBtnTitle
                                 action:(NSString *)actionBtnTitle
                            relodMethod:(SEL)method
                           cancelMethod:(SEL)cancel
                                objects:(id)object
{
    self = [self init];
    if (self) {
        [self initWithAlertViewCancelX:title message:message cancel:cancelBtnTitle action:actionBtnTitle relodMethod:method cancelMethod:cancel objects:object];
    }
    return self;
}



- (void)hideDelayed:(UIView *)alertView
{
    
    if (alertView==nil) {
        return;
    }
    
    [UIView animateWithDuration:.25 animations:^{
//        alertView.transform = CGAffineTransformMakeScale(1.3, 1.3);
        alertView.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (finished) {
            [alertView removeFromSuperview];
            alertView.alpha = 0;
            [self removeFromSuperview];
        }
    }];
}

- (void) recieveStatusBarOriNoti:(NSNotification *) noti
{
    [self fitTransform];
}


- (void) fitTransform
{
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    CGSize size = [[UIScreen mainScreen] bounds].size;
    
    if ((IPHONE_8_UP) && (__IPHONE_OS_8_0)) {
        self.frame = [[UIScreen mainScreen] bounds];
        aletViews.center = self.center;
    }else{
    
        if (UIInterfaceOrientationIsLandscape(orientation)) {
            CGFloat w = size.width;
            size.width = size.height;
            size.height = w;
        }
    
        if (orientation == UIInterfaceOrientationLandscapeLeft) {
            [aletViews setTransform:CGAffineTransformMake(0, -1, 1, 0, 0, 0)];
        }else if (orientation == UIInterfaceOrientationLandscapeRight){
            [aletViews setTransform:CGAffineTransformMake(0, 1, -1, 0, 0, 0)];
        }else if (orientation == UIInterfaceOrientationPortrait){
            aletViews.transform = CGAffineTransformIdentity;
        }else if (orientation == UIInterfaceOrientationPortraitUpsideDown){
            aletViews.transform = CGAffineTransformMake(-1, 0, -0, -1, 0, 0);
        }
    }
    
    //    self.frame = CGRectMake(0, 0, size.width, size.height);
    
}

- (void)initWithAlertViewX:(NSString *)title
                  message:(NSString *)message
                   cancel:(NSString *)cancelBtnTitle
                   action:(NSString *)actionBtnTitle
              relodMethod:(SEL)method
                  objects:(id)object{
    
    reloadobjects=object;
    reloadAction=method;
    
    self.backgroundColor = [UIColor colorWithRed:.16 green:.17 blue:.21 alpha:0.5];
    self.alpha=0.5;
    
    
    if (message == nil || message.length == 0) {
        message=NSLocalizedString(@"检测到新的版本，建议您升级！", nil);
    }
    
//    CGSize cgtitlesize=[title sizeWithFont:[UIFont systemFontOfSize:17.0f]
//                         constrainedToSize:CGSizeMake(280, maxHight)
//                             lineBreakMode:NSLineBreakByWordWrapping];
    CGSize cgtitlesize = [title boundingRectWithSize:CGSizeMake(280, maxHight) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:17.0f]} context:0].size;
    
    CGFloat theight=cgtitlesize.height>maxHight?maxHight:cgtitlesize.height;
    
    
    aletViews =[[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, 210+theight)];
    aletViews.layer.borderColor = [[UIColor whiteColor] CGColor];
    aletViews.layer.borderWidth = 1.0f;
    aletViews.layer.cornerRadius = 8.0f;
    aletViews.alpha=1;
    aletViews.clipsToBounds = TRUE;
    aletViews.backgroundColor=[UIColor whiteColor];
    
    
    UILabel *lab_title=[[UILabel alloc] initWithFrame:CGRectMake(10, 7, 260, theight)];
    lab_title.font=[UIFont boldSystemFontOfSize:17.0f];
    lab_title.textColor=[UIColor blackColor];
    lab_title.backgroundColor=[UIColor clearColor];
    lab_title.text=title;
    lab_title.numberOfLines = 3;
    lab_title.textAlignment = TTTextAlignCenter;
    [aletViews addSubview:lab_title];
    
    NSString *htmlStr=[NSString stringWithFormat:@"<div>%@</div>",message];
    
    WKWebView *lab_messag=[[WKWebView alloc] initWithFrame:CGRectMake(5, theight+18, 270, 145)];

    [lab_messag loadHTMLString:htmlStr baseURL:nil];
    lab_messag.backgroundColor=[UIColor clearColor];
    [aletViews addSubview:lab_messag];
    
    
    for (UIView *_aView in [lab_messag subviews])
    {
        if ([_aView isKindOfClass:[UIScrollView class]])
        {
            [(UIScrollView *)_aView setShowsVerticalScrollIndicator:NO];
            //右侧的滚动条
            
            [(UIScrollView *)_aView setShowsHorizontalScrollIndicator:NO];
            //下侧的滚动条
            
            for (UIView *_inScrollview in _aView.subviews)
            {
                if ([_inScrollview isKindOfClass:[UIImageView class]])
                {
                    _inScrollview.hidden = YES;  //上下滚动出边界时的黑色的图片
                }
            }
        }
    }
    

    
    CALayer* boderLayer = [CALayer layer];
    boderLayer.frame = CGRectMake(0, theight+15, 280, 0.6);
    boderLayer.backgroundColor = NewHDCellSeqLineColor.CGColor;
    [aletViews.layer addSublayer:boderLayer];
    
    UIButton *btn_cannel=[UIButton buttonWithType:UIButtonTypeCustom];
    btn_cannel.frame=CGRectMake(0, aletViews.frame.size.height-44, 258, 44);
    [aletViews addSubview:btn_cannel];
    
    UIButton *btn_action=[UIButton buttonWithType:UIButtonTypeCustom];
    btn_action.frame=CGRectMake(155, aletViews.frame.size.height-44, 111, 44);
    [aletViews addSubview:btn_action];
    
    BOOL xianLg = NO;
    if (cancelBtnTitle==nil&&actionBtnTitle==nil) {
        return;
    }else if(cancelBtnTitle==nil){
        btn_action.frame=CGRectMake(0, aletViews.frame.size.height-44, 280, 44);
        btn_cannel.hidden=YES;
    }else if(actionBtnTitle==nil){
        btn_cannel.frame=CGRectMake(0, aletViews.frame.size.height-44, 280, 44);
        btn_action.hidden=YES;
    }else{
        xianLg = YES;
        btn_cannel.frame=CGRectMake(0, aletViews.frame.size.height-44, 140, 44);
        btn_action.frame=CGRectMake(140, aletViews.frame.size.height-44, 140, 44);
        
    }
    
    [btn_cannel setTitle:cancelBtnTitle forState:UIControlStateNormal];
    [btn_action setTitle:actionBtnTitle forState:UIControlStateNormal];
    [btn_cannel setTitleColor:TTHexColor(0xb6bbbe) forState:UIControlStateNormal];
    [btn_action setTitleColor:TTGlobalColor forState:UIControlStateNormal];
    [btn_cannel setTitleColor:TTGlobalColor forState:UIControlStateHighlighted];
    [btn_action setTitleColor:NewHDCellSeqLineColor forState:UIControlStateHighlighted];
    
    [btn_cannel addTarget:self action:@selector(alertViewCancel:) forControlEvents:UIControlEventTouchUpInside];
    [btn_action addTarget:self action:@selector(alertViewAction:) forControlEvents:UIControlEventTouchUpInside];

    [self addSubview:aletViews];
    
    //线线
    UIView *_lineg = [[UIView alloc] initWithFrame:CGRectMake(0, aletViews.frame.size.height-44, aletViews.frame.size.width, 0.6)];
    _lineg.backgroundColor = NewHDCellSeqLineColor;
    [aletViews addSubview:_lineg];
    
    if (xianLg) {
        UIView *_lines = [[UIView alloc] initWithFrame:CGRectMake(aletViews.frame.size.width/2, aletViews.frame.size.height-44, 0.6, 44)];
        _lines.backgroundColor = NewHDCellSeqLineColor;
        [aletViews addSubview:_lines];
    }
    
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];//关闭键盘

}

- (void) show
{
    UIWindow *rootView = [[UIApplication sharedApplication] keyWindow];
    
    
    if (IPHONE_8_UP) {
        aletViews.center = self.center;
    }else
        aletViews.center = CGPointMake(rootView.bounds.size.width/2.0f,
                                   rootView.bounds.size.height/2.0f);
    
    [self fitTransform];
    [rootView addSubview:self];
    
    self.alpha = 0.0f;
    
    [UIView animateWithDuration:.25 animations:^{
        self.alpha = 1.0;
        [rootView bringSubviewToFront:self];
    }];
}


- (void)initWithAlertViewCancelX:(NSString *)title
                        message:(NSString *)message
                         cancel:(NSString *)cancelBtnTitle
                         action:(NSString *)actionBtnTitle
                    relodMethod:(SEL)method
                   cancelMethod:(SEL)cancel
                        objects:(id)object{
    
    reloadobjects=object;
    reloadAction=method;
    cancelAction=cancel;
    
    self.frame =  [UIScreen mainScreen].bounds; // CGRectMake(0, 0, 320, ScreenHeight);
    self.backgroundColor = [UIColor colorWithRed:.16 green:.17 blue:.21 alpha:0.5];
    self.alpha=0.5;
    
    
//    CGSize cgsize=[message sizeWithFont:[UIFont systemFontOfSize:14.0f]
//                      constrainedToSize:CGSizeMake(260, maxHight)
//                          lineBreakMode:NSLineBreakByWordWrapping];
    CGSize cgsize = [message boundingRectWithSize:CGSizeMake(260, maxHight) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14.0f]} context:0].size;
    
    CGFloat height=cgsize.height>maxHight?maxHight:cgsize.height;
    
//    CGSize cgtitlesize=[title sizeWithFont:[UIFont systemFontOfSize:18.0f]
//                         constrainedToSize:CGSizeMake(260, maxHight)
//                             lineBreakMode:NSLineBreakByWordWrapping];
    CGSize cgtitlesize = [title boundingRectWithSize:CGSizeMake(260, maxHight) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:18.0f]} context:0].size;
    
    CGFloat theight=cgtitlesize.height>maxHight?maxHight:cgtitlesize.height;
    
    
    aletViews=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, height+theight+70)];
    aletViews.layer.borderColor = [[UIColor whiteColor] CGColor];
    aletViews.layer.borderWidth = 1.0f;
    aletViews.layer.cornerRadius = 8.0f;
    aletViews.alpha=1;
    aletViews.clipsToBounds = TRUE;
    aletViews.backgroundColor=[UIColor whiteColor];
    
    
    UILabel *lab_title=[[UILabel alloc] initWithFrame:CGRectMake(10, 7, 260, theight)];
    lab_title.font=[UIFont boldSystemFontOfSize:18.0f];
    lab_title.textColor=[UIColor blackColor];
    lab_title.backgroundColor=[UIColor clearColor];
    lab_title.text=title;
    lab_title.numberOfLines = 10;
    lab_title.textAlignment = TTTextAlignCenter;
    [aletViews addSubview:lab_title];
    
    
    
    UILabel *lab_messag=[[UILabel alloc] initWithFrame:CGRectMake(10, theight+10, 260, height)];
    lab_messag.text=message;
    lab_messag.font=[UIFont systemFontOfSize:14.0f];
    lab_messag.backgroundColor=[UIColor clearColor];
    lab_messag.textColor=[UIColor grayColor];
    lab_messag.userInteractionEnabled=NO;
    lab_messag.lineBreakMode = NSLineBreakByWordWrapping;
    lab_messag.numberOfLines = 10;
    lab_messag.textAlignment = TTTextAlignCenter;
    [aletViews addSubview:lab_messag];
   
    
    
    UIButton *btn_cannel=[UIButton buttonWithType:UIButtonTypeCustom];
    btn_cannel.frame=CGRectMake(0, aletViews.frame.size.height-44, 258, 44);
    [aletViews addSubview:btn_cannel];
    
    UIButton *btn_action=[UIButton buttonWithType:UIButtonTypeCustom];
    btn_action.frame=CGRectMake(155, aletViews.frame.size.height-44, 111, 44);
    [aletViews addSubview:btn_action];
    
    BOOL xianLg = NO;
    if (cancelBtnTitle==nil&&actionBtnTitle==nil) {
        return;
    }else if(cancelBtnTitle==nil){
        btn_action.frame=CGRectMake(0, aletViews.frame.size.height-44, 280, 44);
        btn_cannel.hidden=YES;
    }else if(actionBtnTitle==nil){
        btn_cannel.frame=CGRectMake(0, aletViews.frame.size.height-44, 280, 44);
        btn_action.hidden=YES;
    }else{
        xianLg = YES;
        btn_cannel.frame=CGRectMake(0, aletViews.frame.size.height-44, 140, 44);
        btn_action.frame=CGRectMake(140, aletViews.frame.size.height-44, 140, 44);
        
    }
    
    [btn_cannel setTitle:cancelBtnTitle forState:UIControlStateNormal];
    [btn_action setTitle:actionBtnTitle forState:UIControlStateNormal];
    [btn_cannel setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn_action setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn_cannel addTarget:self action:@selector(alertViewCancel:) forControlEvents:UIControlEventTouchUpInside];
    [btn_action addTarget:self action:@selector(alertViewAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIImage *buttonImage=[self setImageColor:TTRGBAColor(255, 255, 255, 1) imageSize:btn_action.frame.size cornerRadius:3.0f];
    [btn_action setBackgroundImage:buttonImage forState:0];
    
    UIImage *cannerImage=[self setImageColor:TTRGBAColor(255, 255, 255, 1) imageSize:btn_cannel.frame.size cornerRadius:3.0f];
    [btn_cannel setBackgroundImage:cannerImage forState:0];
    [self addSubview:aletViews];
    
    btn_action.contentMode=UIViewContentModeScaleAspectFit;
    btn_cannel.contentMode=UIViewContentModeScaleAspectFit;
    
    //线线
    UIView *_lineg = [[UIView alloc] initWithFrame:CGRectMake(0, aletViews.frame.size.height-44, aletViews.frame.size.width, 0.6)];
    _lineg.backgroundColor = [UIColor grayColor];
    [aletViews addSubview:_lineg];
    
    if (xianLg) {
        UIView *_lines = [[UIView alloc] initWithFrame:CGRectMake(aletViews.frame.size.width/2, aletViews.frame.size.height-44, 0.6, 44)];
        _lines.backgroundColor = [UIColor grayColor];
        [aletViews addSubview:_lines];
    }
    
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];//关闭键盘
}

+ (NSString*)stringWithNewString:(NSString*)dealString
{
    
    NSString* stringTwo =
    [dealString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    NSString* string = [stringTwo stringByReplacingOccurrencesOfString:@"<br/>"
                                                            withString:@"\n"];
    NSString* newUpdateString =
    [string stringByReplacingOccurrencesOfString:@"<p>" withString:@"\n"];
    
    NSString* newUpdateString1 = [newUpdateString stringByReplacingOccurrencesOfString:@"</br>"
                                                                            withString:@"\n"];
    NSString* newUpdateString3 = [newUpdateString1 stringByReplacingOccurrencesOfString:@"</p>"
                                                                             withString:@"\n"];
    
    
    NSString* newUpdateString2 =[newUpdateString3 stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "];
    
    
    
    newUpdateString2 = [newUpdateString2
                        stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    return newUpdateString2;
}

- (void)alertViewCancel:(id)sender
{
    [self hideDelayed:self];
    
    if (cancelAction!=nil&&[reloadobjects respondsToSelector:cancelAction]) {
        [reloadobjects performSelector:cancelAction withObject:nil afterDelay:0.3];
    }
}

- (void)alertViewAction:(id)sender
{
    [self hideDelayed:self];
    
    if (reloadAction!=nil && [reloadobjects respondsToSelector:reloadAction]) {
        [reloadobjects performSelector:reloadAction withObject:nil afterDelay:0.5];
    }
}


- (UIImage *)setImageColor:(UIColor *)color imageSize:(CGSize)size cornerRadius:(float)Radiussize{
    
    UIGraphicsBeginImageContextWithOptions(size, 0, [UIScreen mainScreen].scale);
    [color set];
    UIRectFill(CGRectMake(0, 0, size.width, size.height));
    UIImage *images = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return [self createRoundedRectImage:images cornerRadius:Radiussize];
}


- (UIImage *) createRoundedRectImage:(UIImage*)image cornerRadius:(float)Radiussize //由外部释放
{
    // the size of CGContextRef
    
    int w = image.size.width;
    int h = image.size.height;
    
    UIImage *img = image;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, w, h, 8, 4 * w, colorSpace, kCGImageAlphaPremultipliedFirst);
    CGRect rect = CGRectMake(0, 0, w, h);
    
    CGContextBeginPath(context);
    addRoundedRectToPath(context, rect, Radiussize, Radiussize);
    CGContextClosePath(context);
    CGContextClip(context);
    CGContextDrawImage(context, CGRectMake(0, 0, w, h), img.CGImage);
    CGImageRef imageMasked = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    UIImage *rounedImage = [[UIImage alloc] initWithCGImage:imageMasked];
    CGImageRelease(imageMasked);
    return rounedImage ;
}

static void addRoundedRectToPath(CGContextRef context, CGRect rect, float ovalWidth,
                                 float ovalHeight)
{
    float fw,fh;
    if (ovalWidth == 0 || ovalHeight == 0) {
        CGContextAddRect(context, rect);
        return;
    }
    
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGContextScaleCTM(context, ovalWidth, ovalHeight);
    fw = CGRectGetWidth(rect) / ovalWidth;
    fh = CGRectGetHeight(rect) / ovalHeight;
    
    CGContextMoveToPoint(context, fw, fh/2);  // Start at lower right corner
    CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1);  // Top right corner
    CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1); // Top left corner
    CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1); // Lower left corner
    CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1); // Back to lower right
    
    CGContextClosePath(context);
    CGContextRestoreGState(context);
}


@end
