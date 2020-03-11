//
//  AnimateForDismissed.m
//  coful
//
//  Created by coful on 16/5/20.
//  Copyright © 2016年 coful. All rights reserved.
//

#import "AnimateForDismissed.h"

@interface AnimateForDismissed ()

@end

@implementation AnimateForDismissed


- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext {
    return 0.5;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *container = [transitionContext containerView];
    [container addSubview:toVC.view];
    [container addSubview:fromVC.view];
    
    //设置anrchPoint 和 position
    CGRect initalFrame = [transitionContext initialFrameForViewController:fromVC];
    toVC.view.frame = initalFrame;
    fromVC.view.frame = initalFrame;
    
    //初始位置
    toVC.view.center = CGPointMake(CGRectGetMidX(initalFrame)*0.25, CGRectGetMidY(initalFrame));
    fromVC.view.center = CGPointMake(CGRectGetMidX(initalFrame), CGRectGetMidY(initalFrame));
    
    
    //添加阴影效果
    CAGradientLayer *shadowLayer = [CAGradientLayer layer];
    
    shadowLayer.colors = [NSArray arrayWithObjects:(id)[[UIColor alloc] initWithWhite:0 alpha:1].CGColor, (id)[[UIColor alloc] initWithWhite:0 alpha:0.5].CGColor, (id)[[UIColor alloc] initWithWhite:1 alpha:0.5], nil];
    
    shadowLayer.startPoint = CGPointMake(10, 0.5);
    shadowLayer.endPoint = CGPointMake(0, 0.5);
    shadowLayer.frame = CGRectMake(0,0,10, CGRectGetHeight(initalFrame));
    
    UIView *shadow = [[UIView alloc]initWithFrame:initalFrame];
    shadow.backgroundColor = [UIColor clearColor];
    [shadow.layer addSublayer:shadowLayer];
    [fromVC.view addSubview:shadow];
    shadow.frame=CGRectMake(-10,0,shadow.frame.size.width,shadow.frame.size.height);
    shadow.alpha = 0.5;
    
    //动画
    [UIView animateWithDuration:[self transitionDuration:transitionContext]
                     animations:^{
                         
                         toVC.view.center = CGPointMake(CGRectGetMidX(initalFrame), CGRectGetMidY(initalFrame));
                         
                         fromVC.view.center = CGPointMake(CGRectGetWidth(initalFrame)*1.5, CGRectGetMidY(initalFrame));
                         
                     }
                     completion:^(BOOL finished) {
                         [shadow removeFromSuperview];
                         [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
                     }];
}


@end
