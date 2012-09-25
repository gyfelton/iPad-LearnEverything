//
//  QuestionsSharedManager.m
//  learnEverything
//
//  Created by Yuanfeng on 12-07-03.
//  Copyright (c) 2012 ____Yuanfeng Gao___. All rights reserved.
//

#import "QuestionsSharedManager.h"
#import "NSData+Base64.h"
#import "AppDelegate.h"
#import "JSONKit.h"
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

static QuestionsSharedManager *sharedManager;

@interface QuestionsSharedManager (Private)
- (NSString*)jsonStructureFromManagedObjects:(NSArray*)managedObjects;
- (NSArray*)managedObjectsFromJSONStructure:(NSString*)json withManagedObjectContext:(NSManagedObjectContext*)moc;
@end
    
@implementation QuestionsSharedManager
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize managedObjectContext;
@synthesize dateFormatterUsed;

+ (QuestionsSharedManager*)sharedManager
{
    if (sharedManager == nil) {
        @synchronized(self) {
            if (sharedManager == nil) {
                sharedManager = [[self alloc] init];
                NSManagedObjectContext *context = ((AppDelegate*)[UIApplication sharedApplication].delegate).managedObjectContext;
                sharedManager.managedObjectContext = context;
                sharedManager.dateFormatterUsed = [[NSDateFormatter alloc] init];
                [sharedManager.dateFormatterUsed setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZZZ"];
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

- (NSArray*)_parseJSONDictionaryArray:(NSArray*)arr context:(NSManagedObjectContext*)context questionType:(QuestionType)type
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (NSDictionary *dict in arr) {
        NSEntityDescription *desc = [NSEntityDescription entityForName:@"Question" inManagedObjectContext:context];
        Question *newQn = [[Question alloc]
                           initWithEntity:desc insertIntoManagedObjectContext:context];
        
        //is_active is YES as default
        if ([dict objectForKey:@"is_active"]) {
            newQn.is_active = [dict objectForKey:@"is_active"];
        }
        
        //is_initial_value is YES as default
        if ([dict objectForKey:@"is_initial_value"]) {
            newQn.is_initial_value = [dict objectForKey:@"is_initial_value"];
        }
        
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
        } 
        
        if (type == kTxtPlusTxt && !newQn.answer_id) {
            validQuestion = NO;
        } else if (type == kTxtPlusPic) {
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
            validQuestion = NO; //question type unknown
        }
        
        if ([dict objectForKey:@"create_timestamp"]) {
            //Special consideration
            NSDate *date = [self.dateFormatterUsed dateFromString:[dict objectForKey:@"create_timestamp"]];
            newQn.create_timestamp = date;
        } else
        {
            newQn.create_timestamp = [NSDate date];
        }
        
        //For now we put invalid question
        if (!validQuestion) {
//            NSLog(@"Detect a invalid question %@", newQn.description);
        }
        
        [array addObject:newQn];
    }
    return array;
}

//When the attributes of QuestionSet updates, update here as well
- (BOOL)_assignValuesToQuestionSetAndSave:(QuestionSet*)set withContext:(NSManagedObjectContext*)context SetID:(NSString*)set_id name:(NSString*)name author:(NSString*)author createDate:(NSDate*)create_date modifyDate:(NSDate*)modifyDate questionType:(NSNumber*)questionType questions:(NSArray*)questions coverImageData:(NSData *)data questionSubtype:(NSNumber*)questionSubtype
{
    // If appropriate, configure the new managed object.
    // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
    [set setValueIfNotNil:create_date forKey:@"create_timestamp"];
    set.create_timestamp = create_date;
    [set setValueIfNotNil:modifyDate forKey:@"modify_timestamp"];
    [set setValueIfNotNil:set_id forKey:@"set_id"];
    [set setValueIfNotNil:name forKey:@"name"];
    [set setValueIfNotNil:author forKey:@"author"];
    [set setValueIfNotNil:questionType forKey:@"question_type"];
    [set setValueIfNotNil:questionSubtype forKey:@"question_subtype"];
    [set setValueIfNotNil:data forKey:@"cover_data"];
    //cover_url not implemented yet
    
    if (questions) {
        [set addQuestions:[NSSet setWithArray:questions]];
        for (Question *question in set.questions) {
            question.belongs_to = set;
        }
    }
    
    // Save the context.
    NSError *error = nil;
    if (![context save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        //TODO notify the user about er1ror
        return NO;
    }
    
    return YES;
}

- (BOOL)_insertNewQuestionSetWithSetID:(NSString*)set_id name:(NSString*)name author:(NSString*)author createDate:(NSDate*)create_date modifyDate:(NSDate*)modifyDate questionType:(NSNumber*)questionType questions:(NSArray*)questions coverImageData:(NSData *)data questionSubtype:(NSNumber*)question_subtype
{
    // Create a new instance of the entity managed by the fetched results controller.
    NSManagedObjectContext *context = self.managedObjectContext;
    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
    QuestionSet *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];

    return [self _assignValuesToQuestionSetAndSave:newManagedObject withContext:context SetID:set_id name:name author:author createDate:create_date modifyDate:modifyDate questionType:questionType questions:questions coverImageData:data questionSubtype:question_subtype];
}

- (BOOL)_parseQuestionSetDictionary:(NSDictionary*)question_set filePath:(NSString*)path fileNameAsSetID:(NSString*)set_id andInsertToCoreDataIfNil:(QuestionSet*)qnSet
{
    if (!set_id) {
        return NO;
    }
    
    NSString *name = [question_set objectForKey:@"name"];
    NSString *author = [question_set objectForKey:@"author"];
    NSNumber *questionType = [question_set objectForKey:@"question_type"];
    NSNumber *questionSubtype = [question_set objectForKey:@"question_subtype"];
    
    if (!questionType) {
        questionType = [NSNumber numberWithInt:kUnknownQuestionType];
        //TODO show error
    }
    
    NSArray *questionRawData = [question_set objectForKey:@"questions"];
    
    //Specicial consideration:
    NSDate *createDate = [self.dateFormatterUsed dateFromString:[question_set objectForKey:@"create_timestamp"]];
    NSDate *modifyDate = [self.dateFormatterUsed dateFromString:[question_set objectForKey:@"modify_timestamp"]];
    if (!createDate) {
        createDate = [NSDate date];
    }
    if (!modifyDate) {
        modifyDate = [NSDate date];
    }
    
    NSString *cover_data_base64_string = [question_set objectForKey:@"cover_data"];
    NSData *cover_data = [NSData dataWithBase64EncodedString:cover_data_base64_string];
    
    NSArray *questions = [self _parseJSONDictionaryArray:questionRawData context:[self.fetchedResultsController managedObjectContext] questionType:[questionType intValue]];
    
    if (!questions) {
        NSLog(@"FAIL TO PARSE QUESTIONS FROM QSJ FILE");
    } else
    {
        
    }
    
    if (!qnSet) {
        return [self _insertNewQuestionSetWithSetID:set_id name:name author:author createDate:createDate modifyDate:modifyDate questionType:questionType questions:questions coverImageData:cover_data questionSubtype:questionSubtype];
    } else
    {
        return [self _assignValuesToQuestionSetAndSave:qnSet withContext:self.managedObjectContext SetID:set_id name:name author:author createDate:createDate modifyDate:modifyDate questionType:questionType questions:questions coverImageData:cover_data questionSubtype:questionSubtype];
    }
    
}

- (BOOL)_parseQSJFileOnPath:(NSString*)path
{
    NSError *error = nil;
    NSString *pathForQuestionSet;
    //Notice that set_id is same as file name, need to choose file name very carefully
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
    
    BOOL success;
    if (!alreadyExists) {
        NSString *jsonStr = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
        NSDictionary *resultDict = [jsonStr objectFromJSONString];
        success = [self _parseQuestionSetDictionary:resultDict filePath:path fileNameAsSetID:set_id andInsertToCoreDataIfNil:nil];
    } else
    {
        NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:&error];
        if ([questionSet.modify_timestamp compare:[attributes objectForKey:NSFileModificationDate]] == NSOrderedSame) {
            //如果时间一样，则跳过插入
            return NO;
        }
        
        //如果set_id已存在，该怎么办？
        //目前方法：set_id后面加时间戳,name加时间戳
        set_id = [set_id stringByAppendingFormat:@"%d", [[NSDate date] timeIntervalSinceReferenceDate]];
        
        NSString *jsonStr = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
        
        NSMutableDictionary *resultDict = [NSMutableDictionary dictionaryWithDictionary:[jsonStr objectFromJSONString]];
        
        //改变name
        NSString *name = [resultDict objectForKey:@"name"];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterShortStyle];
        
        name = [name stringByAppendingString:[formatter stringFromDate:[NSDate date]]];
        [resultDict setObject:name forKey:@"name"];
        
        //Assign dates info to dict to update the questionSet
        [resultDict setValue:[attributes objectForKey:NSFileModificationDate] forKey:@"modify_date"];
        [resultDict setValue:[attributes objectForKey:NSFileCreationDate] forKey:@"create_date"];
        
        success = [self _parseQuestionSetDictionary:resultDict filePath:path fileNameAsSetID:set_id andInsertToCoreDataIfNil:nil];
    }   
    
    return success;
}

- (BOOL)parseQSJFileWithURL:(NSURL*)url
{
    return [self _parseQSJFileOnPath:[url path]];
}

- (void)checkCachedQuestionSetsWithCompletion:(void (^)(BOOL))completion
{
    //Check for existing qsj files to load question set if need
    //这个应该不会再使用了，因为已实现preload数据库： http://www.raywenderlich.com/12170/core-data-tutorial-how-to-preloadimport-existing-data-updated
    
    NSArray *array = [[NSBundle mainBundle] pathsForResourcesOfType:@"qsj" inDirectory:nil];
    for (NSString *path in array) {
        [self _parseQSJFileOnPath:path];
    }
    completion(YES);
}

- (BOOL)insertNewQuestionSet
{
    //Create a unique ID
    NSString *uniqueID = [NSString stringWithFormat:@"user_%@_on_%d", [OpenUDID value], [[NSDate date] timeIntervalSinceReferenceDate]];
    
    NSData *imgData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:QUESTION_SET_DEFAULT_COVER_NAME ofType:@"png"]];
    
    return [self _insertNewQuestionSetWithSetID:uniqueID name:@"我的题库" author:@"用户" createDate:[NSDate date] modifyDate:[NSDate date] questionType:[NSNumber numberWithInt:kUnknownQuestionType] questions:nil coverImageData:imgData questionSubtype:nil];
}

