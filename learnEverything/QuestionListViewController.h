//
//  QuestionListViewController.h
//  learnEverything
//
//  Created by Yuanfeng on 12-06-02.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QuestionSet.h"

@interface QuestionCellType0 : UITableViewCell {
}

@property (nonatomic, strong) IBOutlet UILabel *questionNumber;
@property (nonatomic, strong) IBOutlet UITextField *questionTxtField;
@property (nonatomic, strong) IBOutlet UITextField *ansTxtField;

@end

@interface QuestionCellType1 : UITableViewCell {
}

@property (nonatomic, strong) IBOutlet UILabel *questionNumber;
@property (nonatomic, strong) IBOutlet UITextField *questionTxtField;
@property (nonatomic, strong) IBOutlet UIButton *ansImageBtn;

@end

#import <MessageUI/MFMailComposeViewController.h>

#define QUESTION_TXT_TAG 3332
#define ANS_TXT_TAG 3333
#define ANS_IMG_TAG 3334

@interface QuestionListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, MFMailComposeViewControllerDelegate>
{
    __unsafe_unretained IBOutlet UIView *_table_header_view;
    __unsafe_unretained IBOutlet UITableView *_questionsTableView;
    __unsafe_unretained IBOutlet UITextField *_set_name_txtfield;
    __unsafe_unretained IBOutlet UITextField *_set_author_txtfield;
    __unsafe_unretained IBOutlet UIImageView *_cover_img_view;
    
    NSIndexPath *_indexPathForEditingTextField;

    QuestionSet *_questionSet;
    NSArray *_questions;
    
    __unsafe_unretained IBOutlet UIButton *_questionTypeIndiciator;
    MFMailComposeViewController *_mailComposeVC;
    
    //Choose question type views
    
    IBOutlet UIView *_chooseQnTypeContainer;
    __unsafe_unretained IBOutlet UIButton *_chooseTxtPlusTxt;
    __unsafe_unretained IBOutlet UIButton *_chooseTxtPlusPic;
}

@property (nonatomic, strong) UINib *questionCellNib; 
@property (nonatomic, strong) IBOutlet QuestionCellType0 *questionCellType0;   //Txt Plus Txt
@property (nonatomic, strong) IBOutlet QuestionCellType1 *questionCellType1;   //Txt Plus Pic

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (id)initWithManagedContext:(NSManagedObjectContext*)context andQuestionSet:(QuestionSet*)qs;
- (IBAction)onShareQuestionSetClicked:(id)sender;
- (IBAction)onBackButtonClicked:(id)sender;

@end