//
//  JJRouter.h
//  JJRouterDemo
//
//  Created by 房俊杰 on 2018/3/1.
//  Copyright © 2018年 房俊杰. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 block

 @param callBack 返回对象
 */
typedef void(^JJRouterCallBack)(id callBack);

@interface JJRouterResponse : NSObject

/** 参数 */
@property (nonatomic,strong) NSDictionary *params;
/** 控制器 */
@property (nonatomic,strong) UIViewController *viewController;
/** 返回block */
@property (nonatomic,strong) JJRouterCallBack callBack;

@end

/**
 block

 @param response 返回对象
 */
typedef void(^JJRouterHandler)(JJRouterResponse *response);


@interface JJRouter : NSObject

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

/**
 判断url是否可被打开
 
 @param url 需要判断的url
 @return 是否可被打开
 */
+ (BOOL)routerCanOpenURL:(NSString *)url;
/**
 注册url

 @param url url字符串
 @param handler 回调
 */
+ (void)routerRegisterUrl:(NSString *)url handler:(JJRouterHandler)handler;
/**
 注册错误 做降级处理
 
 @param handler 打开url时触发的block
 */
+ (void)routerRegisterErrorURLWithHandler:(JJRouterHandler)handler;
/**
 打开url
 
 @param url url字符串
 @param viewController 当前控制器
 */
+ (void)routerOpenUrl:(NSString *)url viewController:(UIViewController *)viewController;
/**
 打开url

 @param url url字符串
 @param params 参数字典
 @param viewController 当前控制器
 */
+ (void)routerOpenUrl:(NSString *)url params:(NSDictionary *)params viewController:(UIViewController *)viewController;
/**
 打开url
 
 @param url url字符串
 @param viewController 当前控制器
 @param callBack 返回block
 */
+ (void)routerOpenUrl:(NSString *)url viewController:(UIViewController *)viewController callBack:(JJRouterCallBack)callBack;
/**
 打开url
 
 @param url url字符串
 @param params 参数字典
 @param viewController 当前控制器
 @param callBack 返回block
 */
+ (void)routerOpenUrl:(NSString *)url params:(NSDictionary *)params viewController:(UIViewController *)viewController callBack:(JJRouterCallBack)callBack;
@end

























