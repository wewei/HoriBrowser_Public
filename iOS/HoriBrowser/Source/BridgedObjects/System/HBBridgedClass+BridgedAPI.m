//
//  HBBridgedClass+BridgedAPI.m
//  HoriBrowser
//
//  Created by Wei Wei on 1/3/13.
//  Copyright (c) 2013 HoriTech Ltd. All rights reserved.
//

#import "HBBridgedClass+BridgedAPI.h"
#import "HBBridgedObjectManager.h"
#import "HBExecutionUnit.h"

NSString * const HBBridgedClassException = @"BridgedClassException";

NSString * const HBBridgedClassCreationFailureReason = @"Failed to create object.";

@implementation HBBridgedClass (BridgedAPI)

- (void)method_new:(HBInvocationContext *)context
{
    id arguments = [context.arguments objectForKey:@"arguments"];
    NSString *path = [context.arguments objectForKey:@"path"];
    
    if (path == nil || [path isKindOfClass:[NSNull class]])
        path = [context.executionUnit generateTemporaryPath];
    
    HBBridgedObjectManager *objectManager = [HBBridgedObjectManager sharedManager];
    if ([objectManager isPathScriptEditable:path]) {
        if ([objectManager objectForPath:path inExecutionUnit:context.executionUnit] == nil) {
            id object = [self instantiateWithArguments:arguments inExecutionUnit:context.executionUnit];
            if (object != nil) {
                [objectManager setObject:object forPath:path inExecutionUnit:context.executionUnit];
                context.returnValue = path;
                [context succeed];
            } else {
                NSDictionary *userInfo = nil; // TODO, add some userInfo?
                NSException *exception = [NSException exceptionWithName:HBBridgedClassException
                                                                 reason:HBBridgedClassCreationFailureReason
                                                               userInfo:userInfo];
                [exception raise];
            }
        } else {
            [objectManager raiseDuplicatedCreationException:path];
        }
    } else {
        [objectManager raisePathNotEditableException:path];
    }
}

@end
