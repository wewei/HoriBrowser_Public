//
//  HBBridgedClass+BridgedAPI.h
//  HoriBrowser
//
//  Created by Wei Wei on 1/3/13.
//  Copyright (c) 2013 HoriTech Ltd. All rights reserved.
//

#import "HBBridgedClass.h"
#import "HBInvocationContext.h"

@interface HBBridgedClass (BridgedAPI)

- (void)method_new:(HBInvocationContext *)context;

@end
