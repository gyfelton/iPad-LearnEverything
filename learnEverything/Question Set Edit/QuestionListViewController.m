﻿//
//  QuestionListViewController.m
//  learnEverything
//
//  Created by Yuanfeng on 12-06-02.
//  Copyright (c) 2012 ____Yuanfeng Gao___. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "QuestionsSharedManager.h"
#import "NSData+Base64.h"
#import "QuestionListViewController.h"
#import "QuestionType.h"
#import "Question.h"
#import "JSONKit.h"
#import "UIResponder+InsertText.h"
#import "AppDelegate.h"

@implementation QuestionCellType0
@synthesize ansTxtField, questionNumber,questionTxtField;
@synthesize notSelectedView, selectedView;
@end

@implementation QuestionCellType1
@synthesize ansImageBtn, questionNumber, questionTxtField;
@synthesize notSelectedView, selectedView;
@end

@interface QuestionListViewController (Private) 
- (Question*)questionForIndexPath:(NSIndexPath*)indexPath;
- (void)onCellAnswerImageButtonClicked:(UIButton*)answerBtn;
- (void)configureCellType0:(QuestionCellType0 *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)configureCellType1:(QuestionCellType1 *)cell atIndexPath:(NSIndexPath *)indexPath canLoadImage:(BOOL)canLoad;
- (void)loadDataForOnScreenRows;
@end

@implementation QuestionListViewController
@synthesize type0_questionCell, type1_questionCell, questionCellNib;
@synthesize managedObjectContext;
@synthesize popoverController;

- (id)initWithManagedContext:(NSManagedObjectContext*)context andQuestionSet:(QuestionSet *)qs
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        // Custom initialization
        self.title = @"Edit Problem Set"; //@"编辑题库";
        
        self.managedObjectContext = context;
        _questionSet = qs;
        
        _addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewQuestion)];
        //TODO implement this in the future
        //UIBarButtonItem *undoButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemUndo target:self action:@selector(undoPreviousOp:)];
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
    
    _uthor_lbl.font = _cover_lbl.font = _title_lbl.font = [UIFont regularChineseFontWithSize:29];
    _set_author_txtfield.font = _set_name_txtfield.font = [UIFont regularChineseFontWithSize:38];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 400, 44)];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont regularChineseFontWithSize:26.0];
    label.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    label.textAlignment = UITextAlignmentCenter;
    label.textColor = [UIColor whiteColor]; //[UIColor colorWithRed:0.52f green:0.38f blue:0.11f alpha:1.0f];
    label.text=self.title;  
    self.navigationItem.titleView = label; 
    
    //_header_view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"leather_texture"]];
                                    
    _shouldNotShareUnCheckedQuestion = YES;
    _shouldNotShareIncompleteQuestion = YES;
    
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
        //显示选择题库类型
        _header_img_view.hidden = YES;
        _questionsTableView.hidden = YES;
        
        _chooseQnTypeContainer.frame = _questionsTableView.frame;
        [self.view addSubview:_chooseQnTypeContainer];
        
        [_chooseSubtypeMathQn addTarget:self action:@selector(onChooseQuestionTypeClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_chooseSubtypeChiEng addTarget:self action:@selector(onChooseQuestionTypeClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_chooseSubtypeChiPic addTarget:self action:@selector(onChooseQuestionTypeClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_chooseSubtypeEngPic addTarget:self action:@selector(onChooseQuestionTypeClicked:) forControlEvents:UIControlEventTouchUpInside];
        
    } else
    {
        _header_img_view.hidden = NO;
        
        //Here we will know the subtype for sure
        //[_questionTypeIndiciator setTitle:@"文字＋图片" forState:UIControlStateNormal];
        switch ([_questionSet.question_subtype intValue]) {
            case subtype_MathQuestion:
                _header_img_view.image = [UIImage imageNamed:addSuffixEnglish(@"table_header_calc")];
                break;
            case subtype_ChineseEnglishTranslation:
                _header_img_view.image = [UIImage imageNamed:addSuffixEnglish(@"table_header_ChiEng")];
                break;
            case subtype_ChinesePicture:
                _header_img_view.image = [UIImage imageNamed:addSuffixEnglish(@"table_header_ChiPic")];
                break;
            case subtype_EnglishPicture:
                _header_img_view.image = [UIImage imageNamed:addSuffixEnglish(@"table_header_EngPic")];
                break;
            default:
                _header_img_view.image = [UIImage imageNamed:addSuffixEnglish(@"table_header_calc")];
                break;
        }
        [self.navigationItem setRightBarButtonItem:_addButton];
    }
    
    [_cover_img_view setImage:[UIImage imageWithData:_questionSet.cover_data] forState:UIControlStateNormal];
    
    _set_name_txtfield.returnKeyType = _set_author_txtfield.returnKeyType = UIReturnKeyNext;
}

- (void)viewDidUnload
{
    _questionsTableView = nil;
    
    _chooseQnTypeContainer = nil;
    _chooseSubtypeChiEng = nil;
    _chooseSubtypeChiPic = nil;
    _chooseSubtypeEngPic = nil;
    _chooseSubtypeMathQn = nil;
    
    _header_img_view = nil;
    _title_lbl = nil;
    _uthor_lbl = nil;
    _cover_lbl = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (_activeTextField) {
        [_activeTextField resignFirstResponder];
    }
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell isKindOfClass:[QuestionCellType0 class]] || [cell isKindOfClass:[QuestionCellType1 class]]) {
        Question *qn = [self questionForIndexPath:indexPath];
        if ([cell isKindOfClass:[QuestionCellType0 class]])
        {
            QuestionCellType0 *c = (QuestionCellType0*)cell;
            if ([qn.is_active boolValue])
            {
                c.accessoryView = c.notSelectedView;
                qn.is_active = [NSNumber numberWithBool:NO];
            } else 
            {
                c.accessoryView = c.selectedView;
                qn.is_active = [NSNumber numberWithBool:YES];
            }
        } else
        {
            QuestionCellType1 *c = (QuestionCellType1*)cell;
            if ([qn.is_active boolValue])
            {
                c.accessoryView = c.notSelectedView;
                qn.is_active = [NSNumber numberWithBool:NO];
            } else 
            {
                c.accessoryView = c.selectedView;
                qn.is_active = [NSNumber numberWithBool:YES];
            }
        }
    }
}

