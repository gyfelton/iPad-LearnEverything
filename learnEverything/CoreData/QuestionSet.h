//
//  QuestionSet.h
//  learnEverything
//
//  Created by Yuanfeng on 12-07-06.
//  Copyright (c) 2012 ____Yuanfeng Gao___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "QuestionType.h"

@class Question;

@interface QuestionSet : NSManagedObject

@property (nonatomic, retain) NSString * author;
@property (nonatomic, retain) NSData * cover_data;
@property (nonatomic, retain) NSString * cover_url;
@property (nonatomic, retain) NSDate * create_timestamp;
@property (nonatomic, retain) NSDate * modify_timestamp;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * question_type;
@property (nonatomic, retain) NSString * set_id;
@property (nonatomic, retain) NSNumber * question_subtype;
@property (nonatomic, retain) NSSet *questions;
@end

@interface QuestionSet (CoreDataGeneratedAccessors)

- (void)addQuestionsObject:(Question *)value;
- (void)removeQuestionsObject:(Question *)value;
- (void)addQuestions:(NSSet *)values;
- (void)removeQuestions:(NSSet *)values;
@end
