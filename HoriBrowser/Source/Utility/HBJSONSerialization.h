//
//  HBJSONSerialization.h
//  HoriBrowser
//
//  Created by Wei Wei on 1/2/13.
//  Copyright (c) 2013 HoriTech Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HBJSONSerialization : NSObject

+ (id)JSONObjectWithString:(NSString *)string error:(NSError **)error;

+ (NSString *)stringWithJSONObject:(id)JSONObject error:(NSError **)error;

@end
