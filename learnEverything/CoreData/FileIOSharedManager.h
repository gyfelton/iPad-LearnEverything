//
//  FileIOSharedManager.h
//  learnEverything
//
//  Created by Yuanfeng on 12-07-03.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Question.h"
#import "QuestionSet.h"

#define QUESTION_SET_DEFAULT_COVER_NAME @"qn_set_cover_default"

@interface FileIOSharedManager : NSObject
{
    NSFetchedResultsController *_fetchedResultsController;
}

- (NSMutableDictionary*)jsonCompatitableDictionaryFromQuestion:(Question*)question;
- (NSMutableDictionary*)jsonCompatitableDictionaryFromQuestionSet:(QuestionSet*)set filterInCompleteQuestion:(BOOL)filterIncomplete filterInActiveQuestions:(BOOL)filterInActive;
- (NSData*)dataFromJSONParsedQuestionSet:(QuestionSet*)set filterInCompleteQuestion:(BOOL)filterIncomplete filterInActiveQuestions:(BOOL)filterInActive;
- (void)checkCachedQuestionSetsWithCompletion:(void (^)(BOOL finished))completion;;
- (BOOL)insertNewObject;
- (void)parseQSJFileWithURL:(NSURL*)url;

+ (FileIOSharedManager*)sharedManager;

@property (nonatomic, strong) NSDateFormatter *dateFormatterUsed;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, readonly, getter = getFetchedResultsController) NSFetchedResultsController *fetchedResultsController;

@end