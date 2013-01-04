//
//  HBConfiguration.h
//  HoriBrowser
//
//  Created by Wei Wei on 12/30/12.
//  Copyright (c) 2012 HoriTech Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HBConfiguration : NSObject

+ (HBConfiguration *)sharedConfiguration;

@property (readonly, nonatomic) NSURL *serverURL;

@property (readonly, nonatomic) NSString *bridgeScript;
@property (readonly, nonatomic) NSString *createFrameScript;

@property (readonly, nonatomic) NSDictionary *bridgedClasses;

@end
