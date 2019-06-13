//
//  NENextViewController.m
//  NERouter_Example
//
//  Created by 朱炳程 on 2019/6/13.
//  Copyright © 2019 BingCheng. All rights reserved.
//

#import "NENextViewController.h"
#import <NERouter/NERouter.h>

@interface NENextViewController () <NERouterHandler>

@end

@implementation NENextViewController

+ (void)load {
    [NERouter.sharedRouter registerURL:@"ne://next-vc" forViewControllerClass:self];
}

- (void)openFromURL:(NSString *)url withParams:(NSDictionary *)params completion:(void (^)(id))completion {
    self.title = params[@"title"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
}

@end
