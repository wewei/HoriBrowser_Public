//
//  NSObject+Bridge.m
//  HoriBrowser
//
//  Created by Wei Wei on 1/2/13.
//  Copyright (c) 2013 HoriTech Ltd. All rights reserved.
//

#import "NSObject+Bridge.h"

@implementation NSObject (Bridge)

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
        [self performSelector:selector withObject:context];
    } else {
        context.status = [NSNumber numberWithInteger:HBInvocationStatusMethodNotFound];
        [context complete];
    }
}

@end
