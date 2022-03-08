//
//  MGPullDown.m
//  MGPlatformTest
//
//  Created by caosq on 14-7-3.
//  Copyright (c) 2014年 qmqj. All rights reserved.
//

#import "MGPullDown.h"
#import "UIView+MGHandleFrame.h"

@interface MGPullDownCancelButton : UIButton

@property (nonatomic, strong) NSIndexPath *indexPath;

@end

@implementation MGPullDownCancelButton

@end



@interface MGPullDown ()

@end

@implementation MGPullDown

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = I_PHONE ? 30.0 : 42.0;
    
    self.tableView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.tableView.layer.borderWidth = 0.5;
    self.tableView.layer.cornerRadius = 5.0;
    
}

- (void) setRowHeight:(CGFloat)rowHeight
{
    if (_rowHeight != rowHeight) {
        _rowHeight = rowHeight;
        self.tableView.rowHeight = _rowHeight;
        [self.tableView reloadData];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  [self.pulldownLists count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"MG_down_cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MG_down_cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        
        if (self.bShowCancelActionButton) {
            MGPullDownCancelButton *btnCancel = [MGPullDownCancelButton buttonWithType:UIButtonTypeCustom];
            [btnCancel setImage:[MGUtility MGImageName:@"MG_nav_close"] forState:UIControlStateNormal];
            btnCancel.frame = CGRectMake(tableView.bounds.size.width - 35.0, I_PHONE ? 0 : 0 , 35.0, 35.0);
            [cell.contentView addSubview:btnCancel];
            [btnCancel addTarget:self action:@selector(doRemoveItemAction:) forControlEvents:UIControlEventTouchUpInside];
            btnCancel.tag = 101;
        }
    }
    cell.textLabel.font = I_PHONE ? [UIFont systemFontOfSize:13] : [UIFont systemFontOfSize:16.0];
    cell.textLabel.textColor = I_PHONE ? TTHexColor(0x676974) : [UIColor blackColor];
    
    NSString *accountStr = self.pulldownLists[indexPath.row];
      if (accountStr.length == 11 && [[accountStr substringToIndex:1] intValue] == 1) {
           cell.textLabel.text = [accountStr stringByReplacingCharactersInRange:NSMakeRange(3, 4) withString:@"****"];
      }else {
          cell.textLabel.text = accountStr;
      }

    MGPullDownCancelButton *btn =  (MGPullDownCancelButton *)[cell.contentView viewWithTag:101];
    if (btn) {
        if (self.bShowCancelActionButton) {
            [btn setHidden:NO];
            btn.indexPath = indexPath;
        }else
            [btn setHidden:YES];
            
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell setBackgroundColor:[UIColor clearColor]];
    return cell;
}


- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_delegate && [_delegate respondsToSelector:@selector(MGPullDown:selectedItem:)]) {
         NSString *accountStr = self.pulldownLists[indexPath.row];
         self.realAccountStr = accountStr;
         if (accountStr.length == 11 && [[accountStr substringToIndex:1] intValue] == 1) {
             [_delegate MGPullDown:self selectedItem:[accountStr stringByReplacingCharactersInRange:NSMakeRange(3, 4) withString:@"****"]];
         }else {
             [_delegate MGPullDown:self selectedItem:accountStr];
         }
     }
     [self.view removeFromSuperview];
}


