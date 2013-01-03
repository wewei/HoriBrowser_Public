//
//  HBExecutionUnit.h
//  HoriBrowser
//
//  Created by Wei Wei on 12/30/12.
//  Copyright (c) 2012 HoriTech Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HBExecutionUnit : NSObject<UIWebViewDelegate>

@property (readonly, nonatomic) UIWebView *webView;

- (void)loadURL:(NSURL *)URL;

@end
