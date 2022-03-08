//
//  MGScrollView.m
//  MGPlatformTest
//
//  Created by 曹 胜全 on 6/12/14.
//  Copyright (c) 2014 Eason. All rights reserved.
//

#import "MGScrollView.h"

@implementation MGScrollView

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(!self.dragging)
    {
        [[self nextResponder] touchesBegan:touches withEvent:event];
    }
    [super touchesBegan:touches withEvent:event];
}


- (void) setContentOffset:(CGPoint)contentOffset animated:(BOOL)animated
{
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        [self setContentOffset:contentOffset];
    } completion:nil];
}

@end
