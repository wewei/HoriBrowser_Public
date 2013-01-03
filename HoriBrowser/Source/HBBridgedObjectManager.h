//
//  HBBridgedObjectManager.h
//  HoriBrowser
//
//  Created by Wei Wei on 1/3/13.
//  Copyright (c) 2013 HoriTech Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HBExecutionUnit;

@interface HBBridgedObjectManager : NSObject

+ (HBBridgedObjectManager *)sharedManager;

- (id)objectForPath:(NSString *)path inExecutionUnit:(HBExecutionUnit *)executionUnit;

@end
