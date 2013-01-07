//
//  HBObjectNormalizer.m
//  HoriBrowser
//
//  Created by Wei Wei on 1/7/13.
//  Copyright (c) 2013 HoriTech Ltd. All rights reserved.
//

#import "HBObjectNormalizer.h"
#import "HBInvocationContext.h"
#import "HBBridgedObjectManager.h"
#import "HBExecutionUnit.h"
#import "HBCallback.h"

@interface HBObjectNormalizer()

@property (assign, nonatomic) HBExecutionUnit *executionUnit;
@property (assign, nonatomic) HBInvocationContext *invocationContext;

@property (readonly, nonatomic) NSMutableArray *callbacks;

@end


@implementation HBObjectNormalizer

+ (HBObjectNormalizer *)normalizerWithInvocationContext:(HBInvocationContext *)context
{
    return [[[HBObjectNormalizer alloc] initWithInvocationContext:context] autorelease];
}

+ (HBObjectNormalizer *)normalizerWithExecutionUnit:(HBExecutionUnit *)executionUnit
{
    return [[[HBObjectNormalizer alloc] initWithExecutionUnit:executionUnit] autorelease];
}

- (NSMutableArray *)callbacks
{
    if (self.invocationContext) {
        return self.invocationContext.callbacks;
    }
    // TODO support persisted callback return functions;
    return nil;
}

- (id)initWithInvocationContext:(HBInvocationContext *)context
{
    self = [super init];
    if (self) {
        self.executionUnit = context.executionUnit;
        self.invocationContext = context;
    }
    return self;
}

- (id)initWithExecutionUnit:(HBExecutionUnit *)executionUnit
{
    self = [super init];
    if (self) {
        self.executionUnit = executionUnit;
        self.invocationContext = nil;
    }
    return self;
}

- (void)raiseInvocationInternalError
{
    NSException *exception = [NSException exceptionWithName:HBInvocationFailedException
                                                     reason:HBInvocationInternalReason
                                                   userInfo:nil];
    [exception raise];
}

- (id)normalizeBridgedObject:(NSString *)path
{
    HBBridgedObjectManager *objectManager = [HBBridgedObjectManager sharedManager];
    return [objectManager objectForPath:path inExecutionUnit:self.executionUnit];
}

- (id)normalizeDictionary:(NSDictionary *)dictionary
{
    NSMutableDictionary *newDirectory = [NSMutableDictionary dictionary];
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [newDirectory setObject:[self normalizeObject:obj] forKey:key];
    }];
    return newDirectory;
}

- (id)normalizeCallback:(NSNumber *)indexNumber
{
    HBCallback *callback = nil;
    if (self.invocationContext) {
        callback = [HBCallback callbackWithIndex:indexNumber.unsignedIntegerValue
                                       inContext:self.invocationContext];
    } else if (self.executionUnit) {
        callback = [HBCallback callbackWithIndex:indexNumber.unsignedIntegerValue
                                 inExecutionUnit:self.executionUnit];
    }
    
    if (callback) {
        [self.callbacks addObject:callback];
    }
    return callback;
}

- (id)normalizeComplexObject:(NSDictionary *)dictionary
{
    id typeObj = [dictionary objectForKey:@"type"];
    if ([typeObj isKindOfClass:[NSString class]]) {
        NSString *type = typeObj;
        id dataObj = [dictionary objectForKey:@"data"];
        if (dataObj != nil) {
            if ([type isEqualToString:@"object"]) {
                if ([dataObj isKindOfClass:[NSDictionary class]]) {
                    return [self normalizeDictionary:(NSDictionary *)dataObj];
                }
            } else if ([type isEqualToString:@"bridged"]) {
                if ([dataObj isKindOfClass:[NSString class]]) {
                    return [self normalizeBridgedObject:(NSString *)dataObj];
                }
            } else if ([type isEqualToString:@"function"]) {
                if ([dataObj isKindOfClass:[NSNumber class]])
                    return [self normalizeCallback:(NSNumber *)dataObj];
            }
        }
    }
    [self raiseInvocationInternalError];
    
    // Unreachable.
    return [NSNull null];
}

- (id)normalizeObject:(id)arguments
{
    if ([arguments isKindOfClass:[NSNull class]] || arguments == nil)
        return [NSNull null];
    else if ([arguments isKindOfClass:[NSDictionary class]]) {
        return [self normalizeComplexObject:(NSDictionary *)arguments];
    } else {
        return arguments;
    }
}

@end
