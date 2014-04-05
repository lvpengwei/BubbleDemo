//
//  CustomTouchView.h
//  BubbleDemo
//
//  Created by lvpw on 14-4-1.
//  Copyright (c) 2014年 pengwei.lv. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LVTextBubbleView.h"

@interface LVBubbleView : UIView

@property (nonatomic) LVBubbleType bubbleType;
@property (nonatomic, strong) LVTextBubbleView *textBubbleView;

@end

@class LVBubblePointerView;

@protocol LVBubblePointerViewProtocol <NSObject>

- (void)bubblePointerViewDidMoved:(LVBubblePointerView *)bubblePointerView;

@end

@interface LVBubblePointerView : UIView

@property (nonatomic) BOOL selected;
@property (nonatomic, weak) id<LVBubblePointerViewProtocol> delegate;

@end
