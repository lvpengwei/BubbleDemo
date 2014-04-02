//
//  BubbleView.h
//  BubbleDemo
//
//  Created by lvpw on 14-4-1.
//  Copyright (c) 2014年 pengwei.lv. All rights reserved.
//

typedef enum : NSUInteger {
    BubbleTypeEllipse,
    BubbleTypeThought,
    BubbleTypeShout,
} BubbleType;

#import <UIKit/UIKit.h>

@class TextBubbleView;

@protocol TextBubbleViewProtocol <NSObject>

- (void)textBubbleViewDidmoved:(TextBubbleView *)textBubbleView;
- (void)textBubbleViewDidChanged:(TextBubbleView *)textBubbleView;

@end

@interface TextBubbleView : UIView

@property (nonatomic) BubbleType bubbleType;
@property (nonatomic) float maxWidth;
@property (nonatomic, weak) id<TextBubbleViewProtocol> delegate;

@property (nonatomic) float x_scale;
@property (nonatomic) float y_scale;
@property (nonatomic) NSInteger rectPadding;

+ (NSArray *)thought_data;
+ (NSArray *)shout_data;

@end
