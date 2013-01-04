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
    NSString *objectPath = [context.arguments objectForKey:@"viewController"];
    id object = [[HBBridgedObjectManager sharedManager] objectForPath:objectPath
                                                      inExecutionUnit:context.executionUnit];
    NSNumber *animatedNumber = [context.arguments objectForKey:@"animated"];
    BOOL animated = animatedNumber.boolValue;
    if ([object isKindOfClass:[UIViewController class]]) {
        [self presentViewController:object animated:animated completion:^{
            [context succeed];
        }];
    } else {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"viewController" forKey:@"argument"];
        NSException *exception = [NSException exceptionWithName:HBInvocationFailedException
                                                         reason:HBInvocationArgumentErrorReason
                                                       userInfo:userInfo];
        [context completeWithException:exception];
    }
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
