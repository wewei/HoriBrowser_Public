//
//  HBBridgedObjectManager_Test.m
//  HoriBrowser
//
//  Created by Wei Wei on 1/3/13.
//  Copyright (c) 2013 HoriTech Ltd. All rights reserved.
//

#import "HBBridgedObjectManager_Test.h"
#import "HBBridgedObjectManager.h"
#import "HBNamespace.h"

@implementation HBBridgedObjectManager_Test

- (void)testExample
{
    HBBridgedObjectManager *sharedManager = [HBBridgedObjectManager sharedManager];
    NSString *path = @"/System/ObjectManager";
    STAssertEquals(sharedManager,
                   [sharedManager objectForPath:path inExecutionUnit:nil],
                   @"The shared HBBridgedObjectManager should be mapped at %@",
                   path);
    
    STAssertEquals([HBNamespace rootNamespace],
                   [sharedManager objectForPath:@"" inExecutionUnit:nil],
                   @"Empty string should be mapped to the rootNamespace");
    
    
    STAssertEquals([HBNamespace rootNamespace],
                   [sharedManager objectForPath:@"/" inExecutionUnit:nil],
                   @"'/' should be mapped to the rootNamespace");
}

@end
