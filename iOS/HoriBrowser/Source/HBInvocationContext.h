//
//  HBInvocationContext.h
//  HoriBrowser
//
//  Created by Wei Wei on 1/2/13.
//  Copyright (c) 2013 HoriTech Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>


extern NSString * const HBInvocationFailedException;

extern NSString * const HBInvocationUnknownReason;
extern NSString * const HBInvocationObjectNotFoundReason;
extern NSString * const HBInvocationMethodNotFoundReason;
extern NSString * const HBInvocationArgumentErrorReason;

@class HBExecutionUnit;

@interface HBInvocationContext : NSObject

+ (HBInvocationContext *)contextWithExecutionUnit:(HBExecutionUnit *)executionUnit
                          andInvocationDictionary:(NSDictionary *)dictionary;

@property (retain, nonatomic) HBExecutionUnit *executionUnit;
@property (retain, nonatomic) NSString *objectPath;
@property (retain, nonatomic) NSString *method;
@property (retain, nonatomic) id arguments;
@property (retain, nonatomic) NSNumber *index;

@property (retain, nonatomic) NSException *exception;
@property (retain, nonatomic) id returnValue;

@property (readonly, nonatomic) NSDictionary *completionJSON;

- (id)initWithExecutionUnit:(HBExecutionUnit *)executionUnit
    andInvocationDictionary:(NSDictionary *)dictionary;

- (void)complete;

- (void)completeWithException:(NSException *)exception;
- (void)succeed;
- (void)fail;

- (void)raiseArgumentError:(NSString *)argument;

@end
