//
//  UIViewController+BridgedAPI.m
//  HoriBrowser
//
//  Created by Wei Wei on 1/3/13.
//  Copyright (c) 2013 HoriTech Ltd. All rights reserved.
//

#import "UIViewController+BridgedAPI.h"
#import "HBInvocationContext.h"
#import "HBBridgedObjectManager.h"

@implementation UIViewController (BridgedAPI)

- (void)method_presentViewController:(HBInvocationContext *)context
{
    id viewControllerObj = [context.arguments objectForKey:@"viewController"];
    
    if ([viewControllerObj isKindOfClass:[UIViewController class]]) {
        BOOL animated = YES;
        id animatedObj = [context.arguments objectForKey:@"animated"];
        if ([animatedObj isKindOfClass:[NSNumber class]])
            animated = [(NSNumber *)animatedObj boolValue];
        
        [self presentViewController:(UIViewController *)viewControllerObj animated:animated completion:^{
            [context succeed];
        }];
    } else {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"viewController" forKey:@"argument"];
        NSException *exception = [NSException exceptionWithName:HBInvocationFailedException
                                                         reason:HBInvocationArgumentErrorReason
                                                       userInfo:userInfo];
        [exception raise];
    }
}

- (void)method_dismissViewController:(HBInvocationContext *)context
{
    BOOL animated = YES;
    id animatedObj = [context.arguments objectForKey:@"animated"];
    if ([animatedObj isKindOfClass:[NSNumber class]])
        animated = [(NSNumber *)animatedObj boolValue];
    
    [self dismissViewControllerAnimated:animated completion:^{
        [context succeed];
    }];
}

- (NSString *)getter_navigationItemTitle
{
    return self.navigationItem.title;
}

- (void)setter_navigationItemTitle:(NSString *)title
{
    self.navigationItem.title = title;
}

@end
