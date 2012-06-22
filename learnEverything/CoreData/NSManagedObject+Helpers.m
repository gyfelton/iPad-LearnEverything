//
//  NSManagedObject+Helpers.m
//  learnEverything
//
//  Created by Yuanfeng on 12-06-22.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NSManagedObject+Helpers.h"

@implementation NSManagedObject (Helpers)
- (void)setValueIfNotNil:(id)value forKey:(NSString *)key
{
    if (value) {
        [super setValue:value forKey:key];
    } else
    {
        
    }
}

@end
