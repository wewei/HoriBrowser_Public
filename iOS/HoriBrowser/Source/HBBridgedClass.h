//
//  HBBridgedClass.h
//  HoriBrowser
//
//  Created by Wei Wei on 1/3/13.
//  Copyright (c) 2013 HoriTech Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HBExecutionUnit;

@interface HBBridgedClass : NSObject

@property (readonly, nonatomic) NSString *name;
@property (readonly, nonatomic) NSString *objcName;

+ (HBBridgedClass *)classWithName:(NSString *)name objcName:(NSString *)objcName;
- (id)initWithName:(NSString *)name objcName:(NSString *)objcName;

- (id)instantiateWithArguments:(id)arguments inExecutionUnit:(HBExecutionUnit *)executionUnit;

@end
