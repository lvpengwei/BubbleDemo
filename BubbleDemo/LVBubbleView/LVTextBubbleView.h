//
//  BubbleView.h
//  BubbleDemo
//
//  Created by lvpw on 14-4-1.
//  Copyright (c) 2014年 pengwei.lv. All rights reserved.
//

typedef enum : NSUInteger {
    LVBubbleTypeEllipse,
    LVBubbleTypeThought,
    LVBubbleTypeShout,
} LVBubbleType;

#import <UIKit/UIKit.h>

@class LVTextBubbleView;

@protocol LVTextBubbleViewProtocol <NSObject>

- (void)textBubbleViewDidmoved:(LVTextBubbleView *)textBubbleView;
- (void)textBubbleViewDidChanged:(LVTextBubbleView *)textBubbleView;

@end

@interface LVTextBubbleView : UIView

@property (nonatomic) LVBubbleType bubbleType;
@property (nonatomic) CGFloat maxWidth;
@property (nonatomic, weak) id<LVTextBubbleViewProtocol> delegate;

@property (nonatomic) CGFloat x_scale;
@property (nonatomic) CGFloat y_scale;
@property (nonatomic) NSInteger rectPadding;

+ (NSArray *)thought_data;
+ (NSArray *)shout_data;

@end
