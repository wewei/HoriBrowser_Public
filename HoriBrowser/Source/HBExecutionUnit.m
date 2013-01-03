//
//  HBExecutionUnit.m
//  HoriBrowser
//
//  Created by Wei Wei on 12/30/12.
//  Copyright (c) 2012 HoriTech Ltd. All rights reserved.
//

#import "HBExecutionUnit.h"
#import "HBJSONSerialization.h"
#import "HBBridgedObjectManager.h"
#import "NSObject+Bridge.h"
#import "HBInvocationContext.h"
#import "HBConfiguration.h"



@interface HBExecutionUnit()

@property (assign, atomic, getter = isFlushing) BOOL flushing;

@end

@implementation HBExecutionUnit

@synthesize webView = __webView;

@synthesize flushing = _flushing;

- (UIWebView *)webView
{
    if (__webView == nil) {
        __webView = [[UIWebView alloc] initWithFrame:CGRectNull];
        __webView.delegate = self;
    }
    return __webView;
}


- (id)init
{
    self = [super init];
    if (self) {
        __webView = nil;
        _flushing = NO;
    }
    return self;
}

- (void)dealloc
{
    [__webView release];
    [super dealloc];
}

- (void)loadURL:(NSURL *)URL
{
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    [self.webView loadRequest:request];
}

- (void)triggerInvocationWithDictionary:(NSDictionary *)invocationDict
{
    HBInvocationContext *context = [HBInvocationContext contextWithExecutionUnit:self
                                                         andInvocationDictionary:invocationDict];
    id object = [[HBBridgedObjectManager sharedManager] objectForPath:context.objectPath];
    if (object == nil) {
        context.status = [NSNumber numberWithInteger:HBInvocationStatusObjectNotFound];
        [context complete];
    }
    
    [object triggerInvocationWithContext:context];
}

- (BOOL)pullInvocation
{
    NSString *invocationJSON = [self.webView stringByEvaluatingJavaScriptFromString:@"$H.__bridge.__retrieveInvocation();"];
    
    if (invocationJSON == nil)
        return NO;
    
    NSError *error = nil;
    id invocationObject = [HBJSONSerialization JSONObjectWithString:invocationJSON
                                                              error:&error];
    if (error == nil) {
        if (invocationObject == [NSNull null] || invocationObject == nil)
            return NO;
        if ([invocationObject isKindOfClass:[NSDictionary class]])
            [self triggerInvocationWithDictionary:(NSDictionary *)invocationObject];
    } else {
        NSLog(@"%@", error);
    }
    return YES;
}

- (void)flushInvocations
{
    if (self.flushing)
        return;
    
    self.flushing = YES;
    while ([self pullInvocation]) { }
    self.flushing = NO;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if ([request.URL.scheme isEqualToString:@"bridge"]) {
        [self flushInvocations];
        return NO;
    }
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    (void)[webView stringByEvaluatingJavaScriptFromString:[HBConfiguration sharedConfiguration].bridgeScript];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSString *script = [HBConfiguration sharedConfiguration].createFrameScript;
    (void)[webView stringByEvaluatingJavaScriptFromString:script];
}

@end
