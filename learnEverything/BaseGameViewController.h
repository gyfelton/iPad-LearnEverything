//
//  BaseGameViewController.h
//  learnEverything
//
//  Created by Yuanfeng on 12-06-05.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Question.h"

@interface BaseGameViewController : UIViewController

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (NSMutableArray*)allQuestions;

- (IBAction)onMenuClicked:(id)sender;

@end
