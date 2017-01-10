//
//  NextViewController.m
//  CFNavigation
//
//  Created by coful on 17/1/10.
//  Copyright © 2017年 coful. All rights reserved.
//

#import "NextViewController.h"

@interface NextViewController ()

@end

@implementation NextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"push" style:UIBarButtonItemStylePlain target:self action:@selector(pushBtnClick)];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = CGRectMake(0, 0, 200, 50);
    button.center=self.view.center;
    if(self.navigationController){
        [button setTitle:@"pop" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(popBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    else{
        [button setTitle:@"dismiss" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(dismissBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    
    [self.view addSubview:button];
}


- (void)pushBtnClick {
    NextViewController *vc = [[NextViewController alloc] init];
    vc.title = [NSString stringWithFormat:@"%lu",self.navigationController.viewControllers.count];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)popBtnClick {
    [self.navigationController popViewControllerAnimated:YES];
    NSLog(@"pop");
}

- (void)dismissBtnClick {
    [self dismissViewControllerAnimated:YES completion:nil];
    NSLog(@"dismiss");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
