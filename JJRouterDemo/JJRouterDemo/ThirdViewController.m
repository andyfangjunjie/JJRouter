//
//  ThirdViewController.m
//  JJRouterDemo
//
//  Created by 房俊杰 on 2018/3/1.
//  Copyright © 2018年 房俊杰. All rights reserved.
//

#import "ThirdViewController.h"
#import "JJRouter.h"

@interface ThirdViewController ()

@end

@implementation ThirdViewController
+ (void)load {
    [JJRouter routerRegisterUrl:[NSString stringWithFormat:@"%@",NSStringFromClass([self class])] handler:^(JJRouterResponse *response) {
        
        ThirdViewController *third = [[ThirdViewController alloc] init];
        [response.viewController.navigationController pushViewController:third animated:YES];
        
    }];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = NSStringFromClass([self class]);
    self.view.backgroundColor = [UIColor yellowColor];
}
- (void)dealloc {
    NSLog(@"ThirdViewController释放了");
}


@end
