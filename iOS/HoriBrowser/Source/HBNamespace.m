//
//  HBNamespace.m
//  HoriBrowser
//
//  Created by Wei Wei on 1/2/13.
//  Copyright (c) 2013 HoriTech Ltd. All rights reserved.
//

#import "HBNamespace.h"
#import "HBInvocationContext.h"
#import "HBBridgedObjectManager.h"
#import "HBAppDelegate.h"
#import "HBBridgedClass.h"
#import "HBConfiguration.h"

static HBNamespace *rootNamespace = nil;
static HBNamespace *systemNamespace = nil;
static HBNamespace *classNamespace = nil;

@interface HBNamespace()

@property (readonly, nonatomic) NSMutableDictionary *objects;

@end

@implementation HBNamespace

+ (HBNamespace *)rootNamespace
{
    if (rootNamespace == nil) {
        rootNamespace = [[HBNamespace alloc] init];
        [rootNamespace setObject:[HBNamespace systemNamespace] forName:@"System"];
        [rootNamespace setObject:[HBNamespace classNamespace] forName:@"Class"];
    }
    return rootNamespace;
}

+ (HBNamespace *)systemNamespace
{
    if (systemNamespace == nil) {
        systemNamespace = [[HBNamespace alloc] init];
        
        [systemNamespace setObject:[HBBridgedObjectManager sharedManager] forName:@"ObjectManager"];
        
        UIWindow *mainWindow = ((HBAppDelegate *)[UIApplication sharedApplication].delegate).window;
        [systemNamespace setObject:mainWindow forName:@"MainWindow"];
        
        [systemNamespace setObject:mainWindow.rootViewController forName:@"RootViewController"];
    }
    return systemNamespace;
}

+ (HBNamespace *)classNamespace
{
    if (classNamespace == nil) {
        classNamespace = [[HBNamespace alloc] init];
        NSDictionary *bridgedClasses = [HBConfiguration sharedConfiguration].bridgedClasses;
        [bridgedClasses enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            HBBridgedClass *bridgedClass = [HBBridgedClass classWithName:key objcName:obj];
            [classNamespace setObject:bridgedClass forName:key];
        }];
    }
    return classNamespace;
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
    if (object == nil) {
        [self.objects removeObjectForKey:name];
    } else {
        [self.objects setObject:object forKey:name];
    }
}

@end
