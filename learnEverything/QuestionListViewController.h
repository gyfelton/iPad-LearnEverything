//
//  QuestionListViewController.h
//  learnEverything
//
//  Created by Yuanfeng on 12-06-02.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QuestionCell : UITableViewCell {
}

@property (nonatomic, strong) IBOutlet UILabel *questionNumber;
@property (nonatomic, strong) IBOutlet UITextField *questionTxtField;
@property (nonatomic, strong) IBOutlet UITextField *ansTxtField;

@end

#define QUESTION_TXT_TAG 3332
#define ANS_TXT_TAG 3333
@interface QuestionListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate, UITextFieldDelegate>
{
    __unsafe_unretained IBOutlet UIView *_table_header_view;
    __unsafe_unretained IBOutlet UITableView *_questionList;
    
    NSIndexPath *_indexPathForEditingTextField;

    NSString *_questionSetID;
}

@property (nonatomic, strong) UINib *questionCellNib; 
@property (nonatomic, strong) IBOutlet QuestionCell *questionCell;   

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (id)initWithManagedContext:(NSManagedObjectContext*)context andQuestionSetID:(NSString*)set_id;

@end