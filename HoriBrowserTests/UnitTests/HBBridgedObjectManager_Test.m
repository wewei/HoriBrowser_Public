//
//  HBBridgedObjectManager_Test.m
//  HoriBrowser
//
//  Created by Wei Wei on 1/3/13.
//  Copyright (c) 2013 HoriTech Ltd. All rights reserved.
//

#import "HBBridgedObjectManager_Test.h"
#import "HBBridgedObjectManager.h"

@implementation HBBridgedObjectManager_Test

- (void)testExample
{
    HBBridgedObjectManager *sharedManager = [HBBridgedObjectManager sharedManager];
    NSString *path = @"/Utility/ObjectManager";
    STAssertEquals(sharedManager,
                   [sharedManager objectForPath:path],
                   @"The shared HBBridgedObjectManager should be mapped at %@",
                   path);
}

@end
