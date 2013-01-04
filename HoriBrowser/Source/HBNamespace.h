//
//  HBNamespace.h
//  HoriBrowser
//
//  Created by Wei Wei on 1/2/13.
//  Copyright (c) 2013 HoriTech Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HBNamespace : NSObject

+ (HBNamespace *)rootNamespace;
+ (HBNamespace *)systemNamespace;
+ (HBNamespace *)classNamespace;

- (id)objectForName:(NSString *)name;
- (void)setObject:(id)object forName:(NSString *)name;

@end
