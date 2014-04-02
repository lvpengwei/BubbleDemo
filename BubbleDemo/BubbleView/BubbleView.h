//
//  CustomTouchView.h
//  BubbleDemo
//
//  Created by lvpw on 14-4-1.
//  Copyright (c) 2014年 pengwei.lv. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TextBubbleView.h"

@interface BubbleView : UIView

@property (nonatomic) BubbleType bubbleType;
@property (nonatomic, strong) TextBubbleView *textBubbleView;

@end

@class BubblePointerView;

@protocol BubblePointerViewProtocol <NSObject>

- (void)bubblePointerViewDidMoved:(BubblePointerView *)bubblePointerView;

@end

@interface BubblePointerView : UIView

@property (nonatomic) BOOL selected;
@property (nonatomic, weak) id<BubblePointerViewProtocol> delegate;

@end
