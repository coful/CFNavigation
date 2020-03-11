//
//  CFNavigationController.m
//  CFNavigationController
//
//  Created by coful on 16/4/6.
//  Copyright © 2016年 coful. All rights reserved.
//
#define KEY_WINDOW  [[UIApplication sharedApplication]keyWindow]
#define TOP_VIEW  [[UIApplication sharedApplication]keyWindow].rootViewController.view
#define kScreenSize [UIScreen mainScreen].bounds
#define kScreenWidth kScreenSize.size.width
#define kScreenHeight kScreenSize.size.height

#import "CFNavigationController.h"
#import "AnimateForPushTransion.h"
#import "AnimateForPopTransion.h"

@interface CFNavigationController ()
{
    CGPoint startTouch;
    
    UIImageView *lastScreenShotView;
    
    UIView *shadow;
    
}

@property (nonatomic,retain) UIView *backgroundView;
@property (nonatomic,retain) NSMutableArray *screenShotsList;

@property (nonatomic,assign) BOOL isMoving;

@property (nonatomic, strong) AnimateForPushTransion *pushTransionAnimator;
@property (nonatomic, strong) AnimateForPopTransion *popTransionAnimator;

@end

@implementation CFNavigationController

//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        self.canDragBack = YES;
//    }
//    return self;
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.delegate=self;
    self.canDragBack = YES;
    self.screenShotsList = [[NSMutableArray alloc] initWithCapacity:2];
    
    if (@available(iOS 13.0, *)) {
        self.interactivePopGestureRecognizer.enabled = YES;
    }else{
        [self addPanGestureRecognizer:self.view];
        //使原来UINavigationController边缘滑动手势返回不可用
        self.interactivePopGestureRecognizer.enabled = NO;
    }
}


-(void)addPanGestureRecognizer:(UIView *) view{
    UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self
                                                                                action:@selector(handleRightPanGesture:)];
    
    //        UIScreenEdgePanGestureRecognizer *recognizer = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handleEdgePanGesture:)];
    //        recognizer.edges = UIRectEdgeLeft;
    
    recognizer.delegate = self;
    //    NSLog(@"addPanGestureRecognizer %@",view);
    [recognizer delaysTouchesBegan];
    [view addGestureRecognizer:recognizer];
}

- (void)viewWillAppear:(BOOL)animated;{
    [super viewWillAppear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:(BOOL)animated];
    
    if (self.screenShotsList.count == 0) {
        
        UIImage *capturedImage = [self capture];
        
        if (capturedImage) {
            [self.screenShotsList addObject:capturedImage];
        }
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear: animated];
}

-(void)dealloc{
    [self.screenShotsList removeAllObjects];
    
    //    NSLog(@"CFNavigationController 销毁");
}

// override the push method
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    UIImage *capturedImage = [self capture];
    
    if (capturedImage) {
        [self.screenShotsList addObject:capturedImage];
    }
    
    //    NSLog(@"push screenShotsList: %lu",(unsigned long)self.screenShotsList.count);
    
    if (@available(iOS 13.0, *)) {
        //添加手势
        [self addPanGestureRecognizer:viewController.view];
    }
    
    [super pushViewController:viewController animated:animated];
    
}

// override the pop method
- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
    
    [self.screenShotsList removeLastObject];
    
    //    NSLog(@"pop screenShotsList: %lu",(unsigned long)self.screenShotsList.count);
    
    return [super popViewControllerAnimated:animated];
}

// get the current view screen shot
- (UIImage *)capture
{
    UIGraphicsBeginImageContextWithOptions(TOP_VIEW.bounds.size, TOP_VIEW.opaque, 0.0);
    [TOP_VIEW.layer renderInContext:UIGraphicsGetCurrentContext()];
    //    NSLog(@"capture w: %f",TOP_VIEW.bounds.size.width);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    //    NSLog(@"img : %@",img);
    UIGraphicsEndImageContext();
    
    return img;
}

// set lastScreenShotView 's position and alpha when paning
- (void)moveViewWithX:(float)x
{
    
    //    NSLog(@"Move to:%f",x);
    x = x>320?320:x;
    x = x<0?0:x;
    
    CGRect frame = TOP_VIEW.frame;
    frame.origin.x = x;
    TOP_VIEW.frame = frame;
    
    CGRect lssframe = lastScreenShotView.frame;
    lssframe.origin.x = (x-320)/2;
    lastScreenShotView.frame = lssframe;
    
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (self.viewControllers.count <= 1 || !self.canDragBack) return NO;
    
    // 输出点击的view的类名
    //    NSLog(@"%@", NSStringFromClass([touch.view class]));
    
    // 若为UITableViewCellContentView（即点击了tableViewCell），则不截获Touch事件
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]) {
        return NO;
    }
    
    return YES;
}