#pragma mark - Lazy Loading

- (void)loadDataForOnscreenRows
{
    NSArray *array = [_questionsTableView indexPathsForVisibleRows];
    for (NSIndexPath *indexPath in array) {
        UITableViewCell *cell = [_questionsTableView cellForRowAtIndexPath:indexPath];
        if ([cell isKindOfClass:[QuestionCellType1 class]]) {
            QuestionCellType1 *type1 = (QuestionCellType1*)cell;
            [self configureCellType1:type1 atIndexPath:indexPath canLoadImage:YES];
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        //load images
        [self loadDataForOnscreenRows];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    //load images
    [self loadDataForOnscreenRows];
}

#pragma mark - UITableView DataSource

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return nil; //_table_header_view;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //refresh the new question list
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"create_timestamp" ascending:NO];
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
            cell = self.type0_questionCell;  
            self.type0_questionCell = nil;  
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
            cell = self.type1_questionCell;  
            self.type1_questionCell = nil;  
        }
        cell.questionTxtField.clearButtonMode = UITextFieldViewModeWhileEditing;
        
        cell.questionTxtField.delegate = self;
        cell.questionTxtField.tag = QUESTION_TXT_TAG;
        cell.ansImageBtn.tag = ANS_IMG_TAG;
        
        BOOL canLoadImage = (tableView.dragging == NO && tableView.decelerating == NO);
        
        [self configureCellType1:cell atIndexPath:indexPath canLoadImage:canLoadImage];
        
        return cell;
    }
}

- (Question*)questionForIndexPath:(NSIndexPath *)indexPath
{
    Question *managedObject = [_questions objectAtIndex:indexPath.row];
    return managedObject;
}

