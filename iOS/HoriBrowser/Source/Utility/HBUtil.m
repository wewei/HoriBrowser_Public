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