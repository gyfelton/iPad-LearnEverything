//
//  QuestionSet.h
//  learnEverything
//
//  Created by Yuanfeng on 12-06-21.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Question;

@interface QuestionSet : NSManagedObject

@property (nonatomic, retain) NSString * set_id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString *cover_url;
@property (nonatomic, retain) NSDate * create_timestamp;
@property (nonatomic, retain) NSDate * modify_timestamp;
@property (nonatomic, retain) NSSet *questions;

@end

@interface QuestionSet (CoreDataGeneratedAccessors)

- (void)addQuestionsObject:(Question *)value;
- (void)removeQuestionsObject:(Question *)value;
- (void)addQuestions:(NSSet *)values;
- (void)removeQuestions:(NSSet *)values;
@end