- (void)configureCellType0:(QuestionCellType0 *)cell atIndexPath:(NSIndexPath *)indexPath
{
    cell.questionNumber.text = [NSString stringWithFormat:@"%d.", [_questions count] - indexPath.row];
    Question *managedObject = [self questionForIndexPath:indexPath];
    
    cell.questionTxtField.text = managedObject.question_in_text;
    cell.ansTxtField.text = managedObject.answer_in_text;
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if ([managedObject.is_active boolValue]) {
        cell.accessoryView = cell.selectedView;
    } else
    {
        cell.accessoryView = cell.notSelectedView;
    }
    
    cell.questionTxtField.returnKeyType = UIReturnKeyNext;
    cell.ansTxtField.returnKeyType = UIReturnKeyDone;
    
    //Config fonts
    cell.questionNumber.font = [UIFont regularChineseFontWithSize:38];
    cell.questionTxtField.font = cell.ansTxtField.font = [UIFont systemFontOfSize:46];
    
    //config keyboard
    cell.questionTxtField.autocapitalizationType = cell.ansTxtField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    
    if ([_questionSet.question_subtype intValue] == subtype_MathQuestion) {
        cell.questionTxtField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        cell.questionTxtField.inputAccessoryView = _inputAcessoryToolBar;
        cell.ansTxtField.keyboardType = UIKeyboardTypeNumberPad;
        cell.ansTxtField.inputAccessoryView = _inputAcessoryToolBar;
    }
}

//Txt + Pic
- (void)configureCellType1:(QuestionCellType1 *)cell atIndexPath:(NSIndexPath *)indexPath canLoadImage:(BOOL)canLoad
{
    cell.questionNumber.text = [NSString stringWithFormat:@"%d.", [_questions count] - indexPath.row];
    Question *managedObject = [self questionForIndexPath:indexPath];
    
    cell.questionTxtField.text = managedObject.question_in_text;
    
    cell.ansImageBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    NSData *data = managedObject.answer_in_image;
    if (data) {
        if (canLoad) {
            UIImage *image = [UIImage imageWithData:data];
            [cell.ansImageBtn setImage:image forState:UIControlStateNormal];
        } else
        {
            UIImage *img = [UIImage imageNamed:@"question_list_default_pic"];
            [cell.ansImageBtn setImage:img forState:UIControlStateNormal];
        }
    }


    [cell.ansImageBtn addTarget:self action:@selector(onCellAnswerImageButtonClicked:) forControlEvents:UIControlEventTouchDown];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if ([managedObject.is_active boolValue]) {
        cell.accessoryView = cell.selectedView;
    } else
    {
        cell.accessoryView = cell.notSelectedView;
    }
    
    cell.questionTxtField.returnKeyType = UIReturnKeyNext;
    
    cell.questionNumber.font = [UIFont regularChineseFontWithSize:38];
    cell.questionTxtField.font = [UIFont systemFontOfSize:46];
    
    cell.questionTxtField.autocapitalizationType = UITextAutocapitalizationTypeWords;
}

/*
 // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed. 
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
 {
 // In the simplest, most efficient, case, reload the table view.
 [self.tableView reloadData];
 }
 */

- (void)insertNewQuestion
{
    // Create a new instance of the entity managed by the fetched results controller.
    NSManagedObjectContext *context = self.managedObjectContext;
    Question *question = [NSEntityDescription insertNewObjectForEntityForName:@"Question" inManagedObjectContext:context];
    
    // If appropriate, configure the new managed object.
    // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
    [question setValue:[NSDate date] forKey:@"create_timestamp"];

//    question.question_in_text = [NSString stringWithFormat:@" = ?"];
    
    question.is_initial_value = [NSNumber numberWithBool:YES];
    question.is_active = [NSNumber numberWithBool:NO];
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
        //Animate the insertion (insert at top)
        NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:0/*[_questions count]*/ inSection:0];
        //Need to update the indexPath being tracked right now
        [_questionsTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [_questionsTableView scrollToRowAtIndexPath:newIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        if (_indexPathForEditingImage)
        {
            _indexPathForEditingImage = [NSIndexPath indexPathForRow:_indexPathForEditingImage.row+1 inSection:_indexPathForEditingImage.section];
        }
        if (_indexPathForEditingTextField) {
            _indexPathForEditingTextField = [NSIndexPath indexPathForRow:_indexPathForEditingTextField.row+1 inSection:_indexPathForEditingTextField.section];
        }
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
    _activeTextField = textField;
    
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
//        NSLog(@"did end editing %@", _indexPathForEditingTextField.description);
        
        Question *question = [self questionForIndexPath:_indexPathForEditingTextField];
        
        question.is_initial_value = [NSNumber numberWithBool:NO];

        if (textField.tag == QUESTION_TXT_TAG) {
            question.question_in_text = textField.text;
        } else if (textField.tag == ANS_TXT_TAG) {
            
            question.answer_in_text = textField.text;
            question.answer_id = textField.text;
            
            if (question.question_in_text) {
                question.is_active = [NSNumber numberWithBool:YES];
                [_questionsTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:_indexPathForEditingTextField] withRowAnimation:UITableViewRowAnimationNone];
            }
        }
        _indexPathForEditingTextField = nil;
    }
}

