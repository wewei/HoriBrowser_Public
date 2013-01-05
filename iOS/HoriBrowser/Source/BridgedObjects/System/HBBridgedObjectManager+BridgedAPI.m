//
//  HBBridgedObjectManager+BridgedAPI.m
//  HoriBrowser
//
//  Created by Wei Wei on 1/3/13.
//  Copyright (c) 2013 HoriTech Ltd. All rights reserved.
//

#import "HBBridgedObjectManager+BridgedAPI.h"
#import "HBInvocationContext.h"

@implementation HBBridgedObjectManager (BridgedAPI)

- (void)method_hello_world:(HBInvocationContext *)context
{
    NSLog(@"hello world");
    [context succeed];
}

- (void)method_readObject:(HBInvocationContext *)context
{
    id path = nil;
    
    if ([context.arguments isKindOfClass:[NSDictionary class]]) {
        path = [(NSDictionary *)context.arguments objectForKey:@"path"];
    }
    
    if ([path isKindOfClass:[NSString class]]) {
        context.returnValue = [self objectForPath:path
                                  inExecutionUnit:context.executionUnit];
        [context succeed];
    } else {
        [context raiseArgumentError:@"path"];
    }
}

- (void)method_writeObject:(HBInvocationContext *)context
{
    id path = nil;
    id value = nil;
    
    if ([context.arguments isKindOfClass:[NSDictionary class]]) {
        NSDictionary *arguments = context.arguments;
        path = [arguments objectForKey:@"path"];
        value = [arguments objectForKey:@"value"];
    }
    
    if ([path isKindOfClass:[NSString class]]) {
        if (value != nil) {
            if ([self isPathScriptEditable:path]) {
                [self setObject:value forPath:path inExecutionUnit:context.executionUnit override:YES];
                [context succeed];
            } else {
                [self raisePathNotEditableException:path];
            }
        } else {
            [context raiseArgumentError:@"value"];
        }
    } else {
        [context raiseArgumentError:@"path"];
    }
}

@end
