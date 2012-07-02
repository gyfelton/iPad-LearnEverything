//
//  QuestionListViewController.m
//  learnEverything
//
//  Created by Yuanfeng on 12-06-02.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "QuestionListViewController.h"
#import "QuestionType.h"
#import "Question.h"

@implementation QuestionCellType0
@synthesize ansTxtField, questionNumber,questionTxtField;
@end

@implementation QuestionCellType1
@synthesize ansImageBtn, questionNumber, questionTxtField;
@end

@interface QuestionListViewController (Private) 
- (void)configureCellType0:(QuestionCellType0 *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)configureCellType1:(QuestionCellType1 *)cell atIndexPath:(NSIndexPath *)indexPath;
@end

@implementation QuestionListViewController
@synthesize questionCellType0, questionCellType1, questionCellNib;
@synthesize managedObjectContext;

- (id)initWithManagedContext:(NSManagedObjectContext*)context andQuestionSet:(QuestionSet *)qs
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        // Custom initialization
        self.title = @"编辑题库";
        
        self.managedObjectContext = context;
        _questionSet = qs;
        
        UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject)];
        //TODO implement this in the future
        //UIBarButtonItem *undoButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemUndo target:self action:@selector(undoPreviousOp:)];
        self.navigationItem.rightBarButtonItem = addButton;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //Init question cell from nib
    self.questionCellNib = [UINib nibWithNibName:@"QuestionCell" bundle:nil];
    
    _set_name_txtfield.text = _questionSet.name;
    _set_author_txtfield.text = _questionSet.author;
    
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 5.0f) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyBoardHeightChange:) name:UIKeyboardDidChangeFrameNotification object:nil];
    } else
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyBoardHeightChange:) name:UIKeyboardDidShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyBoardHeightChange:) name:UIKeyboardDidHideNotification object:nil];
    }
    
    //Hide table if quesition type is unknown
    if ([_questionSet.question_type intValue] == kUnknownQuestionType) {
        _questionsTableView.hidden = YES;
        _chooseQnTypeContainer.frame = _questionsTableView.frame;
        [self.view addSubview:_chooseQnTypeContainer];
        
        [_chooseTxtPlusTxt addTarget:self action:@selector(onChooseQuestionTypeClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_chooseTxtPlusPic addTarget:self action:@selector(onChooseQuestionTypeClicked:) forControlEvents:UIControlEventTouchUpInside];
    } else
    {
        if ([_questionSet.question_type intValue] == kTxtPlusTxt) {
            [_questionTypeIndiciator setTitle:@"文字＋文字" forState:UIControlStateNormal];
        } else
        {
            [_questionTypeIndiciator setTitle:@"文字＋图片" forState:UIControlStateNormal];
        }
    }
    
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)viewDidUnload
{
    _table_header_view = nil;
    _questionsTableView = nil;
    _chooseQnTypeContainer = nil;
    _chooseTxtPlusTxt = nil;
    _chooseTxtPlusPic = nil;
    _questionTypeIndiciator = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return LANDSCAPE_ORIENTATION;
}

#pragma mark - UITableView Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch ([_questionSet.question_type intValue]) {
        case kUnknownQuestionType:
        case kTxtPlusTxt:   
            return 82;
            break;
        case kTxtPlusPic:
            return 120;
            break;
        default:
            break;
    }
    return 44;
}

