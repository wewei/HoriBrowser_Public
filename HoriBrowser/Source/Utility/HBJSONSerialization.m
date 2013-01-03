//
//  HBJSONSerialization.m
//  HoriBrowser
//
//  Created by Wei Wei on 1/2/13.
//  Copyright (c) 2013 HoriTech Ltd. All rights reserved.
//

#import "HBJSONSerialization.h"

@implementation HBJSONSerialization

+ (id)JSONObjectWithString:(NSString *)string error:(NSError **)error
{
    if (string.length == 0 || string == nil)
        return nil;
    
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    id JSONObject = [NSJSONSerialization JSONObjectWithData:data
                                                    options:NSJSONReadingAllowFragments
                                                      error:error];
    return JSONObject;
}

+ (NSString *)stringWithJSONObject:(id)JSONObject error:(NSError **)error
{
    NSString *string = nil;
    if (JSONObject == nil || JSONObject == [NSNull null]) {
        string = @"null";
    } else {
        NSData *data = [NSJSONSerialization dataWithJSONObject:JSONObject
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:error];
        string = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
    }
    return string;
}

@end
