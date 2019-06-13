//
//  NEHandlerWrapper.m
//  NERouter
//
//  Created by 朱炳程 on 2019/6/13.
//

#import "NEHandlerWrapper.h"

@implementation NEHandlerWrapper

- (id)obj {
    return self.weakObj ?: self.strongObj;
}

@end
