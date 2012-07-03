//
//  Question.h
//  learnEverything
//
//  Created by Yuanfeng on 12-07-03.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "QuestionType.h"

@class QuestionSet;

@interface Question : NSManagedObject

@property (nonatomic, retain) NSString * answer_id;
@property (nonatomic, retain) NSString * answer_in_text;
@property (nonatomic, retain) NSDate * create_timestamp;
@property (nonatomic, retain) NSNumber * is_active;
@property (nonatomic, retain) NSNumber * is_initial_value;
@property (nonatomic, retain) NSString * question_in_text;
@property (nonatomic, retain) NSNumber * question_type;
@property (nonatomic, retain) NSData * answer_in_image;
@property (nonatomic, retain) QuestionSet *belongs_to;

@end
