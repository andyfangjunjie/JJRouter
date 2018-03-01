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
NSString * const kJJRouterURL = @"url";
NSString * const kJJRouterScheme = @"jj://";
NSString * const kJJRouterParams = @"params";
NSString * const kJJRouterHandler = @"-";
NSString * const kJJRouterException = @"exception";
NSString * const kJJRouterErrorURL = @"jj://error";

@interface JJRouter ()

/** 折叠表映射字典表 */
@property (nonatomic,strong) NSMutableDictionary *foldRouterDictionary;
/** 平铺表映射字典表 */
@property (nonatomic,strong) NSMutableDictionary *tileRouterDictionary;

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
 @param params 参数字典
 @param viewController 当前控制器
 */
+ (void)routerOpenUrl:(NSString *)url params:(NSDictionary *)params viewController:(UIViewController *)viewController {
    [[self sharedRouter] routerOpenURLFromRoutersWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kJJRouterScheme,url]] params:params viewController:viewController];
}
#pragma mark - 私有方法
/** 注册url */
- (void)routerRegisterURLToRoutersWithURL:(NSURL *)url handler:(JJRouterHandler)handler {
    if (self.tableType == JJRouterTableTypeFold) {
        NSMutableArray *components = [self routerDecodeFoldURL:url];
        NSMutableDictionary *subRouters = self.foldRouterDictionary;
        for (NSString *component in components) {
            if (!subRouters[component]) {
                subRouters[component] = [NSMutableDictionary dictionary];
            }
            subRouters = subRouters[component];
        }
        if (handler) {
            subRouters[kJJRouterHandler] = handler;
        }
    } else if (self.tableType == JJRouterTableTypeTile) {
        NSMutableString *key = [self routerDecodeTileURL:url];
        NSMutableDictionary *tileRouters = self.tileRouterDictionary;
        if (!tileRouters[key] && handler) {
            tileRouters[key] = handler;
        }
    }
}
/** 打开url */
- (void)routerOpenURLFromRoutersWithURL:(NSURL *)url params:(NSDictionary *)params viewController:(UIViewController *)viewController {
    //判断能否打开url
    NSMutableDictionary *subRouters = [self routerCanOpenURL:url];
    if (subRouters == nil) return;
    
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
        parameters[kJJRouterParams] = params;
    }
    
    //生成响应对象
    JJRouterResponse *response = [[JJRouterResponse alloc] init];
    response.params = parameters;
    response.viewController = viewController;
    
    //回调响应对象，并进行异常捕获，如捕获异常，则降级处理打开errorurl
    if (self.tableType == JJRouterTableTypeFold) {
        JJRouterHandler handler = subRouters[kJJRouterHandler];
        if (handler) {
            @try {
                handler(response);
            }
            @catch (NSException *exception) {
                NSMutableDictionary *paramsError = [NSMutableDictionary dictionaryWithDictionary:parameters];
                paramsError[kJJRouterException] = exception;
                [self routerOpenURLFromRoutersWithURL:[NSURL URLWithString:kJJRouterErrorURL] params:paramsError viewController:viewController];
            }
        }
    } else if (self.tableType == JJRouterTableTypeTile) {
        JJRouterHandler handler = subRouters[[self routerDecodeTileURL:url]];
        if (handler) {
            @try {
                handler(response);
            }
            @catch (NSException *exception) {
                NSMutableDictionary *paramsError = [NSMutableDictionary dictionaryWithDictionary:parameters];
                paramsError[kJJRouterException] = exception;
                [self routerOpenURLFromRoutersWithURL:[NSURL URLWithString:kJJRouterErrorURL] params:paramsError viewController:viewController];
            }
        }
    }
}
/** 判断url能否打开 */
- (NSMutableDictionary *)routerCanOpenURL:(NSURL *)url {
    if (self.tableType == JJRouterTableTypeFold) {
        NSMutableArray *components = [self routerDecodeFoldURL:url];
        NSMutableDictionary *subRouters = self.foldRouterDictionary;
        for (NSString *component in components) {
            BOOL found = NO;
            NSArray *subRouterKeys = subRouters.allKeys;
            for (NSString *key in subRouterKeys) {
                if ([key isEqualToString:component]) {
                    found = YES;
                    subRouters = subRouters[key];
                    break;
                }
            }
            if (!found) return nil;
        }
        return subRouters;
    } else if (self.tableType == JJRouterTableTypeTile) {
        NSMutableString *key = [self routerDecodeTileURL:url];
        NSMutableDictionary *tileRouters = self.tileRouterDictionary;
        if (tileRouters[key]) {return tileRouters;}
        return nil;
    } else {
        return nil;
    }
}

/** 解析折叠表url */
- (NSMutableArray *)routerDecodeFoldURL:(NSURL *)url {
    NSMutableArray *array = [NSMutableArray array];
    
    if (url.scheme.length) [array addObject:url.scheme];
    
    if (url.host.length) [array addObject:url.host];
    
    if (!url.pathComponents.count) return array;
    
    for (NSString *component in url.pathComponents) {
        if ([component isEqualToString:@"/"]) continue;
        [array addObject:component];
    }
    return array;
}
/** 解析平铺表url */
- (NSMutableString *)routerDecodeTileURL:(NSURL *)url {
    NSMutableString *string = [NSMutableString string];
    
    if (url.scheme.length) [string appendFormat:@"%@://",url.scheme];
    
    if (url.host.length) [string appendString:url.host];
    
    if (url.path.length) [string appendString:url.path];
    
    return string;
}
#pragma mark - 懒加载
/** 折叠表映射字典表 */
- (NSMutableDictionary *)foldRouterDictionary {
    if (!_foldRouterDictionary) {
        _foldRouterDictionary = [NSMutableDictionary dictionary];
    }
    return _foldRouterDictionary;
}
/** 平铺表映射字典表 */
- (NSMutableDictionary *)tileRouterDictionary {
    if (!_tileRouterDictionary) {
        _tileRouterDictionary = [NSMutableDictionary dictionary];
    }
    return _tileRouterDictionary;
}
@end









































