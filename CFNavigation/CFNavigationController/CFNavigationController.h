//
//  CFNavigationController.h
//  CFNavigationController
//
//  Created by coful on 16/4/6.
//  Copyright © 2016年 coful. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CFNavigationController : UINavigationController <UINavigationControllerDelegate,UIGestureRecognizerDelegate>

@property (nonatomic,assign) BOOL canDragBack;

@end
