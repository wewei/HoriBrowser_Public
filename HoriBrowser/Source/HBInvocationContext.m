//
//  HBInvocationContext.m
//  HoriBrowser
//
//  Created by Wei Wei on 1/2/13.
//  Copyright (c) 2013 HoriTech Ltd. All rights reserved.
//

#import "HBInvocationContext.h"
#import "HBJSONSerialization.h"
#import "HBExecutionUnit.h"

static NSString * const HBInvocationAttributeObjectPath = @"objectPath";
static NSString * const HBInvocationAttributeMethod = @"method";
static NSString * const HBInvocationAttributeArguments = @"arguments";
static NSString * const HBInvocationAttributeIndex = @"index";

static NSString * const HBCompletionAttributeStatus = @"status";
static NSString * const HBCompletionAttributeReturnValue = @"returnValue";
static NSString * const HBCompletionAttributeIndex = @"index";

@implementation HBInvocationContext

+ (HBInvocationContext *)contextWithExecutionUnit:(HBExecutionUnit *)executionUnit
                          andInvocationDictionary:(NSDictionary *)dictionary
{
    return [[[HBInvocationContext alloc] initWithExecutionUnit:executionUnit
                                       andInvocationDictionary:dictionary] autorelease];
}

@synthesize executionUnit = _executionUnit;
@synthesize objectPath = _objectPath;
@synthesize method = _method;
@synthesize arguments = _arguments;
@synthesize index = _index;

@synthesize status = _status;
@synthesize returnValue = _returnValue;

- (NSString *)completionJSON
{
    NSDictionary * completionDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                     self.status, HBCompletionAttributeStatus,
                                     self.returnValue, HBCompletionAttributeReturnValue,
                                     self.index, HBCompletionAttributeIndex,
                                     nil];
    
    NSError *error = nil;
    NSString *completionJSON = [HBJSONSerialization stringWithJSONObject:completionDict error:&error];
    assert(error == nil && completionDict != nil);
    
    return completionJSON;
}

- (id)initWithExecutionUnit:(HBExecutionUnit *)executionUnit
    andInvocationDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        self.executionUnit = executionUnit;
        self.objectPath = [dictionary objectForKey:HBInvocationAttributeObjectPath];
        self.method = [dictionary objectForKey:HBInvocationAttributeMethod];
        self.arguments = [dictionary objectForKey:HBInvocationAttributeArguments];
        self.index = [dictionary objectForKey:HBInvocationAttributeIndex];
        
        self.status = [NSNumber numberWithInteger:HBInvocationStatusFailed];
        self.returnValue = [NSNull null];
    }
    return self;
}

- (void)complete
{
    NSString *completionScript = [NSString stringWithFormat:@"$H.__bridge.__completeInvocation(%@)",
                                  self.completionJSON];
    (void)[self.executionUnit.webView stringByEvaluatingJavaScriptFromString:completionScript];
}

- (void)completeWithStatus:(HBInvocationStatus)status
{
    self.status = [NSNumber numberWithInteger:status];
    [self complete];
}

- (void)succeed
{
    [self completeWithStatus:HBInvocationStatusSucceeded];
}

- (void)fail
{
    [self completeWithStatus:HBInvocationStatusFailed];
}

- (void)dealloc
{
    self.executionUnit = nil;
    self.objectPath = nil;
    self.method = nil;
    self.arguments = nil;
    self.index = nil;
    
    self.status = nil;
    self.returnValue = nil;
    
    [super dealloc];
}


@end