#pragma mark - UITableView DataSource
// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return _table_header_view;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //refresh the new question list
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"create_timestamp" ascending:YES];
    _questions = [_questionSet.questions sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    return [_questions count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_questionSet.question_type intValue] == kTxtPlusTxt || [_questionSet.question_type intValue] == kUnknownQuestionType) {
        static NSString *questionCellType0ReuseID = @"questionCellType0ReuseID";
        QuestionCellType0 *cell = [tableView dequeueReusableCellWithIdentifier:questionCellType0ReuseID];
        if (!cell) {
            [self.questionCellNib instantiateWithOwner:self options:nil];  
            cell = questionCellType0;  
            self.questionCellType0 = nil;  
        }
        cell.ansTxtField.clearButtonMode = UITextFieldViewModeWhileEditing;
        cell.questionTxtField.clearButtonMode = UITextFieldViewModeWhileEditing;
        
        cell.questionTxtField.delegate = self;
        cell.questionTxtField.tag = QUESTION_TXT_TAG;
        cell.ansTxtField.tag = ANS_TXT_TAG;
        cell.ansTxtField.delegate = self;
        
        [self configureCellType0:cell atIndexPath:indexPath];
        
        return cell;
    } else
    {
    static NSString *questionCellType1ReuseID = @"questionCellType1ReuseID";
    QuestionCellType1 *cell = [tableView dequeueReusableCellWithIdentifier:questionCellType1ReuseID];
    if (!cell) {
        [self.questionCellNib instantiateWithOwner:self options:nil];  
        cell = questionCellType1;  
        self.questionCellType1 = nil;  
    }
    cell.questionTxtField.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    cell.questionTxtField.delegate = self;
    cell.questionTxtField.tag = QUESTION_TXT_TAG;
    cell.ansImageBtn.tag = ANS_IMG_TAG;
    
    [self configureCellType1:cell atIndexPath:indexPath];
    
    return cell;
    }
}

/*
#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    //If exists, just return it
    if (__fetchedResultsController != nil) {
        return __fetchedResultsController;
    }
    
    // Set up the fetched results controller.
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Question" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate
                              predicateWithFormat:@"ANY belongs_to.set_id like %@",
                              _questionSetID];
    //[fetchRequest setPredicate:predicate];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate. (Not applicable)
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"create_timestamp" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"QuestionList"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    NSArray *arr = [self.fetchedResultsController fetchedObjects];
    return __fetchedResultsController;
}    


- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [_questionList beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [_questionList insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [_questionList deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = _questionList;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:(QuestionCell*)[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [_questionList endUpdates];
}
*/

- (void)configureCellType0:(QuestionCellType0 *)cell atIndexPath:(NSIndexPath *)indexPath
{
    cell.questionNumber.text = [NSString stringWithFormat:@"%d.", indexPath.row+1];
    Question *managedObject = [_questions objectAtIndex:indexPath.row];
    
    NSLog(@"set_id %@", managedObject.belongs_to.set_id);
    if ([managedObject.is_initial_value boolValue]) {
        cell.questionTxtField.placeholder = managedObject.question_in_text;
        cell.ansTxtField.placeholder = managedObject.answer_in_text;
    } else
    {
        cell.questionTxtField.text = managedObject.question_in_text;
        cell.ansTxtField.text = managedObject.answer_in_text;
    }
}

- (void)configureCellType1:(QuestionCellType1 *)cell atIndexPath:(NSIndexPath *)indexPath
{
    cell.questionNumber.text = [NSString stringWithFormat:@"%d.", indexPath.row+1];
    Question *managedObject = [_questions objectAtIndex:indexPath.row];
    
    NSLog(@"set_id %@", managedObject.belongs_to.set_id);
    if ([managedObject.is_initial_value boolValue]) {
        cell.questionTxtField.placeholder = managedObject.question_in_text;
        //TODO give placeholder for image
    } else
    {
        cell.questionTxtField.text = managedObject.question_in_text;
        //TODO assign image to answer image
    }
}
/*
 // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed. 
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
 {
 // In the simplest, most efficient, case, reload the table view.
 [self.tableView reloadData];
 }
 */

