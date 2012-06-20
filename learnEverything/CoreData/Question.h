//
//  Question.h
//  learnEverything
//
//  Created by Yuanfeng on 12-06-02.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Question : NSManagedObject

@property (nonatomic, retain) NSString * answer_in_text;
@property (nonatomic, retain) NSString * question_in_text;
@property (nonatomic, retain) NSDate * create_timestamp;
@property (nonatomic, retain) NSNumber * is_initial_value;
@end
