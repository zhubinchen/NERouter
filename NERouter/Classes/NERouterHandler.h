//
//  NERouterHandler.h
//  NERouter
//
//  Created by 朱炳程 on 2019/6/13.
//

#import <Foundation/Foundation.h>

typedef void(^NEHandlerBlock)(NSString *url,NSDictionary* params,void(^completion)(id));

@protocol NERouterHandler<NSObject>
- (void)openFromURL:(NSString*)url
         withParams:(NSDictionary*)params
         completion:(void(^)(id))completion;
@end

@interface NEDefaultHandler: NSObject<NERouterHandler>

+ (instancetype)handlerForBlock:(NEHandlerBlock)block;

+ (instancetype)handlerForTarget:(id)target selector:(SEL)sel;

@end
