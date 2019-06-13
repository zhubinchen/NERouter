//
//  NEHandlerWrapper.h
//  NERouter
//
//  Created by 朱炳程 on 2019/6/13.
//

#import <Foundation/Foundation.h>

@protocol NERouterHandler;

@interface NEHandlerWrapper : NSObject

@property (nonatomic,weak) id weakObj;
@property (nonatomic,strong) id strongObj;
@property (nonatomic,readonly) id obj;

@end

static inline id weakHandler(id obj) {
    if ([obj isKindOfClass:NEHandlerWrapper.class]) {
        return obj;
    }
    NEHandlerWrapper *wrapper = [[NEHandlerWrapper alloc] init];
    wrapper.weakObj = obj;
    return wrapper;
}

static inline id strongHandler(id obj) {
    if ([obj isKindOfClass:NEHandlerWrapper.class]) {
        return obj;
    }
    NEHandlerWrapper *wrapper = [[NEHandlerWrapper alloc] init];
    wrapper.strongObj = obj;
    return wrapper;
}
