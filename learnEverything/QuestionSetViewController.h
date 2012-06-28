//
//  QuestionSetViewController.h
//  learnEverything
//
//  Created by Yuanfeng on 12-06-02.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GMGridView.h"
#import "GMGridViewCell.h"

enum QuestionSetViewControllerType {
    kEditQuestionSet = 0,
    kChooseGameSet = 1
    };
typedef enum QuestionSetViewControllerType QuestionSetViewControllerType;

@interface QuestionSetViewController : UIViewController <GMGridViewDataSource, GMGridViewActionDelegate, NSFetchedResultsControllerDelegate>
{
    GMGridView *_questionSetView;
    IBOutlet UIView *_questionSetView_placeholder;
    
    QuestionSetViewControllerType _viewControllerType;
    
    __unsafe_unretained IBOutlet UILabel *_titleLabel;
//    UIButton *_chooseGameModeBtn;
}

- (id)initWithViewControllerType:(QuestionSetViewControllerType)type;
- (IBAction)onBackClicked:(id)sender;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property BOOL isSinglePlayerMode;
@end