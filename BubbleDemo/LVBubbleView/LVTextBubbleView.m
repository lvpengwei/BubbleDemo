//
//  BubbleView.m
//  BubbleDemo
//
//  Created by lvpw on 14-4-1.
//  Copyright (c) 2014年 pengwei.lv. All rights reserved.
//

#import "LVTextBubbleView.h"
#import "LVMovableView.h"

@interface LVTextBubbleView () <UITextViewDelegate, LVMovableViewProtocol>

@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) LVMovableView *foregroundView;
@property (nonatomic) CGFloat padding_x_scale; // 填充后的缩放比x
@property (nonatomic) CGFloat padding_y_scale; // 填充后的缩放比y

@end

@implementation LVTextBubbleView

#pragma mark - LVMovableViewProtocol

- (void)movableViewBeginMove
{
    [self.textView resignFirstResponder];
}

- (void)movableView:(LVMovableView *)movable deltaX:(float)deltaX deltaY:(float)deltaY
{
    self.transform = CGAffineTransformTranslate(self.transform, deltaX, deltaY);
    if ([self.delegate respondsToSelector:@selector(textBubbleViewDidmoved:)]) {
        [self.delegate textBubbleViewDidmoved:self];
    }
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView
{
    CGSize currentSize = textView.frame.size;
    CGSize textViewTosize = [textView sizeThatFits:CGSizeMake(self.maxWidth, MAXFLOAT)];
    NSLog(@"%@", NSStringFromCGSize(textViewTosize));
    float deltaWidth = textViewTosize.width - currentSize.width;
    float deltaHeight = textViewTosize.height - currentSize.height;
    
    // bubble update frame
    CGSize currentBubbleSize = self.frame.size;
    CGSize bubbleToSize = CGSizeMake(currentBubbleSize.width+deltaWidth, currentBubbleSize.height+deltaHeight);
    self.frame = (CGRect){.origin=self.frame.origin, .size=bubbleToSize};
    
    // textview update frame
    // set min width
    if (textViewTosize.width < 20) {
        textViewTosize = CGSizeMake(20, textViewTosize.height);
    }
    textView.bounds = (CGRect){.origin=CGPointZero, .size=textViewTosize};
    textView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    
    // foreground view
    self.foregroundView.frame = (CGRect){.origin=CGPointZero, .size=bubbleToSize};
    [self setNeedsDisplay];
    
    if ([self.delegate respondsToSelector:@selector(textBubbleViewDidChanged:)]) {
        [self.delegate textBubbleViewDidChanged:self];
    }
}

#pragma mark - Handle Action

- (void)tapAction:(UITapGestureRecognizer *)recognizer
{
    if ([self.textView isFirstResponder]) {
        [self.textView resignFirstResponder];
    } else {
        [self.textView becomeFirstResponder];
    }
}

#pragma mark - override

- (CGFloat)x_scale
{
    return (self.frame.size.width)/75;
}

- (CGFloat)y_scale
{
    return (self.frame.size.height)/50;
}

- (CGFloat)padding_x_scale
{
    return (self.frame.size.width-self.rectPadding*2)/75;
}

- (CGFloat)padding_y_scale
{
    return (self.frame.size.height-self.rectPadding*2)/50;
}

- (NSInteger)rectPadding
{
    return 2;
}

#pragma mark - Life Cycle

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        UITextView *textView = [[UITextView alloc] init];
        textView.frame = CGRectMake(0, 0, 20, 30);
        textView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
        textView.delegate = self;
        textView.backgroundColor = [UIColor clearColor];
        textView.scrollEnabled = NO;
        [self addSubview:textView];
        self.textView = textView;
        
        // foreground view
        LVMovableView *foregroundView = [[LVMovableView alloc] initWithFrame:(CGRect){.origin=CGPointZero, .size=self.frame.size}];
        foregroundView.delegate = self;
        foregroundView.backgroundColor = [UIColor clearColor];
        [self addSubview:foregroundView];
        self.foregroundView = foregroundView;
        
        // tap action
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        [self.foregroundView addGestureRecognizer:tapGestureRecognizer];
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
//    NSLog(@"%s", __FUNCTION__);
    // 一个不透明类型的Quartz 2D绘画环境,相当于一个画布,你可以在上面任意绘画
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBStrokeColor(context,1,1,1,1.0); // 画笔线的颜色
    CGContextSetLineWidth(context, 1.0); // 线的宽度
    UIColor *aColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
    CGContextSetFillColorWithColor(context, aColor.CGColor); // 填充颜色
    CGRect paddedRect = CGRectMake(rect.origin.x+self.rectPadding, rect.origin.y+self.rectPadding, rect.size.width-self.rectPadding*2, rect.size.height-self.rectPadding*2);
    switch (self.bubbleType) {
        case LVBubbleTypeEllipse:{
            // front
            CGContextAddEllipseInRect(context, paddedRect); // 椭圆
            CGContextDrawPath(context, kCGPathFillStroke); // 绘制路径
        }
            break;
        case LVBubbleTypeShout:{
            NSArray *shoutData = [LVTextBubbleView shout_data];
            CGContextBeginPath(context);
            CGContextMoveToPoint(context, [shoutData[0][0] floatValue]*self.padding_x_scale+self.rectPadding, [shoutData[0][1] floatValue]*self.padding_y_scale+self.rectPadding); // 移动
            for (NSArray *points in shoutData) {
                for (int i = 0; i < 3; i+=2) {
                    CGContextAddLineToPoint(context, [points[i] floatValue]*self.padding_x_scale+self.rectPadding, [points[i+1] floatValue]*self.padding_y_scale+self.rectPadding);
                }
            }
            CGContextDrawPath(context, kCGPathFillStroke); // 绘制路径
        }
            break;
        case LVBubbleTypeThought:{
            NSArray *thoughtData = [LVTextBubbleView thought_data];
            CGContextBeginPath(context);
            CGContextMoveToPoint(context, [thoughtData[0][0] floatValue]*self.padding_x_scale+self.rectPadding, [thoughtData[0][1] floatValue]*self.padding_y_scale+self.rectPadding); // 移动
            for (NSArray *points in thoughtData) {
                CGContextAddCurveToPoint(context,
                                         ([points[0] floatValue]+1)*self.padding_x_scale+self.rectPadding,
                                         ([points[1] floatValue]+1)*self.padding_y_scale+self.rectPadding,
                                         ([points[2] floatValue]+1)*self.padding_x_scale+self.rectPadding,
                                         ([points[3] floatValue]+1)*self.padding_y_scale+self.rectPadding,
                                         ([points[4] floatValue]+1)*self.padding_x_scale+self.rectPadding,
                                         ([points[5] floatValue]+1)*self.padding_y_scale+self.rectPadding);
            }
            CGContextDrawPath(context, kCGPathFillStroke); // 绘制路径
        }
            break;
        default:
            break;
    }
    
    // kCGPathFill填充非零绕数规则,kCGPathEOFill表示用奇偶规则,kCGPathStroke路径,kCGPathFillStroke路径填充,kCGPathEOFillStroke表示描线，不是填充
}

