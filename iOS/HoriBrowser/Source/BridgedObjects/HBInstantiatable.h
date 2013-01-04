//
//  HBInstantiatable.h
//  HoriBrowser
//
//  Created by Wei Wei on 1/4/13.
//  Copyright (c) 2013 HoriTech Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HBExecutionUnit;

@protocol HBInstantiatable <NSObject>

- (id)initWithArguments:(id)arguments inExecutionUnit:(HBExecutionUnit *)executionUnit;

@end
