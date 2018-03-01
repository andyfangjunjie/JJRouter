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

+ (void)load {
    [JJRouter routerRegisterUrl:[NSString stringWithFormat:@"%@",NSStringFromClass([self class])] handler:^(JJRouterResponse *response) {
        
        NSLog(@"%@",response.params);
        [response.viewController.navigationController popViewControllerAnimated:YES];
        response.viewController.view.backgroundColor = response.params[@"params"][@"color"];
        
        
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.title = NSStringFromClass([self class]);
    
}


- (IBAction)buttonClick {
    
    [JJRouter routerOpenUrl:@"SecondViewController?type=1" params:@{@"id":@"10"} viewController:self];
    
    
}

@end


























