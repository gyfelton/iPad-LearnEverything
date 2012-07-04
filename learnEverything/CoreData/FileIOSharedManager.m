//
//  FileIOSharedManager.m
//  learnEverything
//
//  Created by Yuanfeng on 12-07-03.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FileIOSharedManager.h"
#import "NSData+Base64.h"
#import "AppDelegate.h"
#import "JSONKit.h"
#import "Question+Helpers.h"
#import "NSManagedObject+Helpers.h"
#import "OpenUDID.h"
#import "QuestionType.h"

@interface NSMutableDictionary (Helpers)
- (void)setObjectIfNotNil:(id)obj forKey:(NSString*)key;
@end
    
@implementation NSMutableDictionary (Helpers)
- (void)setObjectIfNotNil:(id)obj forKey:(NSString *)key
{
    if (obj) {
        [self setObject:obj forKey:key];
    } else
    {
        
    }
}
@end

static FileIOSharedManager *sharedManager;

@interface FileIOSharedManager (Private)
- (NSString*)jsonStructureFromManagedObjects:(NSArray*)managedObjects;
- (NSArray*)managedObjectsFromJSONStructure:(NSString*)json withManagedObjectContext:(NSManagedObjectContext*)moc;
@end
    
@implementation FileIOSharedManager
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize managedObjectContext;

+ (FileIOSharedManager*)sharedManager
{
    if (sharedManager == nil) {
        @synchronized(self) {
            if (sharedManager == nil) {
                sharedManager = [[self alloc] init];
                sharedManager.managedObjectContext = ((AppDelegate*)[UIApplication sharedApplication].delegate).managedObjectContext;
            }
        }
    }
    return sharedManager;
}

#pragma mark - Fetch Result Controller

- (NSFetchedResultsController *)getFetchedResultsController
{
    //If exists, just return it
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    // Set up the fetched results controller.
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"QuestionSet" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"create_timestamp" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"QuestionSet"];
    
    //Don't specify the delegate for now
//    aFetchedResultsController.delegate = self;
    
    _fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
	    /*
	     Replace this implementation with code to handle the error appropriately.
         
	     abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
	     */
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        //TODO notify the user about error
	}
    
    return _fetchedResultsController;
}    

#pragma mark - Parse QSJ files

- (NSArray*)_parseJSONDictionaryArray:(NSArray*)arr context:(NSManagedObjectContext*)context
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (NSDictionary *dict in arr) {
        NSEntityDescription *desc = [NSEntityDescription entityForName:@"Question" inManagedObjectContext:context];
        Question *newQn = [[Question alloc]
                           initWithEntity:desc insertIntoManagedObjectContext:context];
        
        //is_active is YES as default
        //_is_initial_value is YES as default
        
        BOOL validQuestion = YES;
        //Set values:
        //1. question is always in text 
        if ([dict objectForKey:@"question_in_text"]) {
            newQn.question_in_text = [dict objectForKey:@"question_in_text"];
        } else
        {
            validQuestion = NO;
        }
        
        //2. answer is dependent on question type
        //assign answer_id to id and text regardless of type
        //Therefore answer_id is a must for text
        if (![dict objectForKey:@"question_type"]) {
            newQn.question_type = [NSNumber numberWithInt:kTxtPlusTxt]; //by default
        } else
        {
            newQn.question_type = [dict objectForKey:@"question_type"];
        }
        
        if ([dict objectForKey:@"answer_id"]) {
            newQn.answer_id = [dict objectForKey:@"answer_id"];
            if (![dict objectForKey:@"answer_in_text"]) {
                //text fallback to id
                newQn.answer_in_text = [dict objectForKey:@"answer_id"];
            } else
            {
                //This has the text needed
                newQn.answer_in_text = [dict objectForKey:@"answer_in_text"];
            }
        } else if ([newQn.question_type intValue] == kTxtPlusPic) {
            if ([dict objectForKey:@"answer_in_image"]) {
                NSString *base64String = [dict objectForKey:@"answer_in_image"];
                NSData *data = [NSData dataWithBase64EncodedString:base64String]; 
                if (!data) {
                    validQuestion = NO;
                } else
                {
                    newQn.answer_in_image = data;
                }
            } else
            {
                validQuestion = NO; //No Image data, not a valid question
            }
        } else
        {
            //Text+Text type but no answer_in_text or id, not a valid question
            validQuestion = NO;
        }

        if ([dict objectForKey:@"create_timestamp"]) {
            newQn.create_timestamp = [dict objectForKey:@"create_timestamp"];
        } else
        {
            newQn.create_timestamp = [NSDate date];
        }
        //For now we put invalid question
        if (!validQuestion) {
            NSLog(@"Detect a invalid question %@", newQn.description);
        }
        
        [array addObject:newQn];
    }
    return array;
}

