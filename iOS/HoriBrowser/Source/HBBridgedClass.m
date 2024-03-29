//
//  HBBridgedClass.m
//  HoriBrowser
//
//  Created by Wei Wei on 1/3/13.
//  Copyright (c) 2013 HoriTech Ltd. All rights reserved.
//

#import "HBBridgedClass.h"
#import "HBInstantiatable.h"

@implementation HBBridgedClass

@synthesize name = _name;
@synthesize objcName = _objcName;

+ (HBBridgedClass *)classWithName:(NSString *)name objcName:(NSString *)objcName
{
    return [[[HBBridgedClass alloc] initWithName:name objcName:objcName] autorelease];
}

- (id)initWithName:(NSString *)name objcName:(NSString *)objcName
{
    self = [super init];
    if (self) {
        _name = [name retain];
        _objcName = [objcName retain];
    }
    return self;
}

- (id)instantiateWithArguments:(id)arguments inExecutionUnit:(HBExecutionUnit *)executionUnit
{
    Class objcClass = NSClassFromString(self.objcName);
    SEL initSel = @selector(initWithArguments:);
    id<HBInstantiatable> instance = nil;
    if ([objcClass instanceMethodForSelector:initSel]) {
        instance = (id<HBInstantiatable>)[objcClass alloc];
        @try {
            [instance initWithArguments:arguments inExecutionUnit:executionUnit];
        }
        @catch (NSException *exception) {
            [instance release];
            @throw;
        }
        @finally {
            ;
        }
    }
    return [instance autorelease];
}

- (void)dealloc
{
    [_name release];
    [_objcName release];
    [super dealloc];
}

@end