- (void)drawLinkedLine
{
    
}

#pragma mark - Util

// LVBubbleTypeThought类型点坐标
+ (NSArray *)thought_data {
    return @[
             @[@63.3, @4.8, @64.9,@4.8, @66.05, @6],
             @[@66.05, @6, @67.2, @7.15, @67.2, @8.8],
             @[@67.2, @8.8, @67.2, @8.9, @67.2, @9],
             @[@67.2, @9, @67.15, @9.75, @66.85, @10.45],
             @[@66.85, @10.45, @67.55, @10.15, @68.3, @10.15],
             @[@68.3, @10.15, @69.9, @10.15, @71.05, @11.35],
             @[@71.05, @11.35, @72.25, @12.5, @72.25, @14.1],
             @[@72.25, @14.1, @72.25, @14.2, @72.25, @14.35],
             @[@72.25, @14.35, @72.2, @15.8, @71.05, @16.9],
             @[@71.05, @16.9, @71, @16.95, @70.95, @17],
             @[@70.95, @17, @71, @17, @71.05, @17],
             @[@71.05, @17, @72.7, @17, @73.85, @18.2],
             @[@73.85, @18.2, @75, @19.35, @75, @21],
             @[@75, @21, @75, @21.1, @75, @21.2],
             @[@75, @21.2, @74.95, @22.65, @73.85, @23.8],
             @[@73.85, @23.8, @73.25, @24.4, @72.55, @24.7],
             @[@72.55, @24.7, @73.25, @24.95, @73.85, @25.55],
             @[@73.85, @25.55, @75, @26.75, @75, @28.35],
             @[@75, @28.35, @75, @28.45, @75, @28.55],
             @[@75, @28.55, @74.95, @30.05, @73.85, @31.15],
             @[@73.85, @31.15, @72.7, @32.35, @71.05, @32.35],
             @[@71.05, @32.35, @70.7, @32.35, @70.4, @32.3],
             @[@70.4, @32.3, @71.45, @33.4, @71.45, @35],
             @[@71.45, @35, @71.45, @35.1, @71.45, @35.2],
             @[@71.45, @35.2, @71.4, @36.65, @70.3, @37.75],
             @[@70.3, @37.75, @69.15, @38.95, @67.55, @38.95],
             @[@67.55, @38.95, @66.8, @38.95, @66.15, @38.7],
             @[@66.15, @38.7, @66.1, @38.7, @66.05, @38.65],
             @[@66.05, @38.65, @66.1, @38.7, @66.1, @38.75],
             @[@66.1, @38.75, @66.7, @39.65, @66.7, @40.85],
             @[@66.7, @40.85, @66.7, @40.95, @66.7, @41.05],
             @[@66.7, @41.05, @66.65, @42.5, @65.55, @43.6],
             @[@65.55, @43.6, @64.4, @44.8, @62.8, @44.8],
             @[@62.8, @44.8, @62.2, @44.8, @61.7, @44.65],
             @[@61.7, @44.65, @61.55, @45.9, @60.55, @46.95],
             @[@60.55, @46.95, @60.3, @47.2, @60.05, @47.4],
             @[@60.05, @47.4, @59.05, @48.1, @57.8, @48.1],
             @[@57.8, @48.1, @57.05, @48.1, @56.4, @47.85],
             @[@56.4, @47.85, @56.2,@47.75,@56, @47.7],
             @[@56, @47.7, @55.8, @47.95, @55.55, @48.2],
             @[@55.55, @48.2, @54.4, @49.35, @52.75, @49.35],
             @[@52.75, @49.35, @52, @49.35, @51.35, @49.1],
             @[@51.35, @49.1, @50.6, @48.8, @50, @48.2],
             @[@50, @48.2, @49.9, @48.3, @49.75, @48.45],
             @[@49.75, @48.45, @48.6, @49.65, @47, @49.65],
             @[@47, @49.65, @46.65, @49.65, @46.3, @49.6],
             @[@46.3, @49.6, @45.15, @49.35, @44.25, @48.45],
             @[@44.25, @48.45, @43.85, @48.05, @43.55, @47.5],
             @[@43.55, @47.5, @43.55, @47.45, @43.5, @47.4],
             @[@43.5, @47.4, @43.45, @47.5, @43.4, @47.6],
             @[@43.4, @47.6, @43.4, @47.58, @43.4, @47.55],
             @[@43.4, @47.55, @43.1, @48.2, @42.5, @48.8],
             @[@42.5, @48.8, @41.9, @49.4, @41.2, @49.7],
             @[@41.2, @49.7, @40.55, @50, @39.75, @50],
             @[@39.75, @50, @39.2, @50, @38.75, @49.9],
             @[@38.75, @49.9, @38.5, @49.8, @38.3, @49.7],
             @[@38.3, @49.7, @37.6, @49.4, @37, @48.8],
             @[@37, @48.8, @36.45, @48.25, @36.15, @47.55],
             @[@36.15, @47.55, @36.1, @47.7, @36.05, @47.8],
             @[@36.05, @47.8, @35.85, @48.1, @35.5, @48.45],
             @[@35.5, @48.45, @34.35, @49.65, @32.7, @49.65],
             @[@32.7, @49.65, @31.1, @49.65, @29.95, @48.45],
             @[@29.95, @48.45, @29.45, @47.95, @29.2, @47.4],
             @[@29.2, @47.4, @29.1, @47.3, @29.05, @47.15],
             @[@29.05, @47.15, @29, @47.3, @28.95, @47.4],
             @[@28.95, @47.4, @28.7, @47.95, @28.2, @48.45],
             @[@28.2, @48.45, @27.05, @49.65, @25.45, @49.65],
             @[@25.45, @49.65, @24.8, @49.65, @24.25, @49.45],
             @[@24.25, @49.45, @23.4, @49.15, @22.7, @48.45],
             @[@22.7, @48.45, @22.2, @47.95, @21.95, @47.4],
             @[@21.95, @47.4, @21.7, @47, @21.6, @46.5],
             @[@21.6, @46.5, @21.35, @47, @21, @47.4],
             @[@21, @47.4, @20.98, @47.42, @20.95, @47.45],
             @[@20.95, @47.45, @19.8, @48.6, @18.2, @48.6],
             @[@18.2, @48.6, @16.6, @48.6, @15.45, @47.45],
             @[@15.45, @47.45, @15.43, @47.42, @15.4, @47.4],
             @[@15.4, @47.4, @14.25, @46.2, @14.25, @44.65],
             @[@14.25, @44.65, @14.25, @44.55, @14.25, @44.45],
             @[@14.25, @44.45, @14.25, @44.25, @14.3, @44.05],
             @[@14.3, @44.05, @14.3, @43.85, @14.35, @43.65],
             @[@14.35, @43.65, @14.2, @43.8, @14.1, @43.95],
             @[@14.1, @43.95, @13.05, @44.8, @11.65, @44.8],
             @[@11.65, @44.8, @10.05, @44.8, @8.9, @43.6],
             @[@8.9, @43.6, @7.75, @42.45, @7.75, @40.85],
             @[@7.75, @40.85, @7.75, @40.7, @7.75, @40.6],
             @[@7.75, @40.6, @7.8, @39.85, @8.1, @39.15],
             @[@8.1, @39.15, @7.4, @39.45, @6.65, @39.45],
             @[@6.65, @39.45, @5.05, @39.45, @3.9, @38.3],
             @[@3.9, @38.3, @2.75, @37.1, @2.75, @35.5],
             @[@2.75, @35.5, @2.75, @35.4, @2.75, @35.3],
             @[@2.75, @35.3, @2.8, @33.8, @3.9, @32.7],
             @[@3.9, @32.7, @3.95, @32.7, @3.95, @32.65],
             @[@3.95, @32.65, @4, @32.65, @4, @32.6],
             @[@4, @32.6, @3.95, @32.6, @3.9, @32.6],
             @[@3.9, @32.6, @2.35, @32.6, @1.2, @31.45],
             @[@1.2, @31.45, @1.18, @31.43, @1.15, @31.4],
             @[@1.15, @31.4, @0, @30.25, @0, @28.6],
             @[@0, @28.6, @0, @28.5, @0, @28.4],
             @[@0, @28.4, @0.05, @26.95, @1.15, @25.8],
             @[@1.15, @25.8, @1.18, @25.77, @1.2, @25.75],
             @[@1.2, @25.75, @1.8, @25.2, @2.45, @24.9],
             @[@2.45, @24.9, @1.8, @24.65, @1.2, @24.1],
             @[@1.2, @24.1, @1.18, @24.07, @1.15, @24.05],
             @[@1.15, @24.05, @0, @22.85, @0, @21.25],
             @[@0, @21.25, @0, @21.15, @0, @21.05],
             @[@0, @21.05, @0.05, @19.55, @1.15, @18.45],
             @[@1.15, @18.45, @1.18, @18.43, @1.2, @18.4],
             @[@1.2, @18.4, @1.55, @18.1, @1.95, @17.85],
             @[@1.95, @17.85, @2.75, @17.35, @3.8, @17.3],
             @[@3.8, @17.3, @3.6, @17.1, @3.4, @16.9],
             @[@3.4, @16.9, @2.25, @15.75, @2.25, @14.1],
             @[@2.25, @14.1, @2.25, @14, @2.25, @13.9],
             @[@2.25, @13.9, @2.3, @12.45, @3.4, @11.35],
             @[@3.4, @11.35, @4.55, @10.15, @6.15, @10.15],
             @[@6.15, @10.15, @6.35, @10.15, @6.6, @10.2],
             @[@6.6, @10.2, @7.05, @10.2, @7.45, @10.35],
             @[@7.45, @10.35, @7, @9.55, @7, @8.55],
             @[@7, @8.55, @7, @8.45, @7, @8.3],
             @[@7, @8.3, @7.05, @6.85, @8.15, @5.75],
             @[@8.15, @5.75, @9.3, @4.55, @10.9, @4.55],
             @[@10.9, @4.55, @11.1, @4.55, @11.35, @4.6],
             @[@11.35, @4.6, @11.85, @4.6, @12.3, @4.8],
             @[@12.3, @4.8, @12.55, @4.9, @12.75, @5.05],
             @[@12.75, @5.05, @12.75, @5, @12.75, @4.95],
             @[@12.75, @4.95, @12.75, @4.85, @12.75, @4.75],
             @[@12.75, @4.75, @12.8, @3.55, @13.55, @2.6],
             @[@13.55, @2.6, @13.7, @2.35, @13.9, @2.15],
             @[@13.9, @2.15, @15.05, @1, @16.7, @1],
             @[@16.7, @1, @16.9, @1, @17.15, @1.05],
             @[@17.15, @1.05, @17.65, @1.05, @18.1, @1.25],
             @[@18.1, @1.25, @18.65, @1.45, @19.15, @1.85],
             @[@19.15, @1.85, @19.35, @1.5, @19.7, @1.15],
             @[@19.7, @1.15, @20.85, @0, @22.45, @0],
             @[@22.45, @0, @22.65, @0, @22.9, @0.05],
             @[@22.9, @0.05, @23.4, @0.05, @23.85, @0.25],
             @[@23.85, @0.25, @24.05, @0.35, @24.25, @0.45],
             @[@24.25, @0.45, @24.75, @0.7, @25.2, @1.15],
             @[@25.2, @1.15, @26.35, @0, @27.95, @0],
             @[@27.95, @0, @29.55, @0, @30.7, @1.15],
             @[@30.7, @1.15, @31.15, @1.6, @31.45, @2.2],
             @[@31.45, @2.2, @31.75, @1.6, @32.2, @1.15],
             @[@32.2, @1.15, @33.35, @0, @35, @0],
             @[@35, @0, @36.6, @0, @37.75, @1.15],
             @[@37.75, @1.15, @38.35, @1.75, @38.65, @2.45],
             @[@38.65, @2.45, @38.9, @1.75, @39.5, @1.15],
             @[@39.5, @1.15, @40.65, @0, @42.25, @0],
             @[@42.25, @0, @43.85, @0, @45, @1.15],
             @[@45, @1.15, @45.6, @1.75, @45.9, @2.45],
             @[@45.9, @2.45, @46.05, @2.05, @46.3, @1.7],
             @[@46.3, @1.7, @46.5, @1.4, @46.75, @1.15],
             @[@46.75, @1.15, @47.9, @0, @49.5, @0],
             @[@49.5, @0, @51.1, @0, @52.25, @1.15],
             @[@52.25, @1.15, @53.15, @2, @53.4, @3.1],
             @[@53.4, @3.1, @53.65, @2.6, @54.05, @2.15],
             @[@54.05, @2.15, @55.2, @1, @56.8, @1],
             @[@56.8, @1, @58.4, @1, @59.55, @2.15],
             @[@59.55, @2.15, @60.7, @3.35, @60.7, @4.95],
             @[@60.7, @4.95, @60.7, @5.05, @60.7, @5.15],
             @[@60.7, @5.15, @60.7, @5.6, @60.6, @5.95],
             @[@60.6, @5.95, @61.75, @4.8, @63.3, @4.8],
             @[@63.3, @4.8, @64.9, @4.8, @66.05, @6]
             ];
}

