//
//  HBInvocationStatus.h
//  HoriBrowser
//
//  Created by Wei Wei on 1/3/13.
//  Copyright (c) 2013 HoriTech Ltd. All rights reserved.
//

typedef NSInteger HBInvocationStatus;

#define HBInvocationStatusSucceeded 		 0
#define HBInvocationStatusFailed			-1
#define HBInvocationStatusInternalError		-2

// Invocation Error
#define HBInvocationStatusObjectNotFound	-3
#define HBInvocationStatusMethodNotFound	-4
#define HBInvocationStatusArgumentError		-5