//When the attributes of QuestionSet updates, update here as well
- (BOOL)_assignValuesToQuestionSetAndSave:(QuestionSet*)set withContext:(NSManagedObjectContext*)context SetID:(NSString*)set_id name:(NSString*)name author:(NSString*)author createDate:(NSDate*)create_date modifyDate:(NSDate*)modifyDate questionType:(NSNumber*)questionType questions:(NSArray*)questions coverImageData:(NSData *)data
{
    // If appropriate, configure the new managed object.
    // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
    [set setValueIfNotNil:create_date forKey:@"create_timestamp"];
    [set setValueIfNotNil:modifyDate forKey:@"modify_timestamp"];
    [set setValueIfNotNil:set_id forKey:@"set_id"];
    [set setValueIfNotNil:name forKey:@"name"];
    [set setValueIfNotNil:author forKey:@"author"];
    [set setValueIfNotNil:questionType forKey:@"question_type"];
    [set setValueIfNotNil:data forKey:@"cover_data"];
    //cover_url not implemented yet
    
    if (questions) {
        for (Question *question in questions) {
            question.belongs_to = set;
        }
        [set addQuestions:[NSSet setWithArray:questions]];
    }
    
    // Save the context.
    NSError *error = nil;
    if (![context save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        //TODO notify the user about error
        return NO;
    }
    return YES;
}

- (BOOL)_insertNewObjectWithSetID:(NSString*)set_id name:(NSString*)name author:(NSString*)author createDate:(NSDate*)create_date modifyDate:(NSDate*)modifyDate questionType:(NSNumber*)questionType questions:(NSArray*)questions coverImageData:(NSData *)data
{
    // Create a new instance of the entity managed by the fetched results controller.
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
    QuestionSet *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
    
    return [self _assignValuesToQuestionSetAndSave:newManagedObject withContext:context SetID:set_id name:name author:author createDate:create_date modifyDate:modifyDate questionType:questionType questions:questions coverImageData:data];
}

- (BOOL)_parseQuestionSetDictionary:(NSDictionary*)question_set filePath:(NSString*)path fileNameAsSetID:(NSString*)set_id andInsertToCoreDataIfNil:(QuestionSet*)qnSet
{
    if (!set_id) {
        return NO;
    }
    
    NSString *name = [question_set objectForKey:@"name"];
    NSString *author = [question_set objectForKey:@"author"];
    NSNumber *questionType = [question_set objectForKey:@"question_type"];
    NSArray *questionRawData = [question_set objectForKey:@"questions"];
    NSDate *createDate = [question_set objectForKey:@"create_timestamp"];
    NSDate *modifyDate = [question_set objectForKey:@"modify_timestamp"];
    
    NSString *cover_data_base64_string = [question_set objectForKey:@"cover_data"];
    NSData *cover_data = [NSData dataWithBase64EncodedString:cover_data_base64_string];
    
    NSArray *questions = [self _parseJSONDictionaryArray:questionRawData context:[self.fetchedResultsController managedObjectContext]];
    
    if (!questions) {
        NSLog(@"FAIL TO PARSE QUESTIONS FROM QSJ FILE");
    } else
    {
    }
    
    if (!qnSet) {
        return [self _insertNewObjectWithSetID:set_id name:name author:author createDate:createDate modifyDate:modifyDate questionType:questionType questions:questions coverImageData:cover_data];
    } else
    {
        return [self _assignValuesToQuestionSetAndSave:qnSet withContext:self.managedObjectContext SetID:set_id name:name author:author createDate:createDate modifyDate:modifyDate questionType:questionType questions:questions coverImageData:cover_data];
    }
    
}

- (void)checkCachedQuestionSets
{
    //Check for existing qsj files to load question set if need

    NSArray *array = [[NSBundle mainBundle] pathsForResourcesOfType:@"qsj" inDirectory:nil];
    NSError *error = nil;
    NSString *pathForQuestionSet;
    for (NSString *path in array) {
        NSString *set_id = [[path lastPathComponent] stringByDeletingPathExtension];
        NSArray *questionSetArr = [self.fetchedResultsController fetchedObjects];
        BOOL alreadyExists = NO;
        QuestionSet *questionSet = nil;
        for (QuestionSet *set in questionSetArr) {
            if ([set.set_id isEqualToString:set_id]) {
                alreadyExists = YES;
                questionSet = set;
                pathForQuestionSet = path;
                break;
            }
        }
        if (!alreadyExists) {
            NSString *jsonStr = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
            NSDictionary *resultDict = [jsonStr objectFromJSONString];
            BOOL success = [self _parseQuestionSetDictionary:resultDict filePath:path fileNameAsSetID:set_id andInsertToCoreDataIfNil:nil];
        } else
        {
            NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:&error];
            if ([questionSet.modify_timestamp compare:[attributes objectForKey:NSFileModificationDate]] == NSOrderedAscending) {
                //TODO need testing on this
                //modification date is later, should update
                NSString *jsonStr = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
                
                NSMutableDictionary *resultDict = [NSMutableDictionary dictionaryWithDictionary:[jsonStr objectFromJSONString]];
                
                //Assign dates info to dict to update the questionSet
                [resultDict setValue:[attributes objectForKey:NSFileModificationDate] forKey:@"modify_date"];
                [resultDict setValue:[attributes objectForKey:NSFileCreationDate] forKey:@"create_date"];
                
                [self _parseQuestionSetDictionary:resultDict filePath:path fileNameAsSetID:set_id andInsertToCoreDataIfNil:questionSet];
            }
        }
    }
}

