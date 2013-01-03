//
//  HBAppDelegate.h
//  HoriBrowser
//
//  Created by Wei Wei on 12/30/12.
//  Copyright (c) 2012 HoriTech Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HBExecutionUnit.h"

@interface HBAppDelegate : UIResponder <UIApplicationDelegate>

@property (retain, nonatomic) HBExecutionUnit *mainExecutionUnit;

@property (strong, nonatomic) UIWindow *window;

@end
