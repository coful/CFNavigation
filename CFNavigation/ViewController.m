//
//  ViewController.m
//  CFNavigation
//
//  Created by coful on 17/1/10.
//  Copyright © 2017年 coful. All rights reserved.
//

#import "ViewController.h"
#import "NextViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"push" style:UIBarButtonItemStylePlain target:self action:@selector(pushBtnClick)];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = CGRectMake(0, 0, 200, 50);
    button.center=self.view.center;
    [button setTitle:@"present" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(presentBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];

}

- (void)pushBtnClick {
    NextViewController *vc = [[NextViewController alloc] init];
    vc.title = [NSString stringWithFormat:@"%lu",self.navigationController.viewControllers.count];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)presentBtnClick {
    NextViewController *vc = [[NextViewController alloc] init];
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
