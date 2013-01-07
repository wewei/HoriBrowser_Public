//
//  HBCallback.h
//  HoriBrowser
//
//  Created by Wei Wei on 1/7/13.
//  Copyright (c) 2013 HoriTech Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HBInvocationContext;
@class HBExecutionUnit;

@interface HBCallback : NSObject

@property (assign, nonatomic) HBInvocationContext *invocationContext;
@property (assign, nonatomic) HBExecutionUnit *executionUnit;
@property (assign, nonatomic) NSUInteger index;

+ (HBCallback *)callbackWithIndex:(NSUInteger)index inContext:(HBInvocationContext *)context;
+ (HBCallback *)callbackWithIndex:(NSUInteger)index inExecutionUnit:(HBExecutionUnit *)executionUnit;

- (id)initWithIndex:(NSUInteger)index inContext:(HBInvocationContext *)context;
- (id)initWithIndex:(NSUInteger)index inExecutionUnit:(HBExecutionUnit *)executionUnit;

- (id)callWithArguments:(id)arguments;
- (void)asyncCallWithArguments:(id)arguments;
- (id)persist;
- (void)unlink;

@end
