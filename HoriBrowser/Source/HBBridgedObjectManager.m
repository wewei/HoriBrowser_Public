//
//  HBBridgedObjectManager.m
//  HoriBrowser
//
//  Created by Wei Wei on 1/3/13.
//  Copyright (c) 2013 HoriTech Ltd. All rights reserved.
//

#import "HBBridgedObjectManager.h"
#import "HBNamespace.h"

static HBBridgedObjectManager *sharedManager = nil;

@implementation HBBridgedObjectManager

+ (HBBridgedObjectManager *)sharedManager
{
    if (sharedManager == nil) {
        sharedManager = [[HBBridgedObjectManager alloc] init];
        [[HBNamespace utilityNamespace] setObject:sharedManager forName:@"ObjectManager"];
    }
    return sharedManager;
}

- (id)objectForPath:(NSString *)path
{
    NSArray *components = [path componentsSeparatedByString:@"/"];
    id object = nil;
    for (NSString *component in components) {
        if (component.length == 0)
            object = [HBNamespace rootNamespace];
        else if ([object isKindOfClass:[HBNamespace class]])
            object = [(HBNamespace *)object objectForName:component];
        else
            break;
    }
    return object;
}

@end
