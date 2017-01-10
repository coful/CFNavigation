//
//  CFViewController.m
//  coful
//
//  Created by coful on 16/5/19.
//  Copyright © 2016年 coful. All rights reserved.
//

#define KEY_WINDOW  [[UIApplication sharedApplication]keyWindow]
#define kScreenSize [UIScreen mainScreen].bounds
#define kScreenWidth kScreenSize.size.width
#define kScreenHeight kScreenSize.size.height

#import "CFViewController.h"
#import "AnimateForPresented.h"
#import "AnimateForDismissed.h"

@interface CFViewController ()

@property (nonatomic,strong) UIPercentDrivenInteractiveTransition *percentDrivenTransition;

@end

@implementation CFViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)viewWillAppear:(BOOL)animated;{
    [super viewWillAppear:animated];
}


- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear: animated];
    
}

- (void)presentViewController:(UIViewController *)viewControllerToPresent animated: (BOOL)flag completion:(void (^ __nullable)(void))completion{
    
    if ([viewControllerToPresent isKindOfClass:[CFViewController class]] ) {
        //|| [viewControllerToPresent isKindOfClass:[CFNavigationController class]]
        
        viewControllerToPresent.transitioningDelegate = self;
        
        UIScreenEdgePanGestureRecognizer *edgePan = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handleEdgePanGesture:)];
        edgePan.edges = UIRectEdgeLeft;
        [viewControllerToPresent.view addGestureRecognizer:edgePan];
        
    }
    
    [super presentViewController:viewControllerToPresent animated:flag completion:completion];
}

-(void)handleRightPanGesture:(UIPanGestureRecognizer *)sender{
    //     NSLog(@"CFViewController");
    
    CGPoint point = [sender translationInView:sender.view];
    CGFloat progress = fabs([sender translationInView:KEY_WINDOW].x)/KEY_WINDOW.bounds.size.width;
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        _percentDrivenTransition = [[UIPercentDrivenInteractiveTransition alloc] init];
        if (point.x>0) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }else if(sender.state == UIGestureRecognizerStateChanged){
        [_percentDrivenTransition updateInteractiveTransition:progress];
    }else if(sender.state == UIGestureRecognizerStateCancelled || sender.state == UIGestureRecognizerStateEnded){
        if (progress>0.5) {
            [_percentDrivenTransition finishInteractiveTransition];
        }else{
            [_percentDrivenTransition cancelInteractiveTransition];
        }
        _percentDrivenTransition = nil;
    }
}

-(void)handleEdgePanGesture:(UIScreenEdgePanGestureRecognizer *)sender{
    CGFloat progress = ABS([sender translationInView:KEY_WINDOW].x)/KEY_WINDOW.bounds.size.width;
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        _percentDrivenTransition = [[UIPercentDrivenInteractiveTransition alloc] init];
        [self dismissViewControllerAnimated:YES completion:nil];
    }else if(sender.state == UIGestureRecognizerStateChanged){
        [_percentDrivenTransition updateInteractiveTransition:progress];
    }else if(sender.state == UIGestureRecognizerStateCancelled || sender.state == UIGestureRecognizerStateEnded){
        if (progress>0.5) {
            [_percentDrivenTransition finishInteractiveTransition];
        }else{
            [_percentDrivenTransition cancelInteractiveTransition];
        }
        _percentDrivenTransition = nil;
    }
    
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    return [[AnimateForPresented alloc] init];
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    return [[AnimateForDismissed alloc] init];
}

- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id <UIViewControllerAnimatedTransitioning>)animator{
    return _percentDrivenTransition;
}

- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id <UIViewControllerAnimatedTransitioning>)animator{
    return _percentDrivenTransition;
}

@end