-(void)handleEdgePanGesture:(UIScreenEdgePanGestureRecognizer *)sender{
    
    CGFloat progress = ABS([sender translationInView:KEY_WINDOW].x)/KEY_WINDOW.bounds.size.width;
    //    CGPoint touchPoint = [sender locationInView:KEY_WINDOW];
//    NSLog(@"handleEdgePanGesture");
    
//    NSLog(@"%f", progress);
    
    if (self.viewControllers.count <= 1 || !self.canDragBack) return;
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        _isMoving = YES;
        //        startTouch = touchPoint;
        
        if (!self.backgroundView)
        {
            CGRect frame = TOP_VIEW.frame;
            
            self.backgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width , frame.size.height)];
            [TOP_VIEW.superview insertSubview:self.backgroundView belowSubview:TOP_VIEW];
            
            //添加阴影效果
            CAGradientLayer *shadowLayer = [CAGradientLayer layer];
            
            shadowLayer.colors = [NSArray arrayWithObjects:(id)[[UIColor alloc] initWithWhite:0 alpha:1].CGColor, (id)[[UIColor alloc] initWithWhite:0 alpha:0.5].CGColor, (id)[[UIColor alloc] initWithWhite:1 alpha:0.5], nil];
            
            shadowLayer.startPoint = CGPointMake(10, 0.5);
            shadowLayer.endPoint = CGPointMake(0, 0.5);
            shadowLayer.frame = CGRectMake(0,0,10, frame.size.height);
            
            shadow = [[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width , frame.size.height)];
            shadow.backgroundColor = [UIColor clearColor];
            [shadow.layer addSublayer:shadowLayer];
            shadow.frame=CGRectMake(-10,0,shadow.frame.size.width,shadow.frame.size.height);
            shadow.alpha = 0.5;
            
            [TOP_VIEW addSubview:shadow];
            
        }
        
        shadow.hidden = NO;
        self.backgroundView.hidden = NO;
        
        if (lastScreenShotView) [lastScreenShotView removeFromSuperview];
        
        UIImage *lastScreenShot = [self.screenShotsList lastObject];
        lastScreenShotView = [[UIImageView alloc]initWithImage:lastScreenShot];
        [self.backgroundView addSubview:lastScreenShotView];
        
    }else if(sender.state == UIGestureRecognizerStateChanged){
    }else if(sender.state == UIGestureRecognizerStateEnded){
        if (progress > 0.5)
            //        if (touchPoint.x - startTouch.x > 80)
        {
            [UIView animateWithDuration:0.3 animations:^{
                [self moveViewWithX:320];
            } completion:^(BOOL finished) {
                
                [self popViewControllerAnimated:NO];
                CGRect frame = TOP_VIEW.frame;
                frame.origin.x = 0;
                TOP_VIEW.frame = frame;
                
                _isMoving = NO;
                self.backgroundView.hidden = YES;
                shadow.hidden = YES;
            }];
        }
        else
        {
            [UIView animateWithDuration:0.3 animations:^{
                [self moveViewWithX:0];
            } completion:^(BOOL finished) {
                _isMoving = NO;
                self.backgroundView.hidden = YES;
                shadow.hidden = YES;
            }];
            
        }
        return;
    }else if(sender.state == UIGestureRecognizerStateCancelled){
        [UIView animateWithDuration:0.3 animations:^{
            [self moveViewWithX:0];
        } completion:^(BOOL finished) {
            _isMoving = NO;
            self.backgroundView.hidden = YES;
            shadow.hidden = YES;
        }];
        
        return;
    }
    
    if (_isMoving) {
        //        [self moveViewWithX:touchPoint.x - startTouch.x];
        [self moveViewWithX:progress * kScreenWidth];
    }
}


#pragma mark - Gesture Recognizer -

