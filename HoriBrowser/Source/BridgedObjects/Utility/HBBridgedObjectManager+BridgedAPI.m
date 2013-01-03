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

@end
