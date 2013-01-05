//
//  UINavigationController+BridgedAPI.m
//  HoriBrowser
//
//  Created by Wei Wei on 1/3/13.
//  Copyright (c) 2013 HoriTech Ltd. All rights reserved.
//

#import "UINavigationController+BridgedAPI.h"
#import "HBBridgedObjectManager.h"
#import "HBInvocationContext.h"
#import "HBExecutionUnit.h"

NSString * const HBNavControllerException = @"NavitagionControllerException";

NSString * const HBNavControllerInvalidRootControllerReason = @"The root view controller is not valid.";
NSString * const HBNavControllerInvalidURLReason = @"The URL of scene is not valid";
NSString * const HBNavControllerCannotLoadURLReason = @"Cannot connect to the URL of scene.";

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

- (void)method_pushScene:(HBInvocationContext *)context
{
    NSDictionary *arguments = context.arguments;
    NSString *URLString = [arguments objectForKey:@"url"];
    NSURL *URL = [NSURL URLWithString:URLString];
    
    BOOL waitForLoading = NO;
    NSNumber *waitForLoadingNumber = [arguments objectForKey:@"waitForLoading"];
    if (waitForLoadingNumber != nil)
        waitForLoading = waitForLoadingNumber.boolValue;
    
    BOOL stopOnFailure = NO;
    NSNumber *stopOnFailureNumber = [arguments objectForKey:@"stopOnFailure"];
    if (stopOnFailureNumber != nil)
        stopOnFailure = stopOnFailureNumber.boolValue;
    

    if (URL != nil) {
        HBExecutionUnit *newExecutionUnit = [HBExecutionUnit executionUnit];
        void (^completion)(BOOL) = ^(BOOL loaded){
            if (loaded || !stopOnFailure) {
                [self pushViewController:newExecutionUnit animated:YES];
                [context succeed];
            } else {
                NSDictionary *userInfo = [NSDictionary dictionaryWithObject:URLString forKey:@"url"];
                NSException *exception = [NSException exceptionWithName:HBNavControllerException
                                                                 reason:HBNavControllerCannotLoadURLReason
                                                               userInfo:userInfo];
                [context completeWithException:exception];
            }
        };
        if (waitForLoading) {
            [newExecutionUnit loadURL:URL withCompletion:completion];
        } else {
            [newExecutionUnit loadURL:URL];
            completion(YES);
        }
    } else {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:URLString forKey:@"url"];
        NSException *exception = [NSException exceptionWithName:HBNavControllerException
                                                         reason:HBNavControllerInvalidURLReason
                                                       userInfo:userInfo];
        [context completeWithException:exception];
    }
}

- (void)method_pushViewController:(HBInvocationContext *)context
{
    NSDictionary *arguments = context.arguments;
    
    BOOL animated = YES;
    id animatedNumber = [arguments objectForKey:@"animated"];
    if ([animatedNumber isKindOfClass:[NSNumber class]])
        animated = ((NSNumber *)animatedNumber).boolValue;
    
    NSString *path = [arguments objectForKey:@"viewController"];
    id object = [[HBBridgedObjectManager sharedManager] objectForPath:path
                                                      inExecutionUnit:context.executionUnit];
    if ([object isKindOfClass:[UIViewController class]]) {
        [self pushViewController:object animated:animated];
        [context succeed];
    } else {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"viewController" forKey:@"argument"];
        NSException *exception = [NSException exceptionWithName:HBInvocationFailedException
                                                         reason:HBInvocationArgumentErrorReason
                                                       userInfo:userInfo];
        [exception raise];
    }
}

@end
