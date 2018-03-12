//
//  SecondViewController.m
//  JJRouterDemo
//
//  Created by 房俊杰 on 2018/3/1.
//  Copyright © 2018年 房俊杰. All rights reserved.
//

#import "SecondViewController.h"
#import "JJRouter.h"

@interface SecondViewController ()

/** callback */
@property (nonatomic,strong) JJRouterCallBack callBack;

@end

@implementation SecondViewController

+ (void)load {
    [JJRouter routerRegisterUrl:NSStringFromClass([self class]) handler:^(JJRouterResponse *response) {

        NSLog(@"SecondViewController:%@",response.params);
        //打开捕获异常
//        NSMutableArray *array = [NSMutableArray array];
//        [array addObject:response.params[@"a"]];

        SecondViewController *second = [[SecondViewController alloc] init];
        second.callBack = response.callBack;
        [response.viewController.navigationController pushViewController:second animated:YES];

    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = NSStringFromClass([self class]);
    self.view.backgroundColor = [UIColor orangeColor];
    
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];

    
//    CGFloat r = arc4random_uniform(255) / 255.0;
//    CGFloat g = arc4random_uniform(255) / 255.0;
//    CGFloat b = arc4random_uniform(255) / 255.0;
//
//    UIColor *color = [UIColor colorWithRed:r green:g blue:b alpha:1.0];
//    !self.callBack ? : self.callBack(color);
//
//    [self.navigationController popViewControllerAnimated:YES];
    
    
    //跳转第三个页面
    [JJRouter routerOpenUrl:@"ThirdViewController" params:nil viewController:self];

    
    
}
- (void)dealloc {
    NSLog(@"SecondViewController释放了");
}
@end




















