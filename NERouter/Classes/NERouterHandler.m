//
//  NERouterHandler.m
//  NERouter
//
//  Created by 朱炳程 on 2019/6/13.
//

#import "NERouterHandler.h"
#import <objc/runtime.h>

@interface NEDefaultHandler()
@property (nonatomic,copy) NEHandlerBlock block;
@property (nonatomic,weak) id target;
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

- (void)openFromURL:(NSString *)url withParams:(NSDictionary *)params completion:(void (^)(id))completion {
    if (self.block) {
        self.block(url, params, completion);
        return;
    }
    
    NSMethodSignature *signature = [self.target methodSignatureForSelector:self.sel];
    IMP imp = [self.target methodForSelector:self.sel];
    if (imp == NULL) {
        return;
    }
    const char *returnType = signature.methodReturnType;
    id returnValue = nil;
    if (signature.numberOfArguments == 2) {
        if (!strcmp(returnType, @encode(void))) {
            void (*func)(id, SEL) = (void *)imp;
            func(self.target, self.sel);
        } else if (!strcmp(returnType, @encode(id))) {
            id (*func)(id, SEL) = (void *)imp;
            returnValue = func(self.target, self.sel);
        } else {
            int64_t (*func)(id, SEL) = (void *)imp;
            returnValue = @(func(self.target, self.sel));
        }

    } else if (signature.numberOfArguments == 3) {
        if (!strcmp(returnType, @encode(void))) {
            void (*func)(id, SEL, id) = (void *)imp;
            func(self.target, self.sel, params);
        } else if (!strcmp(returnType, @encode(id))) {
            id (*func)(id, SEL, id) = (void *)imp;
            returnValue = func(self.target, self.sel, params);
        } else {
            int64_t (*func)(id, SEL, id) = (void *)imp;
            returnValue = @(func(self.target, self.sel, params));
        }
    }
    completion(returnValue);
}

@end
