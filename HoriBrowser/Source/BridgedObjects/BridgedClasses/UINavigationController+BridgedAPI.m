//
//  UINavigationController+BridgedAPI.m
//  HoriBrowser
//
//  Created by Wei Wei on 1/3/13.
//  Copyright (c) 2013 HoriTech Ltd. All rights reserved.
//

#import "UINavigationController+BridgedAPI.h"
#import "HBBridgedObjectManager.h"

NSString * const HBNavControllerException = @"NavitagionControllerException";

NSString * const HBNavControllerInvalidRootControllerReason = @"The root view controller is not valid.";

@implementation UINavigationController (BridgedAPI)

- (id)initWithArguments:(id)arguments inExecutionUnit:(HBExecutionUnit *)executionUnit
{
    NSDictionary *argumentDict = (NSDictionary *)arguments;
    NSString *rootViewControllerPath = [argumentDict objectForKey:@"rootViewController"];
    HBBridgedObjectManager *objectManager = [HBBridgedObjectManager sharedManager];
    UIViewController *rootViewController = [objectManager objectForPath:rootViewControllerPath
                                                        inExecutionUnit:executionUnit];
    if (rootViewController != nil) {
        self = [self initWithRootViewController:rootViewController];
    } else {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:rootViewController
                                                             forKey:@"rootViewController"];
        NSException *exception = [NSException exceptionWithName:HBNavControllerException
                                                         reason:HBNavControllerInvalidRootControllerReason
                                                       userInfo:userInfo];
        [exception raise];
    }
    return self;
}

@end
