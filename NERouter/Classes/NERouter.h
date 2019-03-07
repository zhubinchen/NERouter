//
//  NERouter.h
//  NewsEarn
//
//  Created by zhubch on 2018/8/1.
//  Copyright © 2018年 CooHua. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^NEHandlerBlock)(NSString *url,NSDictionary* params,void(^completion)(NSDictionary*));

@protocol NERouterHandler<NSObject>
- (void)openFromURL:(NSString*)url
         withParams:(NSDictionary*)params
         completion:(void(^)(NSDictionary*))completion;
@end

@interface NEDefaultHandler: NSObject<NERouterHandler>

+ (instancetype)handlerForBlock:(NEHandlerBlock)block;

+ (instancetype)handlerForTarget:(id)target selector:(SEL)sel;

@end

@interface NERouter : NSObject

@property (nonatomic,readonly) NSArray *allRegisteredURLs;

+ (instancetype)sharedRouter;

- (void)registerURL:(NSString*)url
          forHandler:(id<NERouterHandler>)handler;

- (void)registerURL:(NSString*)url
          forTarget:(id)target
           selector:(SEL)sel;

- (void)registerURL:(NSString*)url
           forBlock:(void(^)(NSDictionary* params,void(^completion)(NSDictionary*)))block;

- (void)registerURL:(NSString*)url
     forViewControllerClass:(Class<NERouterHandler>)clazz;

- (void)unregisterURL:(NSString*)url;

- (BOOL)canOpenURL:(NSString*)url;

- (BOOL)openURL:(NSString*)url;

- (BOOL)openURL:(NSString*)url
         params:(NSDictionary*)params;

- (BOOL)openURL:(NSString*)url
         params:(NSDictionary*)params
     completion:(void(^)(NSDictionary*))completion;

@end
