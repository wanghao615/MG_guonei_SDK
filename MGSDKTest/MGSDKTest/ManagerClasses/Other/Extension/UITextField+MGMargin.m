//
//  UITextField+Margin.m
//
//
//  Created by 曹 胜全 on 5/24/14.
//  Copyright (c) 2014 . All rights reserved.
//

#import "UITextField+MGMargin.h"
#import <objc/runtime.h>


@interface UITextField(Private)

@property (nonatomic, copy) NSString *normalImageName;
@property (nonatomic, copy) NSString *selectedImageName;

@end


@implementation UITextField (Margin)

static char tf_margin_right_key;
static char textfield_margin_key;
static char bgimageedgeinsets_key;
static char selectedImageName_key;
static char normalImageName_key;


- (void) setNormalImageName:(NSString *)normalImageName
{
    objc_setAssociatedObject(self,
                             &normalImageName_key,
                             normalImageName,
                             OBJC_ASSOCIATION_ASSIGN);
}

- (NSString *) normalImageName
{
    NSString *s = objc_getAssociatedObject(self,
                                           &normalImageName_key);
    return s;
}



- (void) setSelectedImageName:(NSString *)selectedImageName
{
    objc_setAssociatedObject(self,
                             &selectedImageName_key,
                             selectedImageName,
                             OBJC_ASSOCIATION_ASSIGN);
}

- (NSString *) selectedImageName
{
    NSString *s = objc_getAssociatedObject(self,
                                              &selectedImageName_key);
    return s;
}



- (void) setRightMargin:(CGFloat)aLeftMargin
{
    [self willChangeValueForKey:@"rightMargin"];
    objc_setAssociatedObject(self,
                             &tf_margin_right_key,
                             [NSNumber numberWithFloat:aLeftMargin],
                             OBJC_ASSOCIATION_ASSIGN);
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, aLeftMargin, self.bounds.size.height)];
    [label setBackgroundColor:[UIColor clearColor]];
    label.text = nil;
    self.rightView = label;
    self.rightViewMode = UITextFieldViewModeAlways;
    [self didChangeValueForKey:@"rightMargin"];
}

- (CGFloat) rightMargin
{
    id aLeftMargin = objc_getAssociatedObject(self,
                                              &tf_margin_right_key);
    return [aLeftMargin floatValue];;
}



- (void) setLeftMargin:(CGFloat)aLeftMargin
{
    [self willChangeValueForKey:@"leftMargin"];
    objc_setAssociatedObject(self,
                             &textfield_margin_key,
                             [NSNumber numberWithFloat:aLeftMargin],
                             OBJC_ASSOCIATION_ASSIGN);
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, aLeftMargin, self.bounds.size.height)];
    [label setBackgroundColor:[UIColor clearColor]];
    label.text = nil;
    self.leftView = label;
    self.leftViewMode = UITextFieldViewModeAlways;
    [self didChangeValueForKey:@"leftMargin"];
}

- (CGFloat) leftMargin
{
    id aLeftMargin = objc_getAssociatedObject(self,
                                             &textfield_margin_key);
    return [aLeftMargin floatValue];;
}


- (void) setBgImageEdgeInsets:(UIEdgeInsets)bgImageEdgeInsets
{
    [self willChangeValueForKey:@"bgImageEdgeInsets"];
    NSString *insets = NSStringFromUIEdgeInsets(bgImageEdgeInsets);
    objc_setAssociatedObject(self,
                             &bgimageedgeinsets_key,
                             insets,
                             OBJC_ASSOCIATION_ASSIGN);
    [self didChangeValueForKey:@"bgImageEdgeInsets"];
}

- (UIEdgeInsets) bgImageEdgeInsets
{
    NSString *bgInset = objc_getAssociatedObject(self,
                                              &bgimageedgeinsets_key);
    UIEdgeInsets edgeInset = UIEdgeInsetsFromString(bgInset);
    
    if (UIEdgeInsetsEqualToEdgeInsets(edgeInset, UIEdgeInsetsZero)) {
        edgeInset = UIEdgeInsetsMake(10, 10, 10, 10);
    }
    return edgeInset;
}

- (void) setBackgroundNormalStateImageName:(NSString *) nImageName andSelectedStateImageName:(NSString *) sImageName
{
    [self setNormalImageName:nImageName];
    [self setSelectedImageName:sImageName];
    [self setBackground:[[UIImage imageNamed:nImageName] resizableImageWithCapInsets:[self bgImageEdgeInsets]]];
    
    [self addTarget:self action:@selector(didBegin:) forControlEvents:UIControlEventEditingDidBegin];

    [self addTarget:self action:@selector(didEnd:) forControlEvents:UIControlEventEditingDidEnd];
    
}

- (void) didEnd:(id)sender
{
    if ([[self normalImageName] length] > 0) {
       [self setBackground:[[UIImage imageNamed:[self normalImageName]] resizableImageWithCapInsets:[self bgImageEdgeInsets]]];
    }
}

- (void) didBegin:(id)sender
{
    if ([[self selectedImageName] length] > 0){
        [self setBackground:[[UIImage imageNamed:[self selectedImageName]] resizableImageWithCapInsets:[self bgImageEdgeInsets]]];
    }
}


@end
