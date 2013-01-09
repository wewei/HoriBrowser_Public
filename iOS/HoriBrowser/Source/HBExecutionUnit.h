//
//  HBExecutionUnit.h
//  HoriBrowser
//
//  Created by Wei Wei on 12/30/12.
//  Copyright (c) 2012 HoriTech Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#define BRIDGE_MAGIC_NUMBER 0xabedcafe

@class HBNamespace;
@class HBCallback;

@interface HBExecutionUnit : UIViewController<UIWebViewDelegate>

@property (readonly, nonatomic) UIWebView *webView;
@property (readonly, nonatomic) HBNamespace *currentNamespace;
@property (readonly, nonatomic) HBNamespace *tempNamespace;

+ (HBExecutionUnit *)executionUnit;

- (void)loadURL:(NSURL *)URL;
- (void)loadURL:(NSURL *)URL withCompletion:(void (^)(BOOL))completion;

- (NSString *)generateTemporaryPath;

- (NSUInteger)persistCallback:(HBCallback *)callback;
- (void)unlinkCallback:(HBCallback *)callback;

- (void)raiseArgumentError:(NSString *)argument;

@end
