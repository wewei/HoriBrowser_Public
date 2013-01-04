//
//  HBExecutionUnit.h
//  HoriBrowser
//
//  Created by Wei Wei on 12/30/12.
//  Copyright (c) 2012 HoriTech Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HBNamespace;

@interface HBExecutionUnit : UIViewController<UIWebViewDelegate>

@property (readonly, nonatomic) UIWebView *webView;
@property (readonly, nonatomic) HBNamespace *currentNamespace;

- (void)loadURL:(NSURL *)URL;

@end
