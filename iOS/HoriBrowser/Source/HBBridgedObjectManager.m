//
//  HBBridgedObjectManager.m
//  HoriBrowser
//
//  Created by Wei Wei on 1/3/13.
//  Copyright (c) 2013 HoriTech Ltd. All rights reserved.
//

#import "HBBridgedObjectManager.h"
#import "HBNamespace.h"
#import "HBExecutionUnit.h"

NSString * const HBObjectManagerException = @"ObjectManagerException";

NSString * const HBObjectManagerUnknownReason = @"Unknown reason";
NSString * const HBObjectManagerInvalidPathReason = @"The object path is not valid.";
NSString * const HBObjectManagerDuplicatedCreationReason = @"The object at certain path already exists.";
NSString * const HBObjectManagerRequireNamespaceReason = @"Require namespace at a certain path.";
NSString * const HBObjectManagerPathNotEditableReason = @"The path is not editable.";

static BOOL HBSplitPath(NSString *path, NSString **namespacePath, NSString **objectName)
{
    const char *buffer = path.UTF8String;
    int index = path.length - 1;
    while (index >= 0) {
        if (buffer[index] == '/') {
            break;
        }
        index --;
    }
    if (index >= 0) {
        if (namespacePath != nil)
            *namespacePath = [path substringToIndex:index];
        if (objectName != nil)
            *objectName = [path substringFromIndex:index + 1];
        return YES;
    }
    return NO;
}

static HBBridgedObjectManager *sharedManager = nil;

@implementation HBBridgedObjectManager

+ (HBBridgedObjectManager *)sharedManager
{
    if (sharedManager == nil) {
        sharedManager = [[HBBridgedObjectManager alloc] init];
    }
    return sharedManager;
}

- (id)objectForPath:(NSString *)path inExecutionUnit:(HBExecutionUnit *)executionUnit
{
    if ([path hasSuffix:@"/"])
        path = [path substringToIndex:path.length - 1];
    
    NSArray *components = [path componentsSeparatedByString:@"/"];
    id object = nil;
    for (NSString *component in components) {
        if (component.length == 0) {
            object = [HBNamespace rootNamespace];
        } else if ([object isKindOfClass:[HBNamespace class]]) {
            if (object == [HBNamespace rootNamespace] &&
                [component isEqualToString:@"Current"]) {
                object = executionUnit.currentNamespace;
            } else
                object = [(HBNamespace *)object objectForName:component];
        } else {
            object = nil;
            break;
        }
    }
    return object;
}


- (HBNamespace *)ensureNamespaceForPath:(NSString *)path
                        inExecutionUnit:(HBExecutionUnit *)executionUnit
{
    if ([path hasSuffix:@"/"])
        path = [path substringToIndex:path.length - 1];
    
    NSArray *components = [path componentsSeparatedByString:@"/"];
    HBNamespace *namespace = nil;
    NSInteger index = components.count - 1;
    while (index >= 0) {
        NSString *component = [components objectAtIndex:index];
        if (component.length == 0)
            break;
        index --;
    }
    if (index < 0)
        [self raiseInvalidPathException:path];
        
    for (;index < components.count; index ++) {
        NSString *component = [components objectAtIndex:index];
        if (component.length == 0) {
            namespace = [HBNamespace rootNamespace];
        } else if (namespace == [HBNamespace rootNamespace] &&
                   [component isEqualToString:@"Current"]) {
            namespace = executionUnit.currentNamespace;
        } else if (namespace != nil) {
            id subNamespace = [namespace objectForName:component];
            if (subNamespace == nil) {
                subNamespace = [[[HBNamespace alloc] init] autorelease];
                [namespace setObject:subNamespace forName:component];
            }
            namespace = (HBNamespace *)subNamespace;
        } else {
            [self raiseInvalidPathException:path];
        }
    }
    
    return namespace;
}

- (void)setObject:(id)object forPath:(NSString *)path inExecutionUnit:(HBExecutionUnit *)executionUnit
{
    [self setObject:object forPath:path inExecutionUnit:executionUnit override:NO];
}

- (void)setObject:(id)object
          forPath:(NSString *)path
  inExecutionUnit:(HBExecutionUnit *)executionUnit
         override:(BOOL)override
{
    NSString *namespacePath = nil;
    NSString *objectName = nil;
    if (HBSplitPath(path, &namespacePath, &objectName)) {
        HBNamespace *namespace = [self ensureNamespaceForPath:namespacePath
                                              inExecutionUnit:executionUnit];
        if (namespace != nil) {
            if ([namespace objectForName:objectName] == nil || override)
                [namespace setObject:object forName:objectName];
            else {
                NSDictionary *userInfo = [NSDictionary dictionaryWithObject:path forKey:@"path"];
                NSException *exception = [NSException exceptionWithName:HBObjectManagerException
                                                                 reason:HBObjectManagerDuplicatedCreationReason
                                                               userInfo:userInfo];
                [exception raise];
            }
        } else
            [NSException raise:HBObjectManagerException format:HBObjectManagerUnknownReason];
    } else {
        [self raiseInvalidPathException:path];
    }
}

- (BOOL)isPathScriptEditable:(NSString *)path
{
    return ([path hasPrefix:@"/User/"] ||
            [path hasPrefix:@"/Current/User/"] ||
            [path hasPrefix:@"/Current/Temp/"]);
}

- (void)unlinkObjectForPath:(NSString *)path inExecutionUnit:(HBExecutionUnit *)executionUnit
{
    NSString *namespacePath = nil;
    NSString *objectName = nil;
    if (HBSplitPath(path, &namespacePath, &objectName)) {
        id namespaceObj = [self objectForPath:namespacePath inExecutionUnit:executionUnit];
        if ([namespaceObj isKindOfClass:[HBNamespace class]]) {
            HBNamespace *namespace = (HBNamespace *)namespaceObj;
            [namespace setObject:nil forName:objectName];
        } else {
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:namespacePath forKey:@"path"];
            NSException *exception = [NSException exceptionWithName:HBObjectManagerException
                                                             reason:HBObjectManagerRequireNamespaceReason
                                                           userInfo:userInfo];
            [exception raise];
        }
    } else {
        [self raiseInvalidPathException:path];
    }
}

- (void)raiseInvalidPathException:(NSString *)path
{
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:path forKey:@"path"];
    NSException *exception = [NSException exceptionWithName:HBObjectManagerException
                                                     reason:HBObjectManagerInvalidPathReason
                                                   userInfo:userInfo];
    [exception raise];
}

- (void)raisePathNotEditableException:(NSString *)path
{
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:path forKey:@"path"];
    NSException *exception = [NSException exceptionWithName:HBObjectManagerException
                                                     reason:HBObjectManagerPathNotEditableReason
                                                   userInfo:userInfo];
    [exception raise];
}


@end
