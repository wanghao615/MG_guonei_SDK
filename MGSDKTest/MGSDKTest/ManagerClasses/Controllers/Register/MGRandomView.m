//
//  MGRandomView.m
//  MGPlatformTest
//
//  Created by ZYZ on 17/1/20.
//  Copyright © 2017年 MGzs. All rights reserved.
//

#import "MGRandomView.h"

@implementation MGRandomView
@synthesize changeArray = _changeArray;
@synthesize changeString = _changeString;
@synthesize codeLabel = _codeLabel;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        float red = arc4random() % 100 / 100.0;
        float green = arc4random() % 100 / 100.0;
        float blue = arc4random() % 100 / 100.0;
        UIColor *color = [UIColor colorWithRed:red green:green blue:blue alpha:0.2];
        self.backgroundColor = color;
        [self change];
    }
    return self;
}

-(NSString *)changeCode
{
   NSString *resultStr =  [self change];
    [self setNeedsDisplay];
    
    return resultStr;
}

- (NSString *)change
{
    self.changeArray = [[NSArray alloc] initWithObjects:@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",nil];
    
    NSMutableString *getStr = [[NSMutableString alloc] initWithCapacity:5];
    
    self.changeString = [[NSMutableString alloc] initWithCapacity:6];
    for(NSInteger i = 0; i < 4; i++)
    {
        NSInteger index = arc4random() % ([self.changeArray count] - 1);
        getStr = [self.changeArray objectAtIndex:index];
        
        self.changeString = (NSMutableString *)[self.changeString stringByAppendingString:getStr];
    }
    return self.changeString;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    float red = arc4random() % 100 / 100.0;
    float green = arc4random() % 100 / 100.0;
    float blue = arc4random() % 100 / 100.0;
    
    UIColor *color = [UIColor colorWithRed:red green:green blue:blue alpha:0.5];
    [self setBackgroundColor:color];
    
    NSString *text = [NSString stringWithFormat:@"%@",self.changeString];
    CGSize cSize = [@"S" sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:20]}];
    int width = rect.size.width / text.length - cSize.width;
    int height = rect.size.height - cSize.height;
    CGPoint point;
    
    float pX, pY;
    for (int i = 0; i < text.length; i++)
    {
        pX = arc4random() % width + rect.size.width / text.length * i;
        pY = arc4random() % height;
        point = CGPointMake(pX, pY);
        unichar c = [text characterAtIndex:i];
        NSString *textC = [NSString stringWithFormat:@"%C", c];
        [textC drawAtPoint:point withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:20]}];
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 1.0);
    for(int cout = 0; cout < 10; cout++)
    {
        red = arc4random() % 100 / 100.0;
        green = arc4random() % 100 / 100.0;
        blue = arc4random() % 100 / 100.0;
        color = [UIColor colorWithRed:red green:green blue:blue alpha:0.2];
        CGContextSetStrokeColorWithColor(context, [color CGColor]);
        pX = arc4random() % (int)rect.size.width;
        pY = arc4random() % (int)rect.size.height;
        CGContextMoveToPoint(context, pX, pY);
        pX = arc4random() % (int)rect.size.width;
        pY = arc4random() % (int)rect.size.height;
        CGContextAddLineToPoint(context, pX, pY);
        CGContextStrokePath(context);
    }
}
@end


