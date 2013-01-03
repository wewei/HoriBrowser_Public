//
//  HBExecutionUnit.h
//  HoriBrowser
//
//  Created by Wei Wei on 12/30/12.
//  Copyright (c) 2012 HoriTech Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HBNamespace;

@interface HBExecutionUnit : NSObject<UIWebViewDelegate>

@property (readonly, nonatomic) UIWebView *webView;
@property (readonly, nonatomic) UIViewController *webViewController;
@property (readonly, nonatomic) HBNamespace *currentNamespace;

- (void)loadURL:(NSURL *)URL;

@end
