//
//  HBNamespace.m
//  HoriBrowser
//
//  Created by Wei Wei on 1/2/13.
//  Copyright (c) 2013 HoriTech Ltd. All rights reserved.
//

#import "HBNamespace.h"
#import "HBInvocationContext.h"

static HBNamespace *rootNamespace = nil;
static HBNamespace *utilityNamespace = nil;

@interface HBNamespace()

@property (readonly, nonatomic) NSMutableDictionary *objects;

@end

@implementation HBNamespace

+ (HBNamespace *)rootNamespace
{
    if (rootNamespace == nil) {
        rootNamespace = [[HBNamespace alloc] init];
    }
    return rootNamespace;
}

+ (HBNamespace *)utilityNamespace
{
    if (utilityNamespace == nil) {
        utilityNamespace = [[HBNamespace alloc] init];
        [[HBNamespace rootNamespace] setObject:utilityNamespace forName:@"Utility"];
    }
    return utilityNamespace;
}

@synthesize objects = __objects;

- (NSMutableDictionary *)objects
{
    if (__objects == nil) {
        __objects = [[NSMutableDictionary alloc] initWithCapacity:0];
    }
    return __objects;
}

- (id)objectForName:(NSString *)name
{
    return [self.objects objectForKey:name];
}

- (void)setObject:(id)object forName:(NSString *)name
{
    [self.objects setObject:object forKey:name];
}

@end