- (void)handleRightPanGesture:(UIPanGestureRecognizer *)recoginzer
{
//    NSLog(@"handleRightPanGesture");
    
    // If the viewControllers has only one vc or disable the interaction, then return.
    if (self.viewControllers.count <= 1 || !self.canDragBack) return;
    
    // we get the touch position by the window's coordinate
    CGPoint touchPoint = [recoginzer locationInView:KEY_WINDOW];
    
//    NSLog(@"%f", touchPoint.x);
    
    // begin paning, show the backgroundView(last screenshot),if not exist, create it.
    if (recoginzer.state == UIGestureRecognizerStateBegan) {
        
        _isMoving = YES;
        startTouch = touchPoint;
        
        if (!self.backgroundView)
        {
            CGRect frame = TOP_VIEW.frame;
            
            self.backgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width , frame.size.height)];
            [TOP_VIEW.superview insertSubview:self.backgroundView belowSubview:TOP_VIEW];
            
            //添加阴影效果
            CAGradientLayer *shadowLayer = [CAGradientLayer layer];
            
            shadowLayer.colors = [NSArray arrayWithObjects:(id)[[UIColor alloc] initWithWhite:0 alpha:1].CGColor, (id)[[UIColor alloc] initWithWhite:0 alpha:0.5].CGColor, (id)[[UIColor alloc] initWithWhite:1 alpha:0.5], nil];
            
            shadowLayer.startPoint = CGPointMake(10, 0.5);
            shadowLayer.endPoint = CGPointMake(0, 0.5);
            shadowLayer.frame = CGRectMake(0,0,10, frame.size.height);
            
            shadow = [[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width , frame.size.height)];
            shadow.backgroundColor = [UIColor clearColor];
            [shadow.layer addSublayer:shadowLayer];
            shadow.frame=CGRectMake(-10,0,shadow.frame.size.width,shadow.frame.size.height);
            shadow.alpha = 0.5;
            
            [TOP_VIEW addSubview:shadow];
            
        }
        
        shadow.hidden = NO;
        self.backgroundView.hidden = NO;
        
        if (lastScreenShotView) [lastScreenShotView removeFromSuperview];
        
        UIImage *lastScreenShot = [self.screenShotsList lastObject];
        lastScreenShotView = [[UIImageView alloc]initWithImage:lastScreenShot];
        [self.backgroundView addSubview:lastScreenShotView];
        
        //End paning, always check that if it should move right or move left automatically
    }else if (recoginzer.state == UIGestureRecognizerStateEnded){
        
        if (touchPoint.x - startTouch.x > 80)
        {
            [UIView animateWithDuration:0.3 animations:^{
                [self moveViewWithX:320];
            } completion:^(BOOL finished) {
                
                [self popViewControllerAnimated:NO];
                CGRect frame = TOP_VIEW.frame;
                frame.origin.x = 0;
                TOP_VIEW.frame = frame;
                
                _isMoving = NO;
                self.backgroundView.hidden = YES;
                shadow.hidden = YES;
            }];
        }
        else
        {
            [UIView animateWithDuration:0.3 animations:^{
                [self moveViewWithX:0];
            } completion:^(BOOL finished) {
                _isMoving = NO;
                self.backgroundView.hidden = YES;
                shadow.hidden = YES;
            }];
            
        }
        return;
        
        // cancal panning, alway move to left side automatically
    }else if (recoginzer.state == UIGestureRecognizerStateCancelled){
        
        [UIView animateWithDuration:0.3 animations:^{
            [self moveViewWithX:0];
        } completion:^(BOOL finished) {
            _isMoving = NO;
            self.backgroundView.hidden = YES;
            shadow.hidden = YES;
        }];
        
        return;
    }
    
    // it keeps move with touch
    if (_isMoving) {
        [self moveViewWithX:touchPoint.x - startTouch.x];
    }
}

- (id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                   animationControllerForOperation:(UINavigationControllerOperation)operation
                                                fromViewController:(UIViewController *)fromVC
                                                  toViewController:(UIViewController *)toVC {
    if (operation == UINavigationControllerOperationPush) {
        if (self.pushTransionAnimator == nil) {
            self.pushTransionAnimator = [AnimateForPushTransion new];
        }
        return self.pushTransionAnimator;
    } else {
        if (self.popTransionAnimator == nil) {
            self.popTransionAnimator = [AnimateForPopTransion new];
        }
        return self.popTransionAnimator;
    }
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    
    //    NSLog(@"viewControllers---%lu",(unsigned long)self.viewControllers.count);
    //    NSLog(@"gestureRecognizers---%lu",self.view.gestureRecognizers.count);
    
}

@end
