//
//  HBUtil.m
//  HoriBrowser
//
//  Created by Wei Wei on 1/4/13.
//  Copyright (c) 2013 HoriTech Ltd. All rights reserved.
//

#import "HBUtil.h"

id HBNoneNil(id obj) {
    return obj == nil ? [NSNull null] : obj;
}

unsigned int millisecondsSince1970() {
    return (unsigned int)([[NSDate date] timeIntervalSince1970] * 1000);
}

#ifdef ENABLE_PERF_TAG
static NSDate *dateOfFirstTag = nil;
static NSDate *dateOfLastTag = nil;
void performanceTag(NSString *tag) {
    NSDate *date = [NSDate date];
    if (dateOfFirstTag == nil)
        dateOfFirstTag = [date retain];
    if (dateOfLastTag == nil)
        dateOfLastTag = [date retain];
    NSLog(@"[PerfTag] %@: (%lf, %lf)",
          tag,
          [date timeIntervalSinceDate:dateOfFirstTag],
          [date timeIntervalSinceDate:dateOfLastTag]
          );
    NSDate *dateLast = dateOfLastTag;
    dateOfLastTag = [date retain];
    [dateLast release];
}
#endif // ENABLE_PERF_TAG