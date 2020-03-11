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
    
    //viewDidLoad self.navigationController为nil 未入栈
//    NSLog(@"self.navigationController %@",self.navigationController);
    
    [button setTitle:@"back" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(backClick) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:button];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //已入栈
//    NSLog(@"viewDidAppear self.navigationController %@",self.navigationController);
}


- (void)pushBtnClick {
    NSLog(@"pushBtnClick");
    
//    NSLog(@"self.navigationController %@",self.navigationController);
    
    NextViewController *vc = [[NextViewController alloc] init];
    vc.title = [NSString stringWithFormat:@"%lu",self.navigationController.viewControllers.count];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)backClick {
    
//    NSLog(@"self.navigationController %@",self.navigationController);
    
    if(self.navigationController){
        NSLog(@"pop");
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
        NSLog(@"dismiss");
    }
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
