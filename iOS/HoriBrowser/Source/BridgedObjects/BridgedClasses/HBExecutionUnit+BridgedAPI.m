//
//  HBExecutionUnit+BridgedAPI.m
//  HoriBrowser
//
//  Created by Wei Wei on 1/5/13.
//  Copyright (c) 2013 HoriTech Ltd. All rights reserved.
//

#import "HBExecutionUnit+BridgedAPI.h"
#import "HBInvocationContext.h"

NSString * const HBExeUnitException = @"ExecutionUnitException";

NSString * const HBExeUnitInvalidURLReason = @"The URL of scene is not valid";
NSString * const HBExeUnitCannotLoadURLReason = @"Cannot connect to the URL.";

@implementation HBExecutionUnit (BridgedAPI)

- (id)initWithArguments:(id)arguments inExecutionUnit:(HBExecutionUnit *)executionUnit
{
    return [self init];
}

- (void)method_loadURL:(HBInvocationContext *)context
{
    NSDictionary *arguments = context.arguments;
    NSString *URLString = [arguments objectForKey:@"url"];
    NSURL *URL = [NSURL URLWithString:URLString];
    
    NSUInteger onStartLoading = 0;
    id onStartLoadingArg = [arguments objectForKey:@"onStartLoading"];
    if ([onStartLoadingArg isKindOfClass:[NSNumber class]])
        onStartLoading = [(NSNumber *)onStartLoadingArg unsignedIntegerValue];
    
    if (URL != nil) {
        if (onStartLoading > 0)
            [context triggerCallbackWithIndex:onStartLoading andArguments:nil];
        
        [self loadURL:URL withCompletion:^(BOOL loaded) {
            if (loaded) {
                [context succeed];
            } else {
                NSDictionary *userInfo = [NSDictionary dictionaryWithObject:URLString forKey:@"url"];
                NSException *exception = [NSException exceptionWithName:HBExeUnitException
                                                                 reason:HBExeUnitCannotLoadURLReason
                                                               userInfo:userInfo];
                [exception raise];
            }
        }];
    } else {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:URLString forKey:@"url"];
        NSException *exception = [NSException exceptionWithName:HBExeUnitException
                                                         reason:HBExeUnitInvalidURLReason
                                                       userInfo:userInfo];
        [exception raise];
    }
}

@end
