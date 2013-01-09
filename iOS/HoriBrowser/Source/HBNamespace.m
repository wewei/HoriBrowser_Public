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
#import "HBInstantiatable.h"

static HBNamespace *rootNamespace = nil;
static HBNamespace *systemNamespace = nil;
static HBNamespace *classNamespace = nil;

@interface HBNamespace()

@property (readonly, nonatomic) NSMutableDictionary *objects;

@property (assign, nonatomic) id owner;
@property (retain, nonatomic) NSString *ownerName;

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
        
        [systemNamespace setObject:[HBBridgedObjectManager sharedManager] forName:@"objectManager"];
        
        UIWindow *mainWindow = ((HBAppDelegate *)[UIApplication sharedApplication].delegate).window;
        [systemNamespace setObject:mainWindow.rootViewController forName:@"rootViewController"];
    }
    return systemNamespace;
}

+ (HBNamespace *)classNamespace
{
    if (classNamespace == nil) {
        classNamespace = [[HBNamespace alloc] init];
        NSDictionary *bridgedClasses = [HBConfiguration sharedConfiguration].bridgedClasses;
        [bridgedClasses enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            Class cls = NSClassFromString(obj);
            if ([cls conformsToProtocol:@protocol(HBInstantiatable)]) {
                HBBridgedClass *bridgedClass = [HBBridgedClass classWithName:key objcName:obj];
                [classNamespace setObject:bridgedClass forName:key];
            }
        }];
    }
    return classNamespace;
}

@synthesize objects = __objects;
@synthesize owner = _owner;
@synthesize ownerName = _ownerName;

- (NSMutableDictionary *)objects
{
    if (__objects == nil) {
        __objects = [[NSMutableDictionary alloc] initWithCapacity:0];
    }
    return __objects;
}

- (void)dealloc
{
    [__objects release];
    [_ownerName release];
    [super dealloc];
}

- (id)objectForName:(NSString *)name
{
    if ([name isEqualToString:self.ownerName])
        return self.owner;
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

- (void)setOwner:(id)owner withName:(NSString *)name
{
    assert([self objectForName:name] == nil);
    self.owner = owner;
    self.ownerName = name;
}

- (NSInteger)numberOfObjects
{
    return self.objects.count + ((self.owner != nil)? 1 : 0);
}
@end
