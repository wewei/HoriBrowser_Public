//
//  HBExecutionUnit+BridgedAPI.m
//  HoriBrowser
//
//  Created by Wei Wei on 1/5/13.
//  Copyright (c) 2013 HoriTech Ltd. All rights reserved.
//

#import "HBExecutionUnit+BridgedAPI.h"
#import "HBInvocationContext.h"
#import "HBCallback.h"

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
    
    HBCallback *onStartLoading = nil;
    id onStartLoadingObj = [arguments objectForKey:@"onStartLoading"];
    if ([onStartLoadingObj isKindOfClass:[HBCallback class]])
        onStartLoading = onStartLoadingObj;
    
    
    if (URL != nil) {
        if (onStartLoading)
            [onStartLoading asyncCallWithArguments:nil];
        
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
