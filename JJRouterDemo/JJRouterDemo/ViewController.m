//
//  ViewController.m
//  JJRouterDemo
//
//  Created by 房俊杰 on 2018/3/1.
//  Copyright © 2018年 房俊杰. All rights reserved.
//

#import "ViewController.h"
#import "JJRouter.h"

@interface ViewController ()

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.title = NSStringFromClass([self class]);
    
}


- (IBAction)buttonClick {
    
//    [JJRouter routerOpenUrl:@"SecondViewController?type=1" params:@{@"id":@"10"} viewController:self];

    [JJRouter routerOpenUrl:@"SecondViewController?phone=18516779543&password=123456" params:@{@"id":@"10"} viewController:self callBack:^(id callBack) {
       
        UIColor *color = callBack;
        
        self.view.backgroundColor = color;
        
    }];
    
}

@end


























