//
//  NERouter.m
//  NewsEarn
//
//  Created by zhubch on 2018/8/1.
//  Copyright © 2018年 CooHua. All rights reserved.
//

#import "NERouter.h"
#import "UIViewController+TopMost.h"

@interface NERouter()
@property (nonatomic,strong) NSMutableDictionary<NSString*,NEHandlerWrapper*> *registerTable;
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
    self.registerTable[realURL] = weakHandler(handler);
}

- (void)registerURL:(NSString *)url forTarget:(id)target selector:(SEL)sel {
    id<NERouterHandler> handler = [NEDefaultHandler handlerForTarget:target selector:sel];
    [self registerURL:url forHandler:strongHandler(handler)];
}

- (void)registerURL:(NSString *)url forBlock:(void (^)(NSDictionary *, void (^)(id)))block {
    id<NERouterHandler> handler = [NEDefaultHandler handlerForBlock:^(NSString *url, NSDictionary *params, void (^completion)(id)) {
        block(params,completion);
    }];
    [self registerURL:url forHandler:strongHandler(handler)];
}

- (void)registerURL:(NSString *)url forViewControllerClass:(Class)clazz {
    if (![clazz isSubclassOfClass:UIViewController.class]) {
        NSLog(@"WARNING: %@ is NOT subclass of UIViewController",NSStringFromClass(clazz));
    }
    NEDefaultHandler *handler = [NEDefaultHandler handlerForBlock:^(NSString *url, NSDictionary *params, void (^completion)(id)) {
        NSObject<NERouterHandler> *obj = [[clazz alloc] init];
        if ([obj respondsToSelector:@selector(openFromURL:withParams:completion:)]) {
            [obj openFromURL:url withParams:params completion:completion];
        }
        if ([obj isKindOfClass:UIViewController.class]) {
            [UIViewController.ne_topMost.navigationController pushViewController:(UIViewController*)obj animated:YES];
        }
    }];
    [self registerURL:url forHandler:strongHandler(handler)];
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
    if (self.registerTable[realURL].obj == nil) {
        self.registerTable[realURL] = nil;
        return NO;
    }
    return YES;
}

- (BOOL)openURL:(NSString *)url {
    return [self openURL:url params:nil];
}

- (BOOL)openURL:(NSString *)url params:(NSDictionary *)params {
    return [self openURL:url params:params completion:nil];
}

- (BOOL)openURL:(NSString *)url params:(NSDictionary *)params completion:(void (^)(id))completion {
    if ([url hasPrefix:@"http"]) {
        [self openWebVC:url];
        return YES;
    }
    NSString *realURL = [url componentsSeparatedByString:@"?"].firstObject.lowercaseString;
    id<NERouterHandler> target = self.registerTable[realURL].obj;
    if (!target) {
        self.registerTable[realURL] = nil;
        NSLog(@"WARNING: Not found target for URL:%@",url);
        return NO;
    }
    if ([target respondsToSelector:@selector(openFromURL:withParams:completion:)]) {
        NSMutableDictionary *urlParams = [self parametersFromURL:url] ?: @{}.mutableCopy;
        [urlParams addEntriesFromDictionary:params];
        [target openFromURL:realURL withParams:urlParams completion:completion ?:^(id value){}];
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