// LVBubbleTypeShout类型点坐标
+ (NSArray *)shout_data {
    return @[@[@69.7, @9.8, @68.35, @12.68, @67, @15.55], @[@67, @15.55, @70.47, @15.55, @73.95, @15.55], @[@73.95, @15.55, @71.42, @17.73, @68.9, @19.9], @[@68.9, @19.9, @71.95, @21.1, @75, @22.3], @[@75, @22.3, @72.17, @23.82, @69.35, @25.35], @[@69.35, @25.35, @72.12, @26.88, @74.9, @28.4], @[@74.9, @28.4, @71.85, @29.2, @68.8, @30], @[@68.8, @30, @70.83, @32.12, @72.85, @34.25], @[@72.85, @34.25, @69.53, @34.27, @66.2, @34.3], @[@66.2, @34.3, @68.15, @36.75, @70.1, @39.2], @[@70.1, @39.2, @66.6, @38.65, @63.1, @38.1], @[@63.1, @38.1, @64.4, @40.77, @65.7, @43.45], @[@65.7, @43.45, @62.38, @42.3, @59.05, @41.15], @[@59.05, @41.15, @59.65, @43.48, @60.25, @45.8], @[@60.25, @45.8, @57.4, @44.62, @54.55, @43.45], @[@54.55, @43.45, @54.55, @45.98, @54.55, @48.5], @[@54.55, @48.5, @52.12, @46.25, @49.7, @44], @[@49.7, @44, @48.88, @46.38, @48.05, @48.75], @[@48.05, @48.75, @46.5, @46.27, @44.95, @43.8], @[@44.95, @43.8, @43.4, @46.23, @41.85, @48.65], @[@41.85, @48.65, @40.9, @46.25, @39.95, @43.85], @[@39.95, @43.85, @37.75, @46.92, @35.55, @50], @[@35.55, @50, @34.45, @46.92, @33.35, @43.85], @[@33.35, @43.85, @30.4, @45.98, @27.45, @48.1], @[@27.45, @48.1, @26.98, @45.85, @26.5, @43.6], @[@26.5, @43.6, @23.7, @45.65, @20.9, @47.7], @[@20.9, @47.7, @20.3, @45.45, @19.7, @43.2], @[@19.7, @43.2, @16.93, @44.95, @14.15, @46.7], @[@14.15, @46.7, @14.15, @44.02, @14.15, @41.35], @[@14.15, @41.35, @11.55, @42.35, @8.95, @43.35], @[@8.95, @43.35, @9.75, @40.88, @10.55, @38.4], @[@10.55, @38.4, @7.53, @38.77, @4.5, @39.15], @[@4.5, @39.15, @5.92, @36.73, @7.35, @34.3], @[@7.35, @34.3, @4.53, @34.3, @1.7, @34.3], @[@1.7, @34.3, @3.33, @32.17, @4.95, @30.05], @[@4.95, @30.05, @2.55, @29.15, @0.15, @28.25], @[@0.15, @28.25, @2.55, @26.8, @4.95, @25.35], @[@4.95, @25.35, @2.48, @23.88, @0, @22.4], @[@0, @22.4, @2.73, @21.5, @5.45, @20.6], @[@5.45, @20.6, @3.2, @18.07, @0.95, @15.55], @[@0.95, @15.55, @4.2, @15.55, @7.45, @15.55], @[@7.45, @15.55, @6, @12.7, @4.55, @9.85], @[@4.55, @9.85, @7.78, @10.85, @11, @11.85], @[@11, @11.85, @9.88, @8.82, @8.75, @5.8], @[@8.75, @5.8, @11.95, @7.3, @15.15, @8.8], @[@15.15, @8.8, @14.5, @5.65, @13.85, @2.5], @[@13.85, @2.5, @16.75, @4.45, @19.65, @6.4], @[@19.65, @6.4, @19.65, @3.65, @19.65, @0.9], @[@19.65, @0.9, @22.1, @3.38, @24.55, @5.85], @[@24.55, @5.85, @25.27, @3.08, @26, @0.3], @[@26, @0.3, @27.7, @3.33, @29.4, @6.35], @[@29.4, @6.35, @30.48, @3.48, @31.55, @0.6], @[@31.55, @0.6, @33.4, @3.48, @35.25, @6.35], @[@35.25, @6.35, @36.45, @3.17, @37.65, @0], @[@37.65, @0, @38.92, @3, @40.2, @6], @[@40.2, @6, @41.85, @3.08, @43.5, @0.15], @[@43.5, @0.15, @44.3, @3.25, @45.1, @6.35], @[@45.1, @6.35, @47.05, @3.4, @49, @0.45], @[@49, @0.45, @49.48, @3.15, @49.95, @5.85], @[@49.95, @5.85, @52.38, @3.55, @54.8, @1.25], @[@54.8, @1.25, @54.8, @3.83, @54.8, @6.4], @[@54.8, @6.4, @57.05, @4.8, @59.3, @3.2], @[@59.3, @3.2, @59.3, @6, @59.3, @8.8], @[@59.3, @8.8, @62.05, @7.3, @64.8, @5.8], @[@64.8, @5.8, @64.1, @8.78, @63.4, @11.75], @[@63.4, @11.75, @66.55, @10.78, @69.7, @9.8], @[@69.7, @9.8, @68.35, @12.68, @67, @15.55]];
}

@end
