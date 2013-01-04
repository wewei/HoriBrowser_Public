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
    NSString *path = [context.arguments objectForKey:@"path"];
    id arguments = [context.arguments objectForKey:@"arguments"];
    
    HBBridgedObjectManager *objectManager = [HBBridgedObjectManager sharedManager];
    if (![objectManager isPathScriptWritable:path]) {
        [context fail];
        return;
    }
    
    if ([objectManager objectForPath:path inExecutionUnit:context.executionUnit] != nil) {
        [context fail];
        return;
    }
    
    id object = [self instantiateWithArguments:arguments];
    if (object == nil) {
        [context fail];
        return;
    }
    
    
    context.returnValue = path;
    
    // TODO, put the object to the object tree
    [context succeed];
}

@end
