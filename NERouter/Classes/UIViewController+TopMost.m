//
//  UIViewController+TopMost.m
//  NewsEarn
//
//  Created by zhubch on 2018/7/11.
//  Copyright © 2018年 CooHua. All rights reserved.
//

#import "UIViewController+TopMost.h"

@implementation UIViewController(TopMost)

+ (UIViewController *)topMost {
    UIViewController *resultVC;
    resultVC = [self _topViewController:[[UIApplication sharedApplication].keyWindow rootViewController]];
    while (resultVC.presentedViewController) {
        resultVC = [self _topViewController:resultVC.presentedViewController];
    }
    return resultVC;
}

+ (UIViewController *)_topViewController:(UIViewController *)vc {
    if ([vc isKindOfClass:[UINavigationController class]]) {
        return [self _topViewController:[(UINavigationController *)vc topViewController]];
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        return [self _topViewController:[(UITabBarController *)vc selectedViewController]];
    } else {
        return vc;
    }
    return nil;
}

@end
