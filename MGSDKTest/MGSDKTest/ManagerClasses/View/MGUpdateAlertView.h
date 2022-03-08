//
//  UpdateAlertView.h
//  Installer
//
//  Created by 彭胜军 on 14-5-7.
//

#import <UIKit/UIKit.h>



@interface MGUpdateAlertView : UIView
{
    UIView *aletViews;
    id reloadobjects;
    SEL reloadAction;
    SEL cancelAction;
}




- (instancetype)initWithAlertView:(NSString *)title
                  message:(NSString *)message
                   cancel:(NSString *)cancelBtnTitle
                   action:(NSString *)actionBtnTitle
              relodMethod:(SEL)method
                  objects:(id)object;


- (instancetype)initWithAlertView:(NSString *)title
                          message:(NSString *)message
                           cancel:(NSString *)cancelBtnTitle
                           action:(NSString *)actionBtnTitle
                     cancelAction:(SEL)cMethod
                      relodMethod:(SEL)method
                          objects:(id)object;



- (instancetype)initWithAlertViewCancel:(NSString *)title
                        message:(NSString *)message
                         cancel:(NSString *)cancelBtnTitle
                         action:(NSString *)actionBtnTitle
                    relodMethod:(SEL)method
                   cancelMethod:(SEL)cancel
                        objects:(id)object;

- (void) show;

@end
