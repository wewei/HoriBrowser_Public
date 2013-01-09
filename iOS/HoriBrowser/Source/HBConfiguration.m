//
//  HBConfiguration.m
//  HoriBrowser
//
//  Created by Wei Wei on 12/30/12.
//  Copyright (c) 2012 HoriTech Ltd. All rights reserved.
//

#import "HBConfiguration.h"

static HBConfiguration *sharedInstance = nil;

@interface HBConfiguration()

@property (readonly, nonatomic) NSDictionary *pluginDictionary;

@end

@implementation HBConfiguration

+ (HBConfiguration *)sharedConfiguration
{
    if (sharedInstance == nil) {
        sharedInstance = [[HBConfiguration alloc] init];
    }
    return sharedInstance;
}

@synthesize serverURL = __serverURL;

- (NSURL *)serverURL
{
    if (__serverURL == nil) {
        __serverURL = [[NSURL alloc] initWithString:@"http://localhost:8000/static/index.html"];
    }
    return __serverURL;
}


@synthesize bridgeScriptPath = __bridgeScriptPath;


- (NSString *)bridgeScriptPath
{
    if (__bridgeScriptPath == nil) {
        __bridgeScriptPath = [[[NSBundle mainBundle] pathForResource:@"HoriBridge" ofType:@"js"] retain];
    }
    return __bridgeScriptPath;
}

@synthesize pluginDictionary = __pluginDictionary;

- (NSDictionary *)pluginDictionary
{
    if (__pluginDictionary == nil) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"Plugins" ofType:@"plist"];
        __pluginDictionary = [[NSDictionary alloc] initWithContentsOfFile:path];
    }
    return __pluginDictionary;
}

- (NSDictionary *)bridgedClasses
{
    return [self.pluginDictionary objectForKey:@"BridgedClasses"];
}

- (NSArray *)additionalPlugins
{
    return [self.pluginDictionary objectForKey:@"AdditionalPlugins"];
}

- (void)dealloc
{
    [__serverURL release];
    [__bridgeScriptPath release];
    [__pluginDictionary release];
    [super dealloc];
}



@end
