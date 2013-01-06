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
#import "NSObject+BridgedAPI.h"
#import "HBInvocationContext.h"
#import "HBConfiguration.h"
#import "HBNamespace.h"


@interface HBExecutionUnit()

@property (assign, atomic, getter = isFlushing) BOOL flushing;
@property (assign, atomic, getter = isLoading) BOOL loading;
@property (copy, nonatomic) void (^completion)(BOOL);

@end

@implementation HBExecutionUnit

+ (HBExecutionUnit *)executionUnit
{
    return [[[HBExecutionUnit alloc] init] autorelease];
}

@synthesize webView = __webView;
@synthesize currentNamespace = __currentNamespace;
@synthesize tempNamespace = __tempNamespace;

@synthesize flushing = _flushing;
@synthesize loading = _loading;

@synthesize completion = _completion;

- (UIWebView *)webView
{
    if (__webView == nil) {
        __webView = [[UIWebView alloc] initWithFrame:CGRectNull];
        __webView.delegate = self;
    }
    return __webView;
}

- (HBNamespace *)currentNamespace
{
    if (__currentNamespace == nil) {
        __currentNamespace = [[HBNamespace alloc] init];
        [__currentNamespace setOwner:self withName:@"WebViewController"];
        [__currentNamespace setObject:self.webView forName:@"WebView"];
        [__currentNamespace setObject:self.tempNamespace forName:@"Temp"];
    }
    return __currentNamespace;
}

- (HBNamespace *)tempNamespace
{
    if (__tempNamespace == nil) {
        __tempNamespace = [[HBNamespace alloc] init];
    }
    return __tempNamespace;
}

- (id)init
{
    self = [super init];
    if (self) {
        __webView = nil;
        _flushing = NO;
        _loading = NO;
        
        self.completion = nil;
        self.view = self.webView;
    }
    return self;
}

- (id)retain
{
    return [super retain];
}

- (oneway void)release
{
    [super release];
}

- (void)dealloc
{
    [__webView release];
    [__currentNamespace release];
    [__tempNamespace release];
    
    self.completion = nil;
    
    [super dealloc];
}

- (void)loadURL:(NSURL *)URL
{
    [self loadURL:URL withCompletion:nil];
}

- (void)loadURL:(NSURL *)URL withCompletion:(void (^)(BOOL))completion
{
    assert(!self.isLoading);
    assert(self.completion == nil);
    if (!self.isLoading) {
        performanceTag(@"StartLoad");
        self.loading = YES;
        self.completion = completion;
        
        NSURLRequest *request = [NSURLRequest requestWithURL:URL];
        [self.webView loadRequest:request];
    }
}

- (void)loadURLComplete:(BOOL)loaded
{
    performanceTag(@"LoadComplete");
    if (self.completion != nil) {
        self.completion(loaded);
    }
    self.loading = FALSE;
    // This must be the last statement, setCompletion to nil may dealloc self.
    self.completion = nil;
}

- (NSString *)generateTemporaryPath
{
    unsigned long long timeSeg = (unsigned long long)[[NSDate date] timeIntervalSince1970] * 1000;
    NSInteger randSeg = (NSInteger)(rand() & 0xffff);
    NSInteger randSegStart = randSeg;
    NSString *name = nil;
    do {
        name = [NSString stringWithFormat:@"%012llX%4X", timeSeg, randSeg];
        if ([self.tempNamespace objectForName:name] == nil)
            break;
        randSeg ++;
        if (randSeg == randSegStart)
            return nil;
    } while (true);
    return [NSString stringWithFormat:@"/Current/Temp/%@", name];
}

- (void)triggerInvocationWithDictionary:(NSDictionary *)invocationDict
{
    performanceTag(@"TriggerInvocation");
    HBInvocationContext *context = [HBInvocationContext contextWithExecutionUnit:self
                                                         andInvocationDictionary:invocationDict];
    id object = [[HBBridgedObjectManager sharedManager] objectForPath:context.objectPath
                                                      inExecutionUnit:self];
    if (object != nil) {
        [object triggerInvocationWithContext:context];
    } else {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:context.objectPath
                                                             forKey:@"objectPath"];  // TODO, give it a name?
        NSException *exception = [NSException exceptionWithName:HBInvocationFailedException
                                                         reason:HBInvocationObjectNotFoundReason
                                                       userInfo:userInfo];
        [context completeWithException:exception];
    }
    
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
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSString *checkResult = [webView stringByEvaluatingJavaScriptFromString:@"typeof $H == 'function'"];
    if (![checkResult isEqualToString:@"true"]) {
        NSString *script = [HBConfiguration sharedConfiguration].bridgeScript;
        (void)[webView stringByEvaluatingJavaScriptFromString:script];
    }
    [self loadURLComplete:YES];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self loadURLComplete:NO];
}

@end