- (void) doRemoveItemAction:(MGPullDownCancelButton *) btn
{
    
    __weak typeof(self) weakSelf = self;
    MGAlertCustomView *alerView = [[MGAlertCustomView alloc]alerViewWithMessige:@"确认删除账号吗？" withType:AlertTypeWithSureandCancel];
    __weak typeof(alerView) weakalert = alerView;
    alerView.handler = ^(NSInteger index){
        if (index == 0) {
            [weakalert dissmiss];
        }else {
            NSMutableArray *M = [NSMutableArray arrayWithArray:weakSelf.pulldownLists];
            if (btn.indexPath.row >= [M count]) {
                return;
            }
            id obj = [weakSelf.pulldownLists objectAtIndex:btn.indexPath.row];
            if ([M containsObject:obj]) {
                [M removeObject:obj];
            }
            weakSelf.pulldownLists = M;
            weakSelf.realAccountStr = obj;
            
            [weakSelf.tableView beginUpdates];
            [weakSelf.tableView deleteRowsAtIndexPaths:@[btn.indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [weakSelf.tableView endUpdates];
            [weakSelf.tableView reloadData];
            
            [weakSelf resize];
            
            if (_delegate && [_delegate respondsToSelector:@selector(MGPullDown:removeItem:)]) {
                [_delegate MGPullDown:weakSelf removeItem:obj];
            }
            [weakalert dissmiss];
        }
    };
    [alerView show];
    
    
}

- (void) resize
{
    CGFloat h = self.tableView.rowHeight * [self.pulldownLists count];
    CGRect frame = self.view.frame;
    frame.size.height = h;
    self.view.frame = frame;
}


- (void) presentPullDownFromRect:(CGRect) rect inView:(UIView *) view
{
    
    if (self.view.superview == nil) {
        [self.tableView reloadData];
        CGFloat h = self.tableView.rowHeight * [self.pulldownLists count];
        if (rect.size.height + rect.origin.y > view.bounds.size.height) {
            h = view.bounds.size.height - rect.size.height - rect.origin.y;
        }
        
        self.view.frame = CGRectMake(rect.origin.x, rect.origin.y + rect.size.height - 2.0, rect.size.width, 0);
        [view addSubview:self.view];
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            self.view.frame = CGRectMake(rect.origin.x, rect.origin.y + rect.size.height - 2.0, rect.size.width, h);
        } completion:nil];
        
    }else {
        [self dismissPullDown];
    }
}


- (void) presentPullDownFromView:(UIView *) fromView inView:(UIView *) view
{
    
    CGRect rect = fromView.frame;
    
    if (self.view.superview == nil) {
        [self.tableView reloadData];
        CGFloat h = self.tableView.rowHeight * [self.pulldownLists count];
        if (rect.size.height + rect.origin.y > view.bounds.size.height) {
            h = view.bounds.size.height - rect.size.height - rect.origin.y;
        }
        
        self.view.frame = CGRectMake(rect.origin.x, rect.origin.y + rect.size.height - 2.0, rect.size.width, 0);
        
        [view bringSubviewToFront:fromView];
        
        [view insertSubview:self.view belowSubview:fromView];
        
//        [view addSubview:self.view];
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            self.view.frame = CGRectMake(rect.origin.x, rect.origin.y + rect.size.height - 2.0, rect.size.width, h);
        } completion:nil];
        
    }else {
        [self dismissPullDown];
    }
}

- (void)presentPullDownToRect:(CGRect)rect inView:(UIView *)view {
    if (self.view.superview == nil) {
        [self.tableView reloadData];
        
        CGRect finalRect = [self calculateRectWith:rect inView:view];
        self.view.frame = finalRect;
        [self.view setHeight:0];
        [view addSubview:self.view];
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            self.view.frame = finalRect;
        } completion:^(BOOL finished) {
            [self.tableView scrollRectToVisible:CGRectMake(0, 0, self.tableView.frame.size.width, self.tableView.rowHeight) animated:YES];
        }];
    } else {
        [self dismissPullDown];
    }
}

- (CGRect)calculateRectWith:(CGRect)rect inView:(UIView *)view {
    
    CGFloat h = self.tableView.rowHeight * [self.pulldownLists count];
    if (rect.origin.y + rect.size.height > view.frame.size.height) {
        h = view.bounds.size.height - rect.origin.y;
    } else {
        if (h < rect.size.height) {
            
        } else {
            h = rect.size.height;
        }
    }
    
    return CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, h);
}

- (void)dismissPullDown {
    [UIView animateWithDuration:.2f animations:^{
        [self.view setHeight:0];
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
    }];
}


@end
