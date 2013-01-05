//
//  NSObject+BridgedAPI.m
//  HoriBrowser
//
//  Created by Wei Wei on 1/2/13.
//  Copyright (c) 2013 HoriTech Ltd. All rights reserved.
//

#import "NSObject+BridgedAPI.h"
#import "HBBridgedObjectManager.h"

NSString * const HBObjectException = @"ObjectException";

NSString * const HBObjectPropertyNotReadableReason = @"Property not readable.";
NSString * const HBObjectPropertyNotWritableReason = @"Property not writable.";

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

- (SEL)selectorForPropertyGetter:(NSString *)property
{
    NSString *getterName = [NSString stringWithFormat:@"getter_%@", property];
    SEL selector = NSSelectorFromString(getterName);
    if (![self respondsToSelector:selector]) {
        selector = nil;
    }
    return selector;
}

- (void)method_getProperty:(HBInvocationContext *)context
{
    NSDictionary *arguments = context.arguments;
    NSString *property = [arguments objectForKey:@"property"];
    SEL selector = [self selectorForPropertyGetter:property];
    if (selector != nil) {
        context.returnValue = [self performSelector:selector withObject:nil];
        [context succeed];
    } else {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:property
                                                             forKey:@"property"];
        NSException *exception = [NSException exceptionWithName:HBObjectException
                                                         reason:HBObjectPropertyNotReadableReason
                                                       userInfo:userInfo];
        [context completeWithException:exception];
    }
}

- (SEL)selectorForPropertySetter:(NSString *)property
{
    NSString *setterName = [NSString stringWithFormat:@"setter_%@:", property];
    SEL selector = NSSelectorFromString(setterName);
    if (![self respondsToSelector:selector]) {
        selector = nil;
    }
    return selector;
}

- (void)method_setProperty:(HBInvocationContext *)context
{
    NSDictionary *arguments = context.arguments;
    NSString *property = [arguments objectForKey:@"property"];
    id value = [arguments objectForKey:@"value"];
    SEL selector = [self selectorForPropertySetter:property];
    if (selector != nil) {
        context.returnValue = [self performSelector:selector withObject:value];
        [context succeed];
    } else {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:property
                                                             forKey:@"property"];
        NSException *exception = [NSException exceptionWithName:HBObjectException
                                                         reason:HBObjectPropertyNotWritableReason
                                                       userInfo:userInfo];
        [context completeWithException:exception];
    }
}

- (void)method_unlink:(HBInvocationContext *)context
{
    NSString *path = context.objectPath;
    HBBridgedObjectManager *objectManager = [HBBridgedObjectManager sharedManager];
    if ([objectManager isPathScriptEditable:path]) {
        [objectManager unlinkObjectForPath:path
                           inExecutionUnit:context.executionUnit];
    } else {
        [objectManager raisePathNotEditableException:path];
    }
    [context succeed];
}


- (void)method_moveToPath:(HBInvocationContext *)context
{
    NSString *pathFrom = context.objectPath;
    NSString *pathTo = [context.arguments objectForKey:@"path"];
    HBBridgedObjectManager *objectManager = [HBBridgedObjectManager sharedManager];
    if ([objectManager isPathScriptEditable:pathFrom]) {
        if ([objectManager isPathScriptEditable:pathTo]) {
            [objectManager setObject:self
                             forPath:pathTo
                     inExecutionUnit:context.executionUnit];
            [objectManager unlinkObjectForPath:pathFrom
                               inExecutionUnit:context.executionUnit];
            [context succeed];
        } else {
            [objectManager raisePathNotEditableException:pathTo];
        }
    } else {
        [objectManager raisePathNotEditableException:pathFrom];
    }
    
}

@end
