//
//  HBInvocationContext.h
//  HoriBrowser
//
//  Created by Wei Wei on 1/2/13.
//  Copyright (c) 2013 HoriTech Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HBExecutionUnit;

typedef enum {
    HBInvocationStatusSucceeded        = 0,
    HBInvocationStatusFailed,
    HBInvocationStatusObjectNotFound,
    HBInvocationStatusMethodNotFound,
    HBInvocationStatusArgumentError,
    HBInvocationStatusInternalError,
} HBInvocationStatus;

@interface HBInvocationContext : NSObject

+ (HBInvocationContext *)contextWithExecutionUnit:(HBExecutionUnit *)executionUnit
                          andInvocationDictionary:(NSDictionary *)dictionary;

@property (retain, nonatomic) HBExecutionUnit *executionUnit;
@property (retain, nonatomic) NSString *objectPath;
@property (retain, nonatomic) NSString *method;
@property (retain, nonatomic) id arguments;
@property (retain, nonatomic) NSNumber *index;

@property (retain, nonatomic) NSNumber *status;
@property (retain, nonatomic) id returnValue;

@property (readonly, nonatomic) NSDictionary *completionJSON;

- (id)initWithExecutionUnit:(HBExecutionUnit *)executionUnit
    andInvocationDictionary:(NSDictionary *)dictionary;

- (void)complete;

- (void)completeWithStatus:(HBInvocationStatus)status;
- (void)succeed;
- (void)fail;

@end
