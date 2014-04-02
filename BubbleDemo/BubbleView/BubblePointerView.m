//
//  BubblePointerView.m
//  BubbleDemo
//
//  Created by lvpw on 14-4-1.
//  Copyright (c) 2014年 pengwei.lv. All rights reserved.
//

#import "BubblePointerView.h"

@interface BubblePointerView ()

@property (nonatomic) float oldX, oldY;

@end

@implementation BubblePointerView

#pragma mark - Life Cycle

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBStrokeColor(context,1,1,1,1.0); // 画笔线的颜色
    CGContextSetLineWidth(context, 1.0); // 线的宽度
    CGContextAddArc(context, 100, 20, 15, 0, 2 * M_PI, 0); //添加一个圆
    CGContextDrawPath(context, kCGPathStroke); //绘制路径
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchLocation = [touch locationInView:self];
    self.oldX = touchLocation.x;
    self.oldY = touchLocation.y;
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesMoved:touches withEvent:event];
    float deltaX = [[touches anyObject]locationInView:self].x - self.oldX;
    float deltaY = [[touches anyObject]locationInView:self].y - self.oldY;
    self.transform = CGAffineTransformTranslate(self.transform, deltaX, deltaY);
}

@end
