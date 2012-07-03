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

@interface FileIOSharedManager : NSObject

- (NSMutableDictionary*)jsonCompatitableDictionaryFromQuestionSet:(QuestionSet*)set filterInCompleteQuestion:(BOOL)filterIncomplete filterInActiveQuestions:(BOOL)filterInActive;
+ (FileIOSharedManager*)sharedManager;

@end
