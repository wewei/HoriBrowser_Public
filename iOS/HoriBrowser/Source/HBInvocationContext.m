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

NSString * const HBInvocationFailedException = @"InvocationFailed";

NSString * const HBInvocationUnknownReason = @"Unknown Reason.";
NSString * const HBInvocationObjectNotFoundReason = @"Target object not found.";
NSString * const HBInvocationMethodNotFoundReason = @"Method not found.";
NSString * const HBInvocationArgumentErrorReason = @"Argument Error";


static NSString * const HBInvocationAttributeObjectPath = @"objectPath";
static NSString * const HBInvocationAttributeMethod = @"method";
static NSString * const HBInvocationAttributeArguments = @"arguments";
static NSString * const HBInvocationAttributeIndex = @"index";

static NSString * const HBExceptionAttributeName = @"name";
static NSString * const HBExceptionAttributeReason = @"reason";
static NSString * const HBExceptionAttributeUserInfo = @"userInfo";

static NSString * const HBCompletionAttributeException = @"exception";
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

@synthesize exception = _exception;
@synthesize returnValue = _returnValue;

- (NSString *)completionJSON
{
    NSDictionary *exceptionDict = nil;
    if (self.exception != nil)
        exceptionDict = [NSDictionary dictionaryWithObjectsAndKeys:
                         HBNoneNil(self.exception.name), HBExceptionAttributeName,
                         HBNoneNil(self.exception.reason), HBExceptionAttributeReason,
                         HBNoneNil(self.exception.userInfo), HBExceptionAttributeUserInfo,
                         nil];
    NSDictionary *completionDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                    HBNoneNil(exceptionDict), HBCompletionAttributeException,
                                    HBNoneNil(self.returnValue), HBCompletionAttributeReturnValue,
                                    HBNoneNil(self.index), HBCompletionAttributeIndex,
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
        
        self.exception = nil;
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

- (void)completeWithException:(NSException *)exception
{
    self.exception = exception;
    [self complete];
}

- (void)succeed
{
    [self completeWithException:nil];
}

- (void)fail
{
    [self completeWithException:[NSException exceptionWithName:HBInvocationFailedException
                                                        reason:HBInvocationUnknownReason
                                                      userInfo:nil]];
}

- (void)dealloc
{
    self.executionUnit = nil;
    self.objectPath = nil;
    self.method = nil;
    self.arguments = nil;
    self.index = nil;
    
    self.exception = nil;
    self.returnValue = nil;
    
    [super dealloc];
}


@end
