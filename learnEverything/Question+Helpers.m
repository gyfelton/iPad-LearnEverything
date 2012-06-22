//
//  Question+Helpers.m
//  learnEverything
//
//  Created by Yuanfeng on 12-06-22.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Question+Helpers.h"

@implementation Question (Helpers)

+ (NSArray*)parseJSONDictionaryArray:(NSArray*)arr context:(NSManagedObjectContext*)context
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (NSDictionary *dict in arr) {
        NSEntityDescription *desc = [NSEntityDescription entityForName:@"Question" inManagedObjectContext:context];
        Question *newQn = [[Question alloc]
                                      initWithEntity:desc insertIntoManagedObjectContext:context];
        
        //Set values
        newQn.question_in_text = [dict objectForKey:@"question_in_text"];
        newQn.answer_id = [dict objectForKey:@"answer_id"];
        if (![dict objectForKey:@"answer_in_text"]) {
            newQn.answer_in_text = [dict objectForKey:@"answer_id"];
        } else
        {
            newQn.answer_in_text = [dict objectForKey:@"answer_in_text"];
        }
        [array addObject:newQn];
    }
    return array;
}
@end
