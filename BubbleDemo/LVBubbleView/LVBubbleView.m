//
//  CustomTouchView.m
//  BubbleDemo
//
//  Created by lvpw on 14-4-1.
//  Copyright (c) 2014年 pengwei.lv. All rights reserved.
//

#import "LVBubbleView.h"

#pragma mark - LVBubbleView

@interface LVBubbleView () <LVBubblePointerViewProtocol, LVTextBubbleViewProtocol>

@property (nonatomic, strong) LVBubblePointerView *bubblePointerView; // 可拖动的小圆
@property (nonatomic) CGPoint targetPoint; // 小圆的中心点
@property (nonatomic) CGPoint textBubbleViewCenterPoint; // bubble的中心点

@end

@implementation LVBubbleView

#pragma mark - LVTextBubbleViewProtocol

- (void)textBubbleViewDidmoved:(LVTextBubbleView *)textBubbleView
{
    self.textBubbleViewCenterPoint = CGPointMake(CGRectGetMidX(textBubbleView.frame), CGRectGetMidY(textBubbleView.frame));
    [self setNeedsDisplay];
}

- (void)textBubbleViewDidChanged:(LVTextBubbleView *)textBubbleView
{
    self.textBubbleViewCenterPoint = CGPointMake(CGRectGetMidX(textBubbleView.frame), CGRectGetMidY(textBubbleView.frame));
    [self setNeedsDisplay];
}

#pragma mark - LVBubblePointerViewProtocol

- (void)bubblePointerViewDidMoved:(LVBubblePointerView *)bubblePointerView
{
    self.targetPoint = CGPointMake(CGRectGetMidX(bubblePointerView.frame), CGRectGetMidY(bubblePointerView.frame));
    [self setNeedsDisplay];
}

#pragma mark - Life Cycle

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // init LVBubblePointerView
        LVBubblePointerView *bubblePointerView = [[LVBubblePointerView alloc] init];
        bubblePointerView.bounds = CGRectMake(0, 0, 50, 50);
        bubblePointerView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds)+100);
        bubblePointerView.backgroundColor = [UIColor clearColor];
        bubblePointerView.delegate = self;
        [self addSubview:bubblePointerView];
        self.bubblePointerView = bubblePointerView;
        
        // init LVTextBubbleView
        LVTextBubbleView *textBubbleView = [[LVTextBubbleView alloc] initWithFrame:CGRectMake(0, 0, 85, 60)];
        textBubbleView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
        textBubbleView.backgroundColor = [UIColor clearColor];
        textBubbleView.maxWidth = 100;
        textBubbleView.delegate = self;
        [self addSubview:textBubbleView];
        self.textBubbleView = textBubbleView;
        
        self.textBubbleViewCenterPoint = self.textBubbleView.center;
        self.targetPoint = self.bubblePointerView.center;
    }
    return self;
}

#pragma mark - override

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *tmpView = [super hitTest:point withEvent:event];
    if (tmpView == self) {
        return nil;
    }
    return tmpView;
}

