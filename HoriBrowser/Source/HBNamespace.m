//
//  HBNamespace.m
//  HoriBrowser
//
//  Created by Wei Wei on 1/2/13.
//  Copyright (c) 2013 HoriTech Ltd. All rights reserved.
//

#import "HBNamespace.h"
#import "HBInvocationContext.h"

static HBNamespace *globalNamespace = nil;

@implementation HBNamespace

+ (HBNamespace *)globalNamespace
{
    if (globalNamespace == nil) {
        globalNamespace = [[HBNamespace alloc] init];
    }
    return globalNamespace;
}

- (id)objectForName:(NSString *)name
{
    if (name.length == 0)
        return self;
    return nil; // TODO
}

- (void)method_createObject:(HBInvocationContext *)context
{
    NSLog(@"hello");
    [context complete];
}

@end
