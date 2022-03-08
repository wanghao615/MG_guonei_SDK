//
//  MGSalesAccountView.m
//  MGSDKTest
//
//  Created by 沈和平 on 2020/2/21.
//  Copyright © 2020 xyzs. All rights reserved.
//

#import "MGSalesAccountView.h"
#import "MGHttpClient.h"

@interface MGSalesAccountView() <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIView *bgV;
@property (weak, nonatomic) IBOutlet UIButton *closeBtn;

@property (weak, nonatomic) IBOutlet UITextField *tf;
@property (weak, nonatomic) IBOutlet UIButton *sureBtn;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;




- (IBAction)closeClick:(UIButton *)sender;
- (IBAction)sureBtnClick:(UIButton *)sender;
- (IBAction)cancelClick:(UIButton *)sender;

@property (copy, nonatomic) NSString *accountStr;

@end

@implementation MGSalesAccountView

+ (instancetype)salesAccountViewWithAccount:(NSString *)accountStr; {
    MGSalesAccountView *salesAccountView = [[NSBundle mainBundle] loadNibNamed:@"MGSalesAccountView" owner:nil options:nil][0];
    salesAccountView.frame = [UIApplication sharedApplication].keyWindow.bounds;
    salesAccountView.accountStr = accountStr;
    salesAccountView.bgV.layer.cornerRadius = 8.0;
    salesAccountView.tf.layer.borderWidth = 0.8;
    salesAccountView.tf.layer.cornerRadius = 4.0;
    salesAccountView.tf.delegate = salesAccountView;
    salesAccountView.layer.borderColor = [UIColor colorWithRed:150/225.0 green:152.0/255.0 blue:151.0/255.0 alpha:1.0].CGColor;
    salesAccountView.sureBtn.layer.borderWidth = 0.8;
    salesAccountView.sureBtn.layer.borderColor = [UIColor colorWithRed:234.0/225.0 green:115.0/255.0 blue:0/255.0 alpha:1.0].CGColor;
    salesAccountView.sureBtn.layer.cornerRadius = 20.0;
    salesAccountView.cancelBtn.layer.cornerRadius = 20.0;
    return salesAccountView;
}

- (IBAction)closeClick:(UIButton *)sender {
    [self removeFromSuperview];
}

- (IBAction)sureBtnClick:(UIButton *)sender {
    
    if (![self.tf.text isEqualToString:@"确认注销"]) {
        [MGSVProgressHUD showErrorWithStatus:@"输入错误，请仔细阅读上方提示！"];
        return;
    }
    
    [MGSVProgressHUD showWithStatus:@"正在销户中..." maskType:MGSVProgressHUDMaskTypeClear];
    
    [[MGHttpClient shareMGHttpClient] cancellationAccountCompletion:^(NSDictionary *responseDic) {
        
        [MGSVProgressHUD showWithStatus:@"销户成功" maskType:MGSVProgressHUDMaskTypeClear];
        
        [MGStorage removeAccountSettingInfoByAccount:self.accountStr];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.35 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self removeFromSuperview];
            [[MGManager defaultManager] performSelector:@selector(MGSwitchAccount) withObject:nil afterDelay:0];
        });
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [MGSVProgressHUD dismiss];
        });
        
    } failed:^(NSInteger ret, NSString *errMsg) {
        
        NSString *err = [NSString stringWithFormat:@"账号销户失败，%@", errMsg];
        [MGSVProgressHUD showErrorWithStatus:err];
        
    }];
    
}

- (IBAction)cancelClick:(UIButton *)sender {
     [self removeFromSuperview];
}


#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [UIView animateWithDuration:0.25 animations:^{
        self.bgV.transform = CGAffineTransformMakeTranslation(0, -65);
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [UIView animateWithDuration:0.25 animations:^{
        self.bgV.transform = CGAffineTransformIdentity;
     }];
    [self.tf resignFirstResponder];
}
@end