- (BOOL)insertNewObject
{
    //Create a unique ID
    NSString *uniqueID = [NSString stringWithFormat:@"user_%@_on_%d", [OpenUDID value], [[NSDate date] timeIntervalSinceReferenceDate]];
    
    NSData *imgData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:QUESTION_SET_DEFAULT_COVER_NAME ofType:@"png"]];
    
    return [self _insertNewObjectWithSetID:uniqueID name:@"我的题库" author:@"用户" createDate:[NSDate date] modifyDate:[NSDate date] questionType:[NSNumber numberWithInt:kUnknownQuestionType] questions:nil coverImageData:imgData];
}

#pragma mark - Serialize Managed objects to NSDitionary

- (id)_parseAttributesHelperWithManagedObject:(NSManagedObject*)object AttributeDescription:(NSAttributeDescription*)attribute theKey:(NSString*)aKey
{
    //For our case, we have NSData, NSDate and NSSet needs special considerations
    switch (attribute.attributeType) {
        case NSBinaryDataAttributeType:
        {
            NSData *data = [object valueForKey:aKey];
            return [data base64EncodingWithLineLength:0];
        }
            break;
        case NSDateAttributeType:
        default:
        {
            return [object valueForKey:aKey];
        }
            break;
    }
    
    return nil;
}

- (NSMutableDictionary*)jsonCompatitableDictionaryFromQuestion:(Question*)question
{
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    NSDictionary *attributesByName = [[question entity] attributesByName];
    for (NSString *aKey in [attributesByName allKeys]) {
        id objectToPut = [self _parseAttributesHelperWithManagedObject:question AttributeDescription:[attributesByName objectForKey:aKey] theKey:aKey];
        [result setObjectIfNotNil:objectToPut forKey:aKey];
    }
    return result;
}

- (NSMutableDictionary*)jsonCompatitableDictionaryFromQuestionSet:(QuestionSet*)set filterInCompleteQuestion:(BOOL)filterIncomplete filterInActiveQuestions:(BOOL)filterInActive
{
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    
    @autoreleasepool {
        NSDictionary *attributesByName = [[set entity] attributesByName];
        for (NSString *aKey in [attributesByName allKeys]) {
            id objectToPut = [self _parseAttributesHelperWithManagedObject:set AttributeDescription:[attributesByName objectForKey:aKey] theKey:aKey];
            [result setObjectIfNotNil:objectToPut forKey:aKey];
        }
        
        NSMutableArray *questionsArray = [[NSMutableArray alloc] initWithCapacity:[set.questions count]];
        //Special: deal with questions, a relationship
        for (Question* question in set.questions)
        {
            if (filterInActive &&  !question.is_active) {
                continue; //should skip this question
                //TODO for incomplete question
            }
            NSMutableDictionary *dict = [self jsonCompatitableDictionaryFromQuestion:question];
            [questionsArray addObject:dict];
        }
        
        [result setObjectIfNotNil:questionsArray forKey:@"question"];
    }
    
    return result;
}

@end