- (void)setNeedsDisplay
{
    [super setNeedsDisplay];
    self.textBubbleView.bubbleType = self.bubbleType;
    [self.textBubbleView setNeedsDisplay];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    float x_scale = self.textBubbleView.x_scale;
    float y_scale = self.textBubbleView.y_scale;
    float textBubbleViewFrameX = self.textBubbleView.frame.origin.x;
    float textBubbleViewFrameY = self.textBubbleView.frame.origin.y;
    float x1 = self.targetPoint.x;
    float y1 = self.targetPoint.y;
    float x2 = self.textBubbleViewCenterPoint.x;
    float y2 = self.textBubbleViewCenterPoint.y;
    float k, b;
    if ((x2-x1)==0) {
        k=0;
        b=x1;
    } else {
        k = (y2-y1)/(x2-x1);
        b = y1-(y2-y1)*x1/(x2-x1);
    }
    float dist = sqrtf(powf((x1-x2), 2) + powf((y1-y2), 2));
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBStrokeColor(context,0,0,0,1.0); // 画笔线的颜色
    CGContextSetLineWidth(context, 2.0); // 线的宽度
    UIColor *aColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
    CGContextSetFillColorWithColor(context, aColor.CGColor); // 填充颜色
    
    // border background
    switch (self.bubbleType) {
        case LVBubbleTypeEllipse:
        {
            CGContextAddEllipseInRect(context, self.textBubbleView.frame); // 椭圆
            CGContextDrawPath(context, kCGPathFillStroke); // 绘制路径
        }
            break;
        case LVBubbleTypeShout:
        {
            NSArray *shoutData = [LVTextBubbleView shout_data];
            CGContextBeginPath(context);
            CGContextMoveToPoint(context, [shoutData[0][0] floatValue]*x_scale+textBubbleViewFrameX, [shoutData[0][1] floatValue]*y_scale+textBubbleViewFrameY); // 移动
            for (NSArray *points in shoutData) {
                for (int i = 0; i < 3; i+=2) {
                    CGContextAddLineToPoint(context, [points[i] floatValue]*x_scale+textBubbleViewFrameX, [points[i+1] floatValue]*y_scale+textBubbleViewFrameY);
                }
            }
            CGContextDrawPath(context, kCGPathFillStroke); // 绘制路径
        }
            break;
        case LVBubbleTypeThought:
        {
            NSArray *thoughtData = [LVTextBubbleView thought_data];
            CGContextBeginPath(context);
            CGContextMoveToPoint(context, [thoughtData[0][0] floatValue]*x_scale+textBubbleViewFrameX, [thoughtData[0][1] floatValue]*y_scale+textBubbleViewFrameY); // 移动
            for (NSArray *points in thoughtData) {
                CGContextAddCurveToPoint(context,
                                         ([points[0] floatValue]+1)*x_scale+textBubbleViewFrameX,
                                         ([points[1] floatValue]+1)*y_scale+textBubbleViewFrameY,
                                         ([points[2] floatValue]+1)*x_scale+textBubbleViewFrameX,
                                         ([points[3] floatValue]+1)*y_scale+textBubbleViewFrameY,
                                         ([points[4] floatValue]+1)*x_scale+textBubbleViewFrameX,
                                         ([points[5] floatValue]+1)*y_scale+textBubbleViewFrameY);
            }
            CGContextDrawPath(context, kCGPathFillStroke); // 绘制路径
        }
            break;
        default:
            break;
    }
    // triangle and cycle
    switch (self.bubbleType) {
            // TODO:椭圆形状情况, 三角形两条边改为贝塞尔曲线
        case LVBubbleTypeEllipse:
        case LVBubbleTypeShout:
        {
            // TODO:三角底边长度, 可调整为随输入框的大小而改变
            int c = 15;
            float x3, x4, y3, y4;
            float k = sqrt(pow((x1-x2), 2) + pow((y1-y2), 2));
            
            if ((x1-x2)*(y1-y2)>0) {
                x3 = MIN((x2+c*(y2-y1)/k), (x2-c*(y2-y1)/k));
                x4 = MAX((x2+c*(y2-y1)/k), (x2-c*(y2-y1)/k));
                y3 = MAX((y2+c*(x2-x1)/k), (y2-c*(x2-x1)/k));
                y4 = MIN((y2+c*(x2-x1)/k), (y2-c*(x2-x1)/k));
            } else if ((x1-x2)*(y1-y2) < 0) {
                x3 = MAX((x2+c*(y2-y1)/k), (x2-c*(y2-y1)/k));
                x4 = MIN((x2+c*(y2-y1)/k), (x2-c*(y2-y1)/k));
                y3 = MAX((y2+c*(x2-x1)/k), (y2-c*(x2-x1)/k));
                y4 = MIN((y2+c*(x2-x1)/k), (y2-c*(x2-x1)/k));
            } else {
                x3 = x2-c;
                x4 = x2+c;
                y3 = y2;
                y4 = y2;
            }
            
            CGContextBeginPath(context);
            CGContextMoveToPoint(context, x1, y1);
            CGContextAddLineToPoint(context, x3, y3);
            CGContextAddLineToPoint(context, x4, y4);
            CGContextAddLineToPoint(context, x1, y1);
            CGContextDrawPath(context, kCGPathFillStroke);
        }
            break;
        case LVBubbleTypeThought:
        {
            float numCicle = MAX(3, floorf(dist/28));
            float lineLength = dist/numCicle;
            float radiusScale = 7/numCicle;
            float i = 0;
            while (i < numCicle) {
                float x, y;
                if (x2<x1) {
                    x = (dist - (i * lineLength)) *cos(atan(k))+x2;
                    y = k*x+b;
                } else if (x2==x1) {
                    x = x2;
                    y = x2>0?lineLength*i:-lineLength*i;
                    y = y1-y;
                } else {
                    x = -(dist - (i * lineLength)) *cos(atan(k))+x2;
                    y = k*x+b;
                }
                
                CGContextAddArc(context, x, y, (3 + (i * radiusScale)), 0, 2*M_PI, 0);
                CGContextDrawPath(context, kCGPathFillStroke); //绘制路径
                i++;
            }
        }
        default:
            break;
    }
}

@end

#pragma mark - LVBubblePointerView

@interface LVBubblePointerView ()

@property (nonatomic) float oldX, oldY;

@end

@implementation LVBubblePointerView

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
    CGContextSetRGBStrokeColor(context,0,0,0,1.0); // 画笔线的颜色
    CGContextSetLineWidth(context, 1.0); // 线的宽度
    UIColor *aColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
    CGContextSetFillColorWithColor(context, aColor.CGColor); // 填充颜色
    CGContextAddArc(context, CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds), self.bounds.size.width/2-30, 0, 2 * M_PI, 0); //添加一个圆
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
    if ([self.delegate respondsToSelector:@selector(bubblePointerViewDidMoved:)]) {
        [self.delegate bubblePointerViewDidMoved:self];
    }
}

@end
