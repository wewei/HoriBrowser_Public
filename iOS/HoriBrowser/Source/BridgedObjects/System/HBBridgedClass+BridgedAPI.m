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

@implementation HBBridgedClass (BridgedAPI)

- (void)method_new:(HBInvocationContext *)context
{
    id arguments = [context.arguments objectForKey:@"arguments"];
    
    id object = [self instantiateWithArguments:arguments inExecutionUnit:context.executionUnit];
    if (object != nil) {
        NSString *path = [context.arguments objectForKey:@"path"];
        if (path == nil)
            path = [context.executionUnit generateTemporaryPath];
        HBBridgedObjectManager *objectManager = [HBBridgedObjectManager sharedManager];
        if ([objectManager isPathScriptEditable:path]) {
            [objectManager setObject:object forPath:path inExecutionUnit:context.executionUnit];
            context.returnValue = path;
            [context succeed];
        } else {
            [objectManager raisePathNotEditableException:path];
        }
    } else {
        [context fail];
        return;
    }
}

@end
