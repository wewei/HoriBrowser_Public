//
//  HBJSONSerialization_Test.m
//  HoriBrowser
//
//  Created by Wei Wei on 1/2/13.
//  Copyright (c) 2013 HoriTech Ltd. All rights reserved.
//

#import "HBJSONSerialization_Test.h"
#import "HBJSONSerialization.h"

@implementation HBJSONSerialization_Test

@synthesize testCases = __testCases;

- (NSDictionary *)testCases
{
    if (__testCases == nil) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"HBJSONSerialization_TestCases"
                                                         ofType:@"plist"];
        __testCases = [[NSDictionary alloc] initWithContentsOfFile:path];
    }
    return __testCases;
}
- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testSerializeNil
{
    NSError *error = nil;
    NSString *JSONString = [HBJSONSerialization stringWithJSONObject:nil error:&error];
    STAssertNil(error, @"Failed to serialize 'nil', got error %@", error);
    STAssertEqualObjects(JSONString, @"null", @"Expect \"null\" for 'nil'");
    
    error = nil;
    JSONString = [HBJSONSerialization stringWithJSONObject:[NSNull null] error:&error];
    STAssertNil(error, @"Failed to serialize [NSNull null], got error %@", error);
    STAssertEqualObjects(JSONString, @"null", @"Expect \"null\" for [NSNull null].");
    
}

- (void)testSerialization
{
    [self testSerializeNil];
    
    [self.testCases enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSError *error = nil;
        NSString *string = [HBJSONSerialization stringWithJSONObject:obj error:&error];
        STAssertNil(error, @"Failed to serialize JSONObject, got error %@", obj, error);
        STAssertEqualObjects(string, key, @"Expect \"%@\" from JSONObject \"%@\"", key, obj);
    }];
}

- (void)testDeserializeNull
{
    NSString *JSONString = @"null";
    NSError *error = nil;
    id JSONObject = [HBJSONSerialization JSONObjectWithString:JSONString error:&error];
    
    STAssertNil(error, @"Failed to deserialize JSONObject with string '%@', got error %@", JSONString, error);
    STAssertEqualObjects(JSONObject, [NSNull null], @"Expect NSNull for JSON 'null'.");
}

- (void)testDeserialization
{
    [self testDeserializeNull];
    
    [self.testCases enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSError *error = nil;
        id JSONObject = [HBJSONSerialization JSONObjectWithString:key error:&error];
        STAssertNil(error, @"Failed to deserialize JSONObject with string '%@', got error %@", key, error);
        STAssertEqualObjects(JSONObject, obj, @"Expect \"%@\" from JSON \"%@\"", obj, key);
    }];
}

- (void)testExample
{
    [self testSerialization];
    [self testDeserialization];
}
@end
