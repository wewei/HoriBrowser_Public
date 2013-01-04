//
//  HBJSONSerialization.m
//  HoriBrowser
//
//  Created by Wei Wei on 1/2/13.
//  Copyright (c) 2013 HoriTech Ltd. All rights reserved.
//

#import "HBJSONSerialization.h"

@implementation HBJSONSerialization

+ (id)normalizedJSONObjectForObject:(id)object
{
    if (object == nil || object == [NSNull null])
        return [NSNull null];
    else if ([object isKindOfClass:[NSString class]])
        return object;
    else if ([object isKindOfClass:[NSNumber class]])
        return object;
    else if ([object isKindOfClass:[NSArray class]]) {
        NSMutableArray *newArray = [NSMutableArray array];
        for (id obj in (NSArray *)object) {
            [newArray addObject:[HBJSONSerialization normalizedJSONObjectForObject:obj]];
        }
        return newArray;
    } else if ([object isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *newDict = [NSMutableDictionary dictionary];
        [(NSDictionary *)object enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [newDict setObject:[HBJSONSerialization normalizedJSONObjectForObject:obj]
                        forKey:[HBJSONSerialization normalizedJSONObjectForObject:key]];
        }];
        return newDict;
    } else {
        return [object description];
    }
}

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
    id normalizedObject = [HBJSONSerialization normalizedJSONObjectForObject:JSONObject];
    if (normalizedObject == [NSNull null]) {
        return @"null";
    } else {
        NSData *data = [NSJSONSerialization dataWithJSONObject:normalizedObject
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:error];
        return [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
    }
}

@end
