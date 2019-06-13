//
//  NEViewController.m
//  NERouter
//
//  Created by BingCheng on 02/27/2019.
//  Copyright (c) 2019 BingCheng. All rights reserved.
//

#import "NEViewController.h"
#import <NERouter/NERouter.h>

@interface NEViewController ()<NERouterHandler>

@end

@implementation NEViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [NERouter.sharedRouter registerURL:@"ne://foo" forBlock:^(NSDictionary *params, void (^completion)(id)) {
        self.title = [params[@"title"] stringByAppendingFormat:@"%@",params[@"i"]];
    }];
    
    [NERouter.sharedRouter registerURL:@"ne://bar" forTarget:self selector:@selector(bar:)];
    
    [NERouter.sharedRouter registerURL:@"ne://test" forHandler:self];
}

#pragma NERouterHandler
- (void)openFromURL:(NSString *)url withParams:(NSDictionary *)params completion:(void (^)(id))completion {
    self.view.backgroundColor = params[@"color"];
}

- (int)bar:(NSDictionary*)params {
    NSLog(@"%@",params);
    int a = [params[@"a"] intValue];
    int b = [params[@"b"] intValue];
    return a+b;
}

- (IBAction)routeToBlock:(id)sender {
    static int i = 0;
    NSString *url = [NSString stringWithFormat:@"ne://foo?title=NERouter&i=%d",i++];
    [NERouter.sharedRouter openURL:url];
//    [NERouter.sharedRouter openURL:@"ne://foo" params:@{@"title":@"NERouter",@"i":@(i++)}];
}

- (IBAction)routeToSelector:(id)sender {
    [NERouter.sharedRouter openURL:@"ne://bar?a=34&b=12" params:nil completion:^(id value) {
        NSLog(@"completion with result %@",value);
    }];
}

- (IBAction)routeToHandler:(id)sender {
    [NERouter.sharedRouter openURL:@"ne://test" params:@{@"color":UIColor.cyanColor}];
}

- (IBAction)routeToViewContoller:(id)sender {
    [NERouter.sharedRouter openURL:@"ne://next-vc?title=zzz"];
}

@end
