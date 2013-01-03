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

@end
