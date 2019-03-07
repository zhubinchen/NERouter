//
//  NERouter.m
//  NewsEarn
//
//  Created by zhubch on 2018/8/1.
//  Copyright © 2018年 CooHua. All rights reserved.
//

#import "NERouter.h"
#import "UIViewController+TopMost.h"
#import <objc/runtime.h>

@interface NEDefaultHandler()
@property (nonatomic,copy) NEHandlerBlock block;
@property (nonatomic,strong) id target;
@property (nonatomic,assign) SEL sel;
@end

@implementation NEDefaultHandler

+ (instancetype)handlerForBlock:(NEHandlerBlock)block{
    NEDefaultHandler *handler = [[self alloc] init];
    handler.block = block;
    return handler;
}

+ (instancetype)handlerForTarget:(id)target selector:(SEL)sel {
    NEDefaultHandler *handler = [[self alloc] init];
    handler.target = target;
    handler.sel = sel;
    return handler;
}

- (void)openFromURL:(NSString *)url withParams:(NSDictionary *)params completion:(void (^)(NSDictionary *))completion {
    if (self.block) {
        self.block(url, params, completion);
    }

    NSMethodSignature *signature = [self.target methodSignatureForSelector:self.sel];
    IMP imp = [self.target methodForSelector:self.sel];

    if (signature.numberOfArguments == 0) {
        void (*func)(id, SEL) = (void *)imp;
        func(self.target, self.sel);
    } else if (signature.numberOfArguments == 1) {
        void (*func)(id, SEL, id) = (void *)imp;
        func(self.target, self.sel, params);
    }
    completion(nil);
}

@end

@interface NERouter()
@property (nonatomic,strong) NSMutableDictionary *registerTable;
@end

@implementation NERouter

+ (void)load {
    
}

+ (instancetype)sharedRouter {
    static dispatch_once_t onceToken;
    static NERouter *router = nil;
    dispatch_once(&onceToken, ^{
        router = [[self alloc] init];
    });
    return router;
}

- (instancetype)init {
    if (self = [super init]) {
        _registerTable = @{}.mutableCopy;
    }
    return self;
}

- (NSArray *)allRegisteredURLs {
    return self.registerTable.allKeys;
}

- (void)registerURL:(NSString *)url forHandler:(id<NERouterHandler>)handler {
    NSString *realURL = [url componentsSeparatedByString:@"?"].firstObject.lowercaseString;
    if (self.registerTable[realURL]) {
        NSLog(@"WARNING: Duplicate URL%@",realURL);
    }
    self.registerTable[realURL] = handler;
}

- (void)registerURL:(NSString *)url forTarget:(id)target selector:(SEL)sel {
    id<NERouterHandler> handler = [NEDefaultHandler handlerForTarget:target selector:sel];
    [self registerURL:url forHandler:handler];
}

- (void)registerURL:(NSString *)url forBlock:(void (^)(NSDictionary *, void (^)(NSDictionary *)))block {
    id<NERouterHandler> handler = [NEDefaultHandler handlerForBlock:^(NSString *url, NSDictionary *params, void (^completion)(NSDictionary *)) {
        block(params,completion);
    }];
    [self registerURL:url forHandler:handler];
}

- (void)registerURL:(NSString *)url forViewControllerClass:(Class)clazz {
    if (![clazz isSubclassOfClass:UIViewController.class]) {
        NSLog(@"WARNING: %@ is NOT subclass of UIViewController",NSStringFromClass(clazz));
    }
    NEDefaultHandler *handler = [NEDefaultHandler handlerForBlock:^(NSString *url, NSDictionary *params, void (^completion)(NSDictionary *)) {
        NSObject<NERouterHandler> *obj = [[clazz alloc] init];
        if ([obj respondsToSelector:@selector(openFromURL:withParams:completion:)]) {
            [obj openFromURL:url withParams:params completion:completion];
        }
        if ([obj isKindOfClass:UIViewController.class]) {
            [UIViewController.topMost.navigationController pushViewController:(UIViewController*)obj animated:YES];
        }
    }];
    [self registerURL:url forHandler:handler];
}

- (void)unregisterURL:(NSString *)url {
    NSString *realURL = [url componentsSeparatedByString:@"?"].firstObject.lowercaseString;
    self.registerTable[realURL] = nil;
}

- (BOOL)canOpenURL:(NSString *)url {
    if ([url hasPrefix:@"http"]) {
        return YES;
    }
    NSString *realURL = [url componentsSeparatedByString:@"?"].firstObject.lowercaseString;
    return self.registerTable[realURL] != nil;
}

- (BOOL)openURL:(NSString *)url {
    return [self openURL:url params:nil];
}

- (BOOL)openURL:(NSString *)url params:(NSDictionary *)params {
    return [self openURL:url params:params completion:nil];
}

- (BOOL)openURL:(NSString *)url params:(NSDictionary *)params completion:(void (^)(NSDictionary *))completion {
    if ([url hasPrefix:@"http"]) {
        [self openWebVC:url];
        return YES;
    }
    NSString *realURL = [url componentsSeparatedByString:@"?"].firstObject.lowercaseString;
    id<NERouterHandler> target = self.registerTable[realURL];
    if (!target) {
        NSLog(@"WARNING: Not found target for URL:%@",url);
        return NO;
    }
    if ([target respondsToSelector:@selector(openFromURL:withParams:completion:)]) {
        NSMutableDictionary *urlParams = [self parametersFromURL:url] ?: @{}.mutableCopy;
        [urlParams addEntriesFromDictionary:params];
        [target openFromURL:realURL withParams:urlParams completion:completion ?:^(NSDictionary*dic){}];
    }
    return YES;
}

- (void)openWebVC:(NSString*)url {

}

- (NSMutableDictionary *)parametersFromURL:(NSString *)urlStr {
    NSRange range = [urlStr rangeOfString:@"?"];
    if (range.location == NSNotFound) {
        return nil;
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSString *parametersString = [urlStr substringFromIndex:range.location + 1];
    if ([parametersString containsString:@"&"]) {

        NSArray *urlComponents = [parametersString componentsSeparatedByString:@"&"];
        
        for (NSString *keyValuePair in urlComponents) {
            NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
            NSString *key = [pairComponents.firstObject stringByRemovingPercentEncoding];
            NSString *value = [pairComponents.lastObject stringByRemovingPercentEncoding];
            
            if (key == nil || value == nil) {
                continue;
            }
            
            id existValue = [params valueForKey:key];
            
            if (existValue != nil) {
                
                if ([existValue isKindOfClass:[NSArray class]]) {
                    NSMutableArray *items = [NSMutableArray arrayWithArray:existValue];
                    [items addObject:value];
                    
                    [params setValue:items forKey:key];
                } else {
                    [params setValue:@[existValue, value] forKey:key];
                }
                
            } else {
                [params setValue:value forKey:key];
            }
        }
    } else {
        NSArray *pairComponents = [parametersString componentsSeparatedByString:@"="];
        
        if (pairComponents.count == 1) {
            return nil;
        }
        
        NSString *key = [pairComponents.firstObject stringByRemovingPercentEncoding];
        NSString *value = [pairComponents.lastObject stringByRemovingPercentEncoding];
        
        if (key == nil || value == nil) {
            return nil;
        }
        
        [params setValue:value forKey:key];
    }
    return params;
}

@end
