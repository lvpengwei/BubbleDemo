//
//  ViewController.m
//  BubbleDemo
//
//  Created by lvpw on 14-4-1.
//  Copyright (c) 2014年 pengwei.lv. All rights reserved.
//

#import "ViewController.h"
#import "BubbleView.h"

@interface ViewController ()

@property (nonatomic, strong) BubbleView *bubbleView;
@property (nonatomic, strong) TextBubbleView *textBubbleView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
//    TextBubbleView *bubbleView = [[TextBubbleView alloc] initWithFrame:CGRectMake(20, 20, 100, 50)];
//    bubbleView.backgroundColor = [UIColor clearColor];
//    bubbleView.maxWidth = 100;
//    bubbleView.bubbleType = BubbleTypeEllipse;
//    [self.view addSubview:bubbleView];
//    self.textBubbleView = bubbleView;
    
    BubbleView *bubbleView = [[BubbleView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    bubbleView.backgroundColor = [UIColor clearColor];
    bubbleView.textBubbleView.bubbleType = BubbleTypeEllipse;
    bubbleView.textBubbleView.maxWidth = 100;
    [self.view addSubview:bubbleView];
    self.bubbleView = bubbleView;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)segmentControlAction:(UISegmentedControl *)sender
{
    switch (sender.selectedSegmentIndex) {
        case 0:{
            self.bubbleView.bubbleType = BubbleTypeEllipse;
            [self.bubbleView setNeedsDisplay];
        }
            break;
        case 1:{
            self.bubbleView.bubbleType = BubbleTypeThought;
            [self.bubbleView setNeedsDisplay];
        }
            break;
        case 2:{
            self.bubbleView.bubbleType = BubbleTypeShout;
            [self.bubbleView setNeedsDisplay];
        }
        default:
            break;
    }
}

@end
