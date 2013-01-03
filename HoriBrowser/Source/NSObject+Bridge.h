//
//  NSObject+Bridge.h
//  HoriBrowser
//
//  Created by Wei Wei on 1/2/13.
//  Copyright (c) 2013 HoriTech Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HBInvocationContext.h"

@interface NSObject (Bridge)

- (void)triggerInvocationWithContext:(HBInvocationContext *)context;

@end