- (void)insertNewObject
{
    // Create a new instance of the entity managed by the fetched results controller.
    NSManagedObjectContext *context = self.managedObjectContext;
    Question *question = [NSEntityDescription insertNewObjectForEntityForName:@"Question" inManagedObjectContext:context];
    
    // If appropriate, configure the new managed object.
    // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
    [question setValue:[NSDate date] forKey:@"create_timestamp"];
    //set default value here
    NSInteger numOfRow = [_questionsTableView numberOfRowsInSection:0];
    question.question_in_text = [NSString stringWithFormat:@"1 + %d = ?", numOfRow+1];
    question.answer_in_text = [NSString stringWithFormat:@"%d", numOfRow+2];
    question.is_initial_value = [NSNumber numberWithBool:YES];
    question.belongs_to = _questionSet;
    
    // Save the context.
    NSError *error = nil;
    if (![context save:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    } else
    {
        //Animate the insertion
        [_questionsTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:[_questions count] inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

//- (void)undoPreviousOp:(id)sender
//{
//    //Not working
//    NSUndoManager *manager = self.fetchedResultsController.managedObjectContext.undoManager;
//    BOOL canUndo = manager.canUndo;
//    [self.fetchedResultsController.managedObjectContext.undoManager undo];
//}

#pragma mark - UITextField Delegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    id cell = textField.superview.superview;
    if ([cell isKindOfClass:[UITableViewCell class]]) {
        _indexPathForEditingTextField = [_questionsTableView indexPathForCell:cell];
    } else
    {
        
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == _set_name_txtfield) {
        _questionSet.name = textField.text;
    } else if (textField == _set_author_txtfield) {
        _questionSet.author = textField.text;
    } else if (_indexPathForEditingTextField) {
        NSLog(@"did end editing %@", _indexPathForEditingTextField.description);
        
        Question *question = [_questions objectAtIndex:_indexPathForEditingTextField.row];
        
        question.is_initial_value = [NSNumber numberWithBool:NO];
        
        if (textField.tag == QUESTION_TXT_TAG) {
            question.question_in_text = textField.text;
        } else if (textField.tag == ANS_TXT_TAG) {
            question.answer_in_text = textField.text;
        }
        _indexPathForEditingTextField = nil;
    }
}

#pragma mark - NSNotifications

- (void)onKeyBoardHeightChange:(NSNotification *)notification
{
    CGRect keyboardFrame;
    [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardFrame];
    
    CGRect realKeyboardFrame = [self.view convertRect:keyboardFrame toView:nil];
    //CGRect keyBoardRect = keyHeightValues 
    //TODO here we only take care of lanscape mode, need to consider portrait mode or other types of keyboard if possible
    _questionsTableView.contentInset = UIEdgeInsetsMake(0, 0, realKeyboardFrame.origin.y>=0? realKeyboardFrame.size.height : 0, 0);
    
    if (_indexPathForEditingTextField) {
        [_questionsTableView scrollRectToVisible:[_questionsTableView rectForRowAtIndexPath:_indexPathForEditingTextField] animated:YES];
    }
}

#pragma mark - IBActions
- (void)onChooseQuestionTypeClicked:(UIButton*)btn
{
    if (btn == _chooseTxtPlusTxt) {
        [_chooseQnTypeContainer removeFromSuperview];
        _questionSet.question_type = [NSNumber numberWithInt:kTxtPlusTxt];
        _questionsTableView.hidden = NO;
        [_questionsTableView reloadData];
        [_questionTypeIndiciator setTitle:@"文字＋文字" forState:UIControlStateNormal];
    } else
    {
        //Txt Plus Pic
        [_chooseQnTypeContainer removeFromSuperview];
        _questionSet.question_type = [NSNumber numberWithInt:kTxtPlusPic];
        _questionsTableView.hidden = NO;
        [_questionsTableView reloadData];
        [_questionTypeIndiciator setTitle:@"文字＋图片" forState:UIControlStateNormal];
    }
}

- (IBAction)onShareQuestionSetClicked:(id)sender {
    if ([MFMailComposeViewController canSendMail]) {
        _mailComposeVC = [[MFMailComposeViewController alloc] init];
        [_mailComposeVC setSubject:@"题库名"];
        [_mailComposeVC setMessageBody:@"这是一个题库，请使用 xxx 打开" isHTML:NO];
        NSArray *array = [[NSBundle mainBundle] pathsForResourcesOfType:@"qsj" inDirectory:nil];
        NSString *path = [array lastObject];
        NSData *data = [NSData dataWithContentsOfFile:path];
        [_mailComposeVC addAttachmentData:data mimeType:@"application/x-qsj" fileName:@"test.qsj"];
        _mailComposeVC.mailComposeDelegate = self;
        [self presentModalViewController:_mailComposeVC animated:YES];
    } else
    {
        //TODO
    }    
}

- (IBAction)onBackButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - MFMailCompose Delegate
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [_mailComposeVC dismissModalViewControllerAnimated:YES];
    //TODO react according to mail send result?
}
@end

