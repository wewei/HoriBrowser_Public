//
//  NSObject+BridgedAPI.m
//  HoriBrowser
//
//  Created by Wei Wei on 1/2/13.
//  Copyright (c) 2013 HoriTech Ltd. All rights reserved.
//

#import "NSObject+BridgedAPI.h"

@implementation NSObject (BridgedAPI)

- (SEL)selectorForMethod:(NSString *)method
{
    NSString *methodName = [NSString stringWithFormat:@"method_%@:", method];
    SEL selector = NSSelectorFromString(methodName);
    if (![self respondsToSelector:selector]) {
        selector = nil;
    }
    return selector;
}

- (void)triggerInvocationWithContext:(HBInvocationContext *)context
{
    SEL selector = [self selectorForMethod:context.method];
    if (selector != nil) {
        @try {
            [self performSelector:selector withObject:context];
        }
        @catch (NSException *exception) {
            [context completeWithException:exception];
        }
        @finally {
            ;
        }
    } else {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:context.method
                                                             forKey:@"method"];
        NSException *exception = [NSException exceptionWithName:HBInvocationFailedException
                                                         reason:HBInvocationMethodNotFoundReason
                                                       userInfo:userInfo];
        [context completeWithException:exception];
    }
}

@end
