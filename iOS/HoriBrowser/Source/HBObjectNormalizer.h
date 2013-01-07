//
//  HBObjectNormalizer.h
//  HoriBrowser
//
//  Created by Wei Wei on 1/7/13.
//  Copyright (c) 2013 HoriTech Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HBExecutionUnit;
@class HBInvocationContext;

@interface HBObjectNormalizer : NSObject


+ (HBObjectNormalizer *)normalizerWithInvocationContext:(HBInvocationContext *)context;
+ (HBObjectNormalizer *)normalizerWithExecutionUnit:(HBExecutionUnit *)executionUnit;

- (id)initWithInvocationContext:(HBInvocationContext *)context;
- (id)initWithExecutionUnit:(HBExecutionUnit *)executionUnit;

- (id)normalizeObject:(id)arguments;

@end
