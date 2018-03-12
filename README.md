# JJRouter
轻量级路由设计，用法简单

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
