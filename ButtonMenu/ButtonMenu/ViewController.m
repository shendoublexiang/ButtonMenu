//
//  ViewController.m
//  ButtonMenu
//
//  Created by sherry on 16/5/26.
//  Copyright © 2016年 sherry. All rights reserved.
//

#import "ViewController.h"
#import "ButtonMenu.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    ButtonMenu * btn = [[ButtonMenu alloc] initWithFrame:CGRectMake(0, 60, 0, 0)];
    
    [self.view addSubview:btn];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




@end
