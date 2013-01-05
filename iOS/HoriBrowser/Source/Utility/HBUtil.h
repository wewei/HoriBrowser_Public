//
//  HBUtil.h
//  HoriBrowser
//
//  Created by Wei Wei on 1/4/13.
//  Copyright (c) 2013 HoriTech Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

inline id HBNoneNil(id obj);
inline unsigned int millisecondsSince1970();

#ifdef ENABLE_PERF_TAG
void performanceTag(NSString *tag);
#else // ENABLE_PERF_TAG
#define performanceTag(tag)
#endif // ENABLE_PERF_TAG