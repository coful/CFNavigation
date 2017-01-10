//
//  AnimateForPopTransion.m
//  CFNavigationController
//
//  Created by coful on 16/4/6.
//  Copyright © 2016年 coful. All rights reserved.
//

#import "AnimateForPopTransion.h"

@interface AnimateForPopTransion ()

@end

@implementation AnimateForPopTransion


- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext {
    return 0.5;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *container = [transitionContext containerView];
    [container addSubview:toVC.view];
    [container addSubview:fromVC.view];
    
    //截图
    UIGraphicsBeginImageContextWithOptions([fromVC navigationController].view.bounds.size, YES, 0.0);
    
    [[fromVC navigationController].view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *fromVCImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //设置anrchPoint 和 position
    CGRect initalFrame = [transitionContext initialFrameForViewController:fromVC];
    toVC.view.frame = initalFrame;
    fromVC.view.frame = initalFrame;
    
    //加载截图
    UIImageView *captureView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, [fromVC navigationController].navigationBar.frame.size.width, [fromVC navigationController].navigationBar.frame.size.height+21)];
    captureView.clipsToBounds=YES; //超出部分剪掉
    captureView.contentMode=UIViewContentModeTop;
    captureView.image=fromVCImage;
    [toVC.view addSubview:captureView];
    
    //初始位置
    toVC.view.center = CGPointMake(CGRectGetMidX(initalFrame)*0.25, CGRectGetMidY(initalFrame));
    [toVC navigationController].navigationBar.alpha=1;
    [toVC navigationController].navigationBar.center = CGPointMake(CGRectGetWidth(initalFrame)*0.5, [toVC navigationController].navigationBar.center.y);
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
                         
                         [toVC navigationController].navigationBar.center=CGPointMake(CGRectGetWidth(initalFrame)*1.5, [toVC navigationController].navigationBar.center.y);
                         fromVC.view.center = CGPointMake(CGRectGetWidth(initalFrame)*1.5, CGRectGetMidY(initalFrame));
                         
                     }
                     completion:^(BOOL finished) {
                         [toVC navigationController].navigationBar.center=CGPointMake(CGRectGetWidth(initalFrame)*0.5, [toVC navigationController].navigationBar.center.y);
                         
                         [captureView removeFromSuperview];
                         
                         [shadow removeFromSuperview];
                         [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
                     }];
}

- (void)animationEnded:(BOOL)transitionCompleted {
    
}

@end
