//
//  MovableView.h
//  BubbleDemo
//
//  Created by lvpw on 14-4-1.
//  Copyright (c) 2014年 pengwei.lv. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LVMovableView;

@protocol LVMovableViewProtocol <NSObject>
@optional
- (void)movableViewBeginMove;
- (void)movableView:(LVMovableView *)movableView deltaX:(float)deltaX deltaY:(float)deltaY;

@end

@interface LVMovableView : UIView

@property (weak, nonatomic) id<LVMovableViewProtocol> delegate;

@end
