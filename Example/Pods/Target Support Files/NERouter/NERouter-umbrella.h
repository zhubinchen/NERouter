#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "NERouter.h"
#import "UIViewController+TopMost.h"

FOUNDATION_EXPORT double NERouterVersionNumber;
FOUNDATION_EXPORT const unsigned char NERouterVersionString[];

