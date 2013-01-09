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

@property (readonly, nonatomic) NSString *bridgeScriptPath;

@property (readonly, nonatomic) NSDictionary *bridgedClasses;

@property (readonly, nonatomic) NSArray *additionalPlugins;

@end
