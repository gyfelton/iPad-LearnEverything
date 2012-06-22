//
//  Question+Helpers.h
//  learnEverything
//
//  Created by Yuanfeng on 12-06-22.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Question.h"

@interface Question (Helpers)

+ (NSArray*)parseJSONDictionaryArray:(NSArray*)arr context:(NSManagedObjectContext*)context;

@end
