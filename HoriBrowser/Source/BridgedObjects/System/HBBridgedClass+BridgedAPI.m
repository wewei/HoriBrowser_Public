//
//  HBBridgedClass+BridgedAPI.m
//  HoriBrowser
//
//  Created by Wei Wei on 1/3/13.
//  Copyright (c) 2013 HoriTech Ltd. All rights reserved.
//

#import "HBBridgedClass+BridgedAPI.h"
#import "HBBridgedObjectManager.h"

@implementation HBBridgedClass (BridgedAPI)

- (void)method_new:(HBInvocationContext *)context
{
    id arguments = [context.arguments objectForKey:@"arguments"];
    
    id object = [self instantiateWithArguments:arguments];
    if (object != nil) {
        NSString *path = [context.arguments objectForKey:@"path"];
        HBBridgedObjectManager *objectManager = [HBBridgedObjectManager sharedManager];
        [objectManager setObject:object forPath:path inExecutionUnit:context.executionUnit];
        [context succeed];
    } else {
        [context fail];
        return;
    }
}

@end
