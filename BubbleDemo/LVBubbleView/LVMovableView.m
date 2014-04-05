//
//  MovableView.m
//  BubbleDemo
//
//  Created by lvpw on 14-4-1.
//  Copyright (c) 2014年 pengwei.lv. All rights reserved.
//

#import "LVMovableView.h"

@interface LVMovableView ()

@property (nonatomic) float oldX, oldY;

@end

@implementation LVMovableView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchLocation = [touch locationInView:self];
    self.oldX = touchLocation.x;
    self.oldY = touchLocation.y;
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesCancelled:touches withEvent:event];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesEnded:touches withEvent:event];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesMoved:touches withEvent:event];
    float deltaX = [[touches anyObject]locationInView:self].x - self.oldX;
    float deltaY = [[touches anyObject]locationInView:self].y - self.oldY;
    if (deltaX != 0 && deltaY != 0) {
        if ([self.delegate respondsToSelector:@selector(movableViewBeginMove)]) {
            [self.delegate movableViewBeginMove];
        }
    }
    if ([self.delegate respondsToSelector:@selector(movableView:deltaX:deltaY:)]) {
        [self.delegate movableView:self deltaX:deltaX deltaY:deltaY];
    }
}

@end
