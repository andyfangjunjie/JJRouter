//
//  ErrorViewController.m
//  JJRouterDemo
//
//  Created by 房俊杰 on 2018/3/1.
//  Copyright © 2018年 房俊杰. All rights reserved.
//

#import "ErrorViewController.h"
#import "JJRouter.h"

@interface ErrorViewController ()
/** label */
@property (nonatomic,strong) UILabel *errorLabel;
@property (strong, nonatomic) NSDictionary *params;
@end

@implementation ErrorViewController

+ (void)load {
    [JJRouter routerRegisterErrorURLWithHandler:^(JJRouterResponse *response) {
       
        NSLog(@"error : %@",response.params);
        ErrorViewController *error = [[ErrorViewController alloc] init];
        error.params = response.params;
        [response.viewController.navigationController pushViewController:error animated:YES];
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = NSStringFromClass([self class]);
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.errorLabel.text = [NSString stringWithFormat:@"%@", self.params];
    [self.errorLabel sizeToFit];
    [self.view addSubview:self.errorLabel];
}

- (UILabel *)errorLabel {
    if (!_errorLabel) {
        CGFloat y = [UIApplication sharedApplication].statusBarFrame.size.height+self.navigationController.navigationBar.bounds.size.height;
        _errorLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, y, self.view.bounds.size.width-20, 0)];
        _errorLabel.textColor = [UIColor blackColor];
        _errorLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightRegular];
        _errorLabel.textAlignment = NSTextAlignmentLeft;
        _errorLabel.numberOfLines = 0;
        [self.view addSubview:_errorLabel];
    }
    return _errorLabel;
}

@end