- (void)activateNextCellQuestionTextField:(NSIndexPath*)currentIndexPath
                                           
{
    NSIndexPath *nextIndexPath = [NSIndexPath indexPathForRow:currentIndexPath.row+1 inSection:currentIndexPath.section];
    UITableViewCell *cell = [_questionsTableView cellForRowAtIndexPath:nextIndexPath];
    if (cell) {
        
        CGRect rect = [_questionsTableView rectForRowAtIndexPath:nextIndexPath];
//        [_questionsTableView scrollToRowAtIndexPath:nextIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        [_questionsTableView scrollRectToVisible:rect animated:YES];
        
        if ([cell isKindOfClass:[QuestionCellType0 class]]) {
            [((QuestionCellType0*)cell).questionTxtField becomeFirstResponder];
        } else if ([cell isKindOfClass:[QuestionCellType1 class]]) {
            [((QuestionCellType1*)cell).questionTxtField becomeFirstResponder];
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _set_name_txtfield) {
        [_set_author_txtfield becomeFirstResponder];
    } else if (textField == _set_author_txtfield ) {
        [_set_author_txtfield resignFirstResponder];
        [self onCoverClicked:_cover_img_view];
    } else
    {
        if (_indexPathForEditingTextField) {
            if (textField.tag == QUESTION_TXT_TAG) {
                UITableViewCell *cell = [_questionsTableView cellForRowAtIndexPath:_indexPathForEditingTextField];
                if ([cell isKindOfClass:[QuestionCellType0 class]]) {
                    [((QuestionCellType0*)cell).ansTxtField becomeFirstResponder];
                } else if ([cell isKindOfClass:[QuestionCellType1 class]]) {
                    [textField resignFirstResponder];
                    [self onCellAnswerImageButtonClicked:((QuestionCellType1*)cell).ansImageBtn];
                }
            } else if (textField.tag == ANS_TXT_TAG)
            {
                //try to find next question's question textField
                [self activateNextCellQuestionTextField:_indexPathForEditingTextField];
            }
        }
    }
    return NO;
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
- (void)dismissActionSheet:(UIActionSheet*)sheet
{
    [sheet dismissWithClickedButtonIndex:0 animated:YES];
}

- (void)onChooseQuestionTypeClicked:(UIButton*)btn
{
    if (btn == _chooseSubtypeMathQn) {
        _questionSet.question_type = [NSNumber numberWithInt:kTxtPlusTxt];
        _questionSet.question_subtype = [NSNumber numberWithInt:subtype_MathQuestion];
        _questionsTableView.hidden = NO;
        _header_img_view.image = [UIImage imageNamed:addSuffixEnglish(@"table_header_calc")];
    } 
    if (btn == _chooseSubtypeChiEng)
    {
        _questionSet.question_type = [NSNumber numberWithInt:kTxtPlusTxt];
        _questionsTableView.hidden = NO;
        _questionSet.question_subtype = [NSNumber numberWithInt:subtype_ChineseEnglishTranslation];
        _header_img_view.image = [UIImage imageNamed:addSuffixEnglish(@"table_header_ChiEng")];
    }
    if (btn == _chooseSubtypeChiPic) {
        _questionSet.question_type = [NSNumber numberWithInt:kTxtPlusPic];
        _questionsTableView.hidden = NO;
        _questionSet.question_subtype = [NSNumber numberWithInt:subtype_ChinesePicture];
        _header_img_view.image = [UIImage imageNamed:addSuffixEnglish(@"table_header_ChiPic")];
    }
    if (btn == _chooseSubtypeEngPic) {
        _questionSet.question_type = [NSNumber numberWithInt:kTxtPlusPic];
        _questionsTableView.hidden = NO;
        _questionSet.question_subtype = [NSNumber numberWithInt:subtype_EnglishPicture];
        _header_img_view.image = [UIImage imageNamed:addSuffixEnglish(@"table_header_EngPic")];
    }
    
    _header_img_view.hidden = NO;
    [_chooseQnTypeContainer removeFromSuperview];
    [_questionsTableView reloadData];
    
    [self.navigationItem setRightBarButtonItem:_addButton];
    UIActionSheet *temp = [[UIActionSheet alloc] initWithTitle:nil delegate:nil cancelButtonTitle:nil destructiveButtonTitle:@"Click the + button above to insert a new question" otherButtonTitles:nil]; //@"点击上面的加号添加第一道题目"
    [temp showFromBarButtonItem:_addButton animated:YES];
    [self performSelector:@selector(dismissActionSheet:) withObject:temp afterDelay:1.2f];
    
    //新建题库时干脆先插入一题目
    [self insertNewQuestion];
}

- (IBAction)onShareQuestionSetClicked:(id)sender {
    if (![MFMailComposeViewController canSendMail]) {
        if (!_setMailAlert)
        {
			_setMailAlert = [[UIAlertView alloc] initWithTitle:@"You have not set up any mail account yet." message:@"To share the problem set, you need to set up an email account. Click \"Set up Account\" to continue." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Set Up Mail Account", nil];
            //_setMailAlert = [[UIAlertView alloc] initWithTitle:@"还没有设置邮件帐户吧" message:@"要分享你的题库，你需要设置你的邮箱，点击“设置邮箱”进行设置" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"设置邮件帐户", nil];
        }
        [_setMailAlert show];
        return;
    }
    
    ShareOptionsTableViewController *options = [[ShareOptionsTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    options.customDelegate = self;
    self.popoverController = [[UIPopoverController alloc] initWithContentViewController:options];
    self.popoverController.popoverContentSize = CGSizeMake(400, 220); //320
    [self.popoverController presentPopoverFromRect:((UIButton*)sender).frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
}

- (IBAction)onCoverClicked:(id)sender {
    UIButton *cover = (UIButton*)sender;
    
    if (!_actionSheetForCover) {
		_actionSheetForCover= [[UIActionSheet alloc] initWithTitle:@"Modify Cover\nPlease select a image source:" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Web Image Search", @"Camera", @"Photo Album",nil];
        //_actionSheetForCover= [[UIActionSheet alloc] initWithTitle:@"修改封面\n请选择图片来源：" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"网络图片搜索", @"照相机", @"相册",nil];
    }
    [_actionSheetForCover showFromRect:cover.frame inView:self.view animated:YES];
}

- (void)onCellAnswerImageButtonClicked:(UIButton*)answerBtn
{
    [_activeTextField resignFirstResponder];
    QuestionCellType1 *cell = (QuestionCellType1*)answerBtn.superview.superview;
    if ([cell isKindOfClass:[QuestionCellType1 class]]) {
        if (false) {//(_indexPathForEditingImage && [_indexPathForEditingImage compare:[_questionsTableView indexPathForCell:cell]] == NSOrderedSame && !self.popoverController.isPopoverVisible && self.popoverController) {
            //如果点的是相同的cell，把前面的VC再展示遍 (目前这个功能不行）
//            [self.popoverController presentPopoverFromRect:answerBtn.frame inView:cell permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        } else
        {
            //Prepare for new popOver VC
            self.popoverController = nil;
            _indexPathForEditingImage = [_questionsTableView indexPathForCell:cell];
            if (!_actionSheetForImageBtn) {
				_actionSheetForImageBtn = [[UIActionSheet alloc] initWithTitle:@"Please select a image source:" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Web Image Search", @"Camera", @"Photo Album",nil];
                //_actionSheetForImageBtn = [[UIActionSheet alloc] initWithTitle:@"请选择图片来源：" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"网络图片搜索", @"照相机", @"相册",nil];
            }
            [_actionSheetForImageBtn showFromRect:answerBtn.frame inView:cell animated:YES]; 
        }
    }
}

#pragma mark - MFMailCompose Delegate
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    if (result == MFMailComposeResultSent) {
        [appDelegate showMailHUD:YES];
    } else if (result ==  MFMailComposeResultFailed)
    {
        [appDelegate showMailHUD:NO];
    }
    [_mailComposeVC dismissModalViewControllerAnimated:YES];
}

#pragma mark - UIActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    _activeActionSheet = actionSheet;
    CGRect rectForPopover;
    UIView *viewForPopover;
    UIPopoverArrowDirection direction;
    
    NSString *searchQuery = nil;
    if (_activeActionSheet == _actionSheetForCover) {
        rectForPopover = _cover_img_view.frame;
        viewForPopover = self.view;
        direction = UIPopoverArrowDirectionLeft;
        searchQuery = _questionSet.name;
    } else
    {
        QuestionCellType1 *cell = (QuestionCellType1*)[_questionsTableView cellForRowAtIndexPath:_indexPathForEditingImage];
        rectForPopover = cell.ansImageBtn.frame;
        viewForPopover = cell;
        direction = UIPopoverArrowDirectionAny;
        Question *qn = [self questionForIndexPath:_indexPathForEditingImage];
        searchQuery = qn.question_in_text;
    }
    
    switch (buttonIndex) {
        case 0:
            //Bing Image Search
        {
            ImageSearchViewController *imgSearchVC = [[ImageSearchViewController alloc] initWithSearchStringArray:[NSArray arrayWithObjects:searchQuery, nil] delegate:self];
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:imgSearchVC];
            
            UIPopoverController *popOver = [[UIPopoverController alloc] initWithContentViewController:nav]; 
            self.popoverController = popOver;
            self.popoverController.popoverContentSize = CGSizeMake(420, 670);
            [self.popoverController presentPopoverFromRect:rectForPopover inView:viewForPopover permittedArrowDirections:direction animated:YES];
        }
            break;
        case 1:
        case 2:
        {
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            if (buttonIndex == 1 && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            } else
            {
                picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            }
            picker.delegate = (id)self;
            picker.allowsEditing = NO;
            UIPopoverController *popOver = [[UIPopoverController alloc] initWithContentViewController:picker];
            popOver.delegate = (id)self;
            
            self.popoverController = popOver;
            [self.popoverController presentPopoverFromRect:rectForPopover inView:viewForPopover permittedArrowDirections:direction animated:YES];
        }
            break;
        default:
            break;
    }
}

#pragma mark - PhotoEditingViewController Delegate
- (void)PhotoEditingVC:(PhotoEditingViewController *)vc didFinishCropWithOriginalImage:(UIImage *)originalImg editedImage:(UIImage *)editedImg
{
    if (_activeActionSheet == _actionSheetForCover) {
        [UIView beginAnimations:@"transition" context:NULL];
        [UIView setAnimationDuration:0.5f];
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:_cover_img_view cache:YES];
        [_cover_img_view setImage:editedImg forState:UIControlStateNormal];
        _cover_img_view.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [UIView commitAnimations];
        
        //cover_url should not be used
        _questionSet.cover_data = UIImagePNGRepresentation(editedImg);
    } else
    {
        QuestionCellType1 *cell = (QuestionCellType1*)[_questionsTableView cellForRowAtIndexPath:_indexPathForEditingImage];
        [cell.ansImageBtn setImage:editedImg forState:UIControlStateNormal];
        cell.ansImageBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
        Question *qn = [self questionForIndexPath:_indexPathForEditingImage];
        qn.answer_in_image = UIImageJPEGRepresentation(editedImg, 0.8);
        
        if (qn.question_in_text) {
            qn.is_active = [NSNumber numberWithBool:YES];
            cell.accessoryView = cell.selectedView;
        }
        [self activateNextCellQuestionTextField:_indexPathForEditingImage];
    }

    [self.popoverController dismissPopoverAnimated:YES];
    self.popoverController = nil;
}

#pragma mark - UIImagePicker delegate

- (void)imagePickerController:(id/*Either UIImagePickerController or ImageSearchVC*/)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //For answer image, it's 3:2
    BOOL is3To4 = _activeActionSheet == _actionSheetForCover ? YES : NO;
    
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    if (image) {
        PhotoEditingViewController *photoEditingVC = [[PhotoEditingViewController alloc] initWithImage:image using3To4Ratio:is3To4];
        photoEditingVC.delegate = self;
        //        [self.popOverController dismissPopoverAnimated:YES];
        //        if ([picker isKindOfClass:[UIImagePickerController class]]) {
        //            [(UIImagePickerController*)picker pushViewController:photoEditingVC animated:YES];
        //        } else if ([picker isKindOfClass:[ImageSearchWebViewController class]])
        //        {
        //            [((ImageSearchWebViewController*)picker).navigationController pushViewController:photoEditingVC animated:YES];
        //        }
        //Have to use this to do the presentation or things can be wrong again
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:photoEditingVC];
        self.popoverController.delegate = self;
        [self.popoverController setPopoverContentSize:CGSizeMake(480, 517)];
        [self.popoverController setContentViewController:nav animated:YES];
    }
}

#pragma mark - UIPopoverController Delegate
- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController
{
    return YES;
}

#pragma mark - UIAlertView Delegate
// Launches the Mail application on the device.
-(void)launchMailAppOnDevice
{
    NSString *recipients = @"mailto:example@example.com?subject=Hello from California!";
    NSString *body = @"&body=Please switch back to App to continue share problem set."; //@"&body=请跳回到“勇者斗恶龙”继续分享题库^_^”";
    
    NSString *email = [NSString stringWithFormat:@"%@%@", recipients, body];
    email = [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (_setMailAlert) {
        if (buttonIndex == 1) {
            //Jump to mail
            [self launchMailAppOnDevice];
        }
    }
}

#pragma mark - Share Option Delegate
- (BOOL)isSwitchOnOnRow:(NSInteger)row
{
    if (row == 0) {
        return _shouldNotShareIncompleteQuestion;
    } else
    {
        return _shouldNotShareUnCheckedQuestion;
    }
}

- (void)didToggleSwitchOnRow:(NSInteger)row isOn:(BOOL)on
{
    if (row == 0) {
        _shouldNotShareIncompleteQuestion = on;
    } else
    {
        _shouldNotShareUnCheckedQuestion = on;
    }
}

- (void)prepareDataAndShowMailComposer
{
    if ([MFMailComposeViewController canSendMail]) {
        _mailComposeVC = [[MFMailComposeViewController alloc] init];
        
        [_mailComposeVC setSubject:[NSString stringWithFormat:@"Problem set %@ shared by %@", _questionSet.name, _questionSet.author]];
        [_mailComposeVC setMessageBody:[NSString stringWithFormat:@"Attached is a problem set, please open it in %@:", APP_NAME] isHTML:NO];
        
        //[_mailComposeVC setSubject:[NSString stringWithFormat:@"由“勇者斗恶龙”分享的题库：%@", _questionSet.name]];
        //[_mailComposeVC setMessageBody:@"附件是一个题库，请下载后使用 “勇者斗恶龙” 打开\n\nApp Store下载点这里:" isHTML:NO];
        
        NSData *data = [[QuestionsSharedManager sharedManager] dataFromJSONParsedQuestionSet:_questionSet filterInCompleteQuestion:_shouldNotShareIncompleteQuestion filterInActiveQuestions:_shouldNotShareUnCheckedQuestion];
        NSString *fileName = [_questionSet.set_id stringByAppendingString:@".qsj"];
        [_mailComposeVC addAttachmentData:data mimeType:@"application/x-qsj" fileName:fileName];
        _mailComposeVC.mailComposeDelegate = self;
        [self presentModalViewController:_mailComposeVC animated:YES];
    }
    
    [self.popoverController dismissPopoverAnimated:NO];
}

- (void)didSelectCellOnIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section != 1) {
        return;
    }
    
    [self performSelector:@selector(prepareDataAndShowMailComposer) withObject:nil afterDelay:0.1f];
}

#pragma mark - Operation Signs

- (IBAction)onPlusClicked:(id)sender
{
    if (_activeTextField) {
        [_activeTextField insertText:@"+"];
    }
}

- (IBAction)onMinusClicked:(id)sender
{
    if (_activeTextField) {
        [_activeTextField insertText:@"-"];
    }
}

- (IBAction)onMultiplyClicked:(id)sender
{
    if (_activeTextField) {
        [_activeTextField insertText:@"×"];
    }
}

- (IBAction)onQuestionSignClicked:(id)sender {
    if (_activeTextField) {
        [_activeTextField insertText:@"?"];
    }
}

- (IBAction)onDivisionClicked:(id)sender
{
    if (_activeTextField) {
        [_activeTextField insertText:@"÷"];
    }
}

- (IBAction)onEqualQuestionSignClicked:(id)sender {
    if (_activeTextField) {
        [_activeTextField insertText:@"= ?"];
    }
}

- (IBAction)onEqualSignClicked:(id)sender
{
    if (_activeTextField) {
        [_activeTextField insertText:@"="];
    }
}

- (IBAction)onLeftBraketClicked:(id)sender
{
    if (_activeTextField) {
        [_activeTextField insertText:@"("];
    }
}

- (IBAction)onRightBraketClicked:(id)sender
{
    if (_activeTextField) {
        [_activeTextField insertText:@")"];
    }
}

@end

