//
//  NSManagedObject+Helpers.h
//  learnEverything
//
//  Created by Yuanfeng on 12-06-22.
//  Copyright (c) 2012 ____Yuanfeng Gao___. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (Helpers)

- (void)setValueIfNotNil:(id)value forKey:(NSString *)key;

@end
