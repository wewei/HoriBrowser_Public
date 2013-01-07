//
//  HBCallback.m
//  HoriBrowser
//
//  Created by Wei Wei on 1/7/13.
//  Copyright (c) 2013 HoriTech Ltd. All rights reserved.
//

#import "HBCallback.h"
#import "HBInvocationContext.h"
#import "HBExecutionUnit.h"
#import "HBJSONSerialization.h"
#import "HBObjectNormalizer.h"

@implementation HBCallback

@synthesize invocationContext = _invocationContext;
@synthesize executionUnit = _executionUnit;
@synthesize index = _index;

+ (HBCallback *)callbackWithIndex:(NSUInteger)index
                        inContext:(HBInvocationContext *)context
{
    return [[[HBCallback alloc] initWithIndex:index inContext:context] autorelease];
}

+ (HBCallback *)callbackWithIndex:(NSUInteger)index inExecutionUnit:(HBExecutionUnit *)executionUnit
{
    return [[[HBCallback alloc] initWithIndex:index inExecutionUnit:executionUnit] autorelease];
}

- (id)initWithIndex:(NSUInteger)index inContext:(HBInvocationContext *)context
{
    self = [super init];
    if (self) {
        self.index = index;
        self.invocationContext = context;
        self.executionUnit = context.executionUnit;
    }
    return self;
}

- (id)initWithIndex:(NSUInteger)index inExecutionUnit:(HBExecutionUnit *)executionUnit
{
    self = [super init];
    if (self) {
        self.index = index;
        self.invocationContext = nil;
        self.executionUnit = executionUnit;
    }
    return self;
}

- (id)callWithArguments:(id)arguments
{
    if (self.invocationContext) {
        NSError *error = nil;
        NSString *argsJSON = [HBJSONSerialization stringWithJSONObject:arguments error:&error];
        assert(error == nil);
        NSString *callbackScript = [NSString stringWithFormat:@"$H.__bridge.__triggerCallback(%u, %u, %@)",
                                    self.invocationContext.index.unsignedIntegerValue,
                                    self.index,
                                    argsJSON];
        NSString *resultString = [self.executionUnit.webView stringByEvaluatingJavaScriptFromString:callbackScript];
        id result = [HBJSONSerialization JSONObjectWithString:resultString error:&error];
        HBObjectNormalizer *normalizer = [HBObjectNormalizer normalizerWithInvocationContext:self.invocationContext];
        return [normalizer normalizeObject:result];
    } else {
        // TODO support persisted callbacks
        return nil;
    }
}

- (void)asyncCallWithArguments:(id)arguments
{
    if (self.invocationContext) {
        NSError *error = nil;
        NSString *argsJSON = [HBJSONSerialization stringWithJSONObject:arguments error:&error];
        assert(error == nil);
        NSString *callbackScript = [NSString stringWithFormat:@"$H.__bridge.__triggerCallbackAsync(%u, %u, %@)",
                                    self.invocationContext.index.unsignedIntegerValue,
                                    self.index,
                                    argsJSON];
        (void)[self.executionUnit.webView stringByEvaluatingJavaScriptFromString:callbackScript];
    } else {
        // TODO support persisted callbacks
    }
}

- (id)persist
{
    self.invocationContext = nil;
    self.index = [self.executionUnit persistCallback:self];
    return self;
}

- (void)unlink
{
    [self.executionUnit unlinkCallback:self];
}

@end