#pragma mark - Serialize Managed objects to NSDitionary

- (id)_parseAttributesHelperWithManagedObject:(NSManagedObject*)object AttributeDescription:(NSAttributeDescription*)attribute theKey:(NSString*)aKey
{
    //For our case, we have NSData, NSDate NSSet needs special considerations
    switch (attribute.attributeType) {
        case NSBinaryDataAttributeType:
        {
            NSData *data = [object valueForKey:aKey];
//            UIImage *img = [UIImage imageWithData:data];
//            if (img) {
//                data = UIImageJPEGRepresentation(img, 0.7);
//            }
            return [data base64EncodingWithLineLength:0];
        }
            break;
        case NSDateAttributeType:
        {
            NSDate *date = [object valueForKey:aKey];
            return date;
        }
            break;
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
            if (filterInActive &&  ![question.is_active boolValue]) {
                continue; //should skip this question
                //TODO for incomplete question
            }
            if (filterIncomplete) {
                if ([set.question_type intValue] == kTxtPlusTxt) {
                    if (!question.question_in_text || !question.answer_in_text) {
                        continue;
                    }
                } else {
                    if (!question.question_in_text || !question.answer_in_image) {
                        continue;
                    }
                }
            }
            NSMutableDictionary *dict = [self jsonCompatitableDictionaryFromQuestion:question];
            [questionsArray addObject:dict];
        }
        
        [result setObjectIfNotNil:questionsArray forKey:@"questions"];
    }
    
    return result;
}

- (NSData*)dataFromJSONParsedQuestionSet:(QuestionSet*)set filterInCompleteQuestion:(BOOL)filterIncomplete filterInActiveQuestions:(BOOL)filterInActive
{
    NSMutableDictionary *dict = [self jsonCompatitableDictionaryFromQuestionSet:set filterInCompleteQuestion:filterIncomplete filterInActiveQuestions:filterInActive];

    NSError *error = nil;
    
    NSData *data = [dict JSONDataWithOptions:JKSerializeOptionNone serializeUnsupportedClassesUsingBlock:^id(id object) 
                    {
                        if([object isKindOfClass:[NSDate class]]) { 
                            return([self.dateFormatterUsed stringFromDate:object]);
                        }
                        return(nil);
                    } error:&error];
    return data;
}
@end
