//
//  JJRouter.m
//  JJRouterDemo
//
//  Created by 房俊杰 on 2018/3/1.
//  Copyright © 2018年 房俊杰. All rights reserved.
//

#import "JJRouter.h"

@interface JJRouterResponse ()

@end
@implementation JJRouterResponse

@end
NSString * const kJJRouterURL = @"openUrl";
NSString * const kJJRouterScheme = @"jj://";
NSString * const kJJRouterHandler = @"-";
NSString * const kJJRouterException = @"exception";
NSString * const kJJRouterErrorURL = @"jj://error";

@interface JJRouter ()

/** 表映射字典 */
@property (nonatomic,strong) NSMutableDictionary *routerDictionary;

@end
@implementation JJRouter
#pragma mark - 公有方法
/**
 获取JJRouter全局唯一单例
 
 @return JJRouter单例
 */
+ (instancetype)sharedRouter {
    static JJRouter *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}
/**
 判断url是否可被打开
 
 @param url 需要判断的url
 @return 是否可被打开
 */
+ (BOOL)routerCanOpenURL:(NSString *)url {
    NSMutableDictionary *subRouters = [[self sharedRouter] routerCanOpenURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kJJRouterScheme,url]]];
    return subRouters ? YES : NO;
}
/**
 注册url
 
 @param url url字符串
 @param handler 回调
 */
+ (void)routerRegisterUrl:(NSString *)url handler:(JJRouterHandler)handler {
    [[self sharedRouter] routerRegisterURLToRoutersWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kJJRouterScheme,url]] handler:handler];
}
/**
 注册错误 做降级处理
 
 @param handler 打开url时触发的block
 */
+ (void)routerRegisterErrorURLWithHandler:(JJRouterHandler)handler {
     [[self sharedRouter] routerRegisterURLToRoutersWithURL:[NSURL URLWithString:kJJRouterErrorURL] handler:handler];
}
/**
 打开url
 
 @param url url字符串
 @param viewController 当前控制器
 */
+ (void)routerOpenUrl:(NSString *)url viewController:(UIViewController *)viewController {
    [self routerOpenUrl:url params:nil viewController:viewController];
}
/**
 打开url
 
 @param url url字符串
 @param params 参数字典
 @param viewController 当前控制器
 */
+ (void)routerOpenUrl:(NSString *)url params:(NSDictionary *)params viewController:(UIViewController *)viewController {
    [self routerOpenUrl:url params:params viewController:viewController callBack:nil];
}
/**
 打开url
 
 @param url url字符串
 @param viewController 当前控制器
 @param callBack 返回block
 */
+ (void)routerOpenUrl:(NSString *)url viewController:(UIViewController *)viewController callBack:(JJRouterCallBack)callBack {
    [self routerOpenUrl:url params:nil viewController:viewController callBack:callBack];
}
/**
 打开url
 
 @param url url字符串
 @param params 参数字典
 @param viewController 当前控制器
 @param callBack 返回block
 */
+ (void)routerOpenUrl:(NSString *)url params:(NSDictionary *)params viewController:(UIViewController *)viewController callBack:(JJRouterCallBack)callBack {
    [[self sharedRouter] routerOpenURLFromRoutersWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kJJRouterScheme,url]] params:params viewController:viewController callBack:callBack];
}
#pragma mark - 私有方法
/** 判断url能否打开 */
- (NSMutableDictionary *)routerCanOpenURL:(NSURL *)url {
    NSMutableString *key = [self routerDecodeTableURL:url];
    if (self.routerDictionary[key]) return self.routerDictionary;
    return nil;
}
/** 注册url */
- (void)routerRegisterURLToRoutersWithURL:(NSURL *)url handler:(JJRouterHandler)handler {
    NSMutableString *key = [self routerDecodeTableURL:url];
    if (!self.routerDictionary[key] && handler) {
        self.routerDictionary[key] = handler;
    }
}
/** 打开url */
- (void)routerOpenURLFromRoutersWithURL:(NSURL *)url params:(NSDictionary *)params viewController:(UIViewController *)viewController callBack:(JJRouterCallBack)callBack {
    //判断能否打开url
    NSMutableDictionary *subRouters = [self routerCanOpenURL:url];
    if (subRouters == nil) {
        NSLog(@"%@未被注册",url);
        return;
    }
    
    //参数字典拼接
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    NSArray<NSURLQueryItem *> *queryItems = [[NSURLComponents alloc] initWithURL:url resolvingAgainstBaseURL:NO].queryItems;
    if (queryItems.count != 0) {
        for (NSURLQueryItem *item in queryItems) {
            parameters[item.name] = item.value;
        }
    }
    //保证在404的情况下，生成的响应对象中的parameters格式和正常情况下的格式相同
    if ([url.absoluteString isEqualToString:kJJRouterErrorURL]) {
        parameters = params.mutableCopy;
    } else {
        parameters[kJJRouterURL] = url.absoluteString;
        if (params) {
            for (NSString *key in params.allKeys) {
                parameters[key] = params[key];
            }
        }
    }
    
    //生成响应对象
    JJRouterResponse *response = [[JJRouterResponse alloc] init];
    response.params = parameters;
    response.viewController = viewController;
    response.callBack = callBack;
    
    //回调响应对象，并进行异常捕获，如捕获异常，则降级处理打开errorurl
    JJRouterHandler handler = subRouters[[self routerDecodeTableURL:url]];
    if (handler) {
        @try {
            handler(response);
        }
        @catch (NSException *exception) {
            parameters[kJJRouterException] = exception;
            [self routerOpenURLFromRoutersWithURL:[NSURL URLWithString:kJJRouterErrorURL] params:parameters viewController:viewController callBack:callBack];
        }
    }
}
/** 解析表url */
- (NSMutableString *)routerDecodeTableURL:(NSURL *)url {
    NSMutableString *string = [NSMutableString string];
    
    if (url.scheme.length) [string appendFormat:@"%@://",url.scheme];
    
    if (url.host.length) [string appendString:url.host];
    
    if (url.path.length) [string appendString:url.path];
    
    return string;
}
#pragma mark - 懒加载
/** 表映射字典 */
- (NSMutableDictionary *)routerDictionary {
    if (!_routerDictionary) {
        _routerDictionary = [NSMutableDictionary dictionary];
    }
    return _routerDictionary;
}
@end









































