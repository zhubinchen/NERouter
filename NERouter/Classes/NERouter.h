//
//  NERouter.h
//  NewsEarn
//
//  Created by zhubch on 2018/8/1.
//  Copyright © 2018年 CooHua. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NERouterHandler.h"
#import "NEHandlerWrapper.h"

@protocol NERouterDelegate <NSObject>

@end

@interface NERouter : NSObject

@property (nonatomic,readonly) NSArray *allRegisteredURLs;

@property (nonatomic,weak) id<NERouterDelegate> delegate;

+ (instancetype)sharedRouter;

- (void)registerURL:(NSString*)url
          forHandler:(id<NERouterHandler>)handler;

- (void)registerURL:(NSString*)url
          forTarget:(id)target
           selector:(SEL)sel;

- (void)registerURL:(NSString*)url
           forBlock:(void(^)(NSDictionary* params,void(^completion)(id)))block;

- (void)registerURL:(NSString*)url
     forViewControllerClass:(Class<NERouterHandler>)clazz;

- (void)unregisterURL:(NSString*)url;

- (BOOL)canOpenURL:(NSString*)url;

- (BOOL)openURL:(NSString*)url;

- (BOOL)openURL:(NSString*)url
         params:(NSDictionary*)params;

- (BOOL)openURL:(NSString*)url
         params:(NSDictionary*)params
     completion:(void(^)(id value))completion;

@end

