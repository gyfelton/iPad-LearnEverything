//
//  FileIOSharedManager.m
//  learnEverything
//
//  Created by Yuanfeng on 12-07-03.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FileIOSharedManager.h"
#import "NSData+Base64.h"

@interface NSMutableDictionary (Additionals)
- (void)setObjectIfNotNil:(id)obj forKey:(NSString*)key;
@end
    
@implementation NSMutableDictionary (Additionals)
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

+ (FileIOSharedManager*)sharedManager
{
    if (sharedManager == nil) {
        @synchronized(self) {
            if (sharedManager == nil) {
                sharedManager = [[self alloc] init];
            }
        }
    }
    return sharedManager;
}

- (id)parseAttributesHelperWithManagedObject:(NSManagedObject*)object AttributeDescription:(NSAttributeDescription*)attribute theKey:(NSString*)aKey
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
        id objectToPut = [self parseAttributesHelperWithManagedObject:question AttributeDescription:[attributesByName objectForKey:aKey] theKey:aKey];
        [result setObjectIfNotNil:objectToPut forKey:aKey];
    }
    return result;
}

- (NSMutableDictionary*)jsonCompatitableDictionaryFromQuestionSet:(QuestionSet*)set filterInCompleteQuestion:(BOOL)filterIncomplete filterInActiveQuestions:(BOOL)filterInActive
{
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
     NSDictionary *attributesByName = [[set entity] attributesByName];
    for (NSString *aKey in [attributesByName allKeys]) {
        id objectToPut = [self parseAttributesHelperWithManagedObject:set AttributeDescription:[attributesByName objectForKey:aKey] theKey:aKey];
        [result setObjectIfNotNil:objectToPut forKey:aKey];
    }
    
    NSMutableArray *questionsArray = [[NSMutableArray alloc] initWithCapacity:[set.questions count]];
    //Special: deal with questions, a relationship
    for (Question* question in set.questions)
    {
        if (filterInActive &&  !question.is_active) {
            continue; //should skip this question
        }
        NSMutableDictionary *dict = [self jsonCompatitableDictionaryFromQuestion:question];
        [questionsArray addObject:dict];
    }
    
    [result setObjectIfNotNil:questionsArray forKey:@"question"];
    
    return result;
}

@end
