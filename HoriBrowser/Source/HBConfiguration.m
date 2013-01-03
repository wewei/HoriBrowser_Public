//
//  HBConfiguration.m
//  HoriBrowser
//
//  Created by Wei Wei on 12/30/12.
//  Copyright (c) 2012 HoriTech Ltd. All rights reserved.
//

#import "HBConfiguration.h"

static HBConfiguration *sharedInstance = nil;

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
        __serverURL = [[NSURL alloc] initWithString:@"http://localhost/"];
    }
    return __serverURL;
}


@synthesize bridgeScript = __bridgeScript;


- (NSString *)bridgeScript
{
    if (__bridgeScript == nil) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"HoriBridge" ofType:@"js"];
        NSError *error = nil;
        __bridgeScript = [[NSString alloc] initWithContentsOfFile:path
                                                         encoding:NSUTF8StringEncoding
                                                            error:&error];
        assert(error == nil);
    }
    return __bridgeScript;
}

@synthesize createFrameScript = __createFrameScript;

- (NSString *)createFrameScript
{
    if (__createFrameScript == nil) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"CreateBridgeFrame" ofType:@"js"];
        NSError *error = nil;
        __createFrameScript = [[NSString alloc] initWithContentsOfFile:path
                                                              encoding:NSUTF8StringEncoding
                                                                 error:&error];
        assert(error == nil);
    }
    return __createFrameScript;
}

- (void)dealloc
{
    [__serverURL release];
    [__bridgeScript release];
    [__createFrameScript release];
    [super dealloc];
}



@end
