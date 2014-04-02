//
//  MovableView.h
//  BubbleDemo
//
//  Created by lvpw on 14-4-1.
//  Copyright (c) 2014年 pengwei.lv. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MovableView;

@protocol MovableViewProtocol <NSObject>
@optional
- (void)movableViewBeginMove;
- (void)movableView:(MovableView *)movableView deltaX:(float)deltaX deltaY:(float)deltaY;

@end

@interface MovableView : UIView

@property (weak, nonatomic) id<MovableViewProtocol> delegate;

@end
