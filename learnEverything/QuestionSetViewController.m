//
//  QuestionSetViewController.m
//  learnEverything
//
//  Created by Yuanfeng on 12-06-02.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "QuestionSetViewController.h"
#import "QuestionSet.h"
#import "Question+Helpers.h"
#import "NSManagedObject+Helpers.h"
#import "OpenUDID.h"
#import "JSONKit.h"
#import "QuestionListViewController.h"
#import "AppDelegate.h"

@interface QuestionSetViewController (Private) 
- (void)configureCell:(GMGridViewCell *)cell atIndex:(NSInteger)index;
- (BOOL)_assignValuesToQuestionSetAndSave:(QuestionSet*)set withContext:(NSManagedObjectContext*)context SetID:(NSString*)set_id name:(NSString*)name author:(NSString*)author createDate:(NSDate*)create_date modifyDate:(NSDate*)modifyDate questions:(NSArray*)questions;
- (BOOL)_parseQuestionSetDictionary:(NSDictionary*)question_set filePath:(NSString*)path fileNameAsSetID:(NSString*)set_id andInsertToCoreDataIfNil:(QuestionSet*)qnSet;
- (BOOL)insertNewObjectWithSetID:(NSString*)set_id name:(NSString*)name author:(NSString*)author createDate:(NSDate*)create_date modifyDate:(NSDate*)modifyDate questions:(NSArray*)questions;
- (BOOL)insertNewObject;
@end

@implementation QuestionSetViewController
@synthesize managedObjectContext;
@synthesize fetchedResultsController = __fetchedResultsController;
@synthesize isSinglePlayerMode;

#define NUM_FOR_ADD_BUTTON 1

- (id)initWithViewControllerType:(QuestionSetViewControllerType)type
{
    self = [super initWithNibName:nil bundle:nil];
    
    if (self) {
        // Custom initialization
        _viewControllerType = type;
        self.title = _viewControllerType == kEditQuestionSet ? @"编辑题库" : @"选择题库开始游戏";
    }
    
    return self;
}

- (IBAction)onBackClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

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

/*
- (void)prepareGameModeChooser
{
    //Choose single or dual
    _chooseGameModeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _chooseGameModeBtn.frame = self.view.frame;
    _chooseGameModeBtn.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6f];
    [_chooseGameModeBtn addTarget:self action:@selector(cancelGame:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *singlePlayer = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    singlePlayer.frame = CGRectMake(0, 0, 300, 150);
    singlePlayer.center = CGPointMake(_chooseGameModeBtn.center.x, _chooseGameModeBtn.center.y-100);
    [singlePlayer setTitle:@"单人对战" forState:UIControlStateNormal];
    [singlePlayer addTarget:self action:@selector(startSinglePlayerGame:) forControlEvents:UIControlEventTouchUpInside];
    
    [_chooseGameModeBtn addSubview:singlePlayer];
    
    UIButton *twoPlayers = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    twoPlayers.frame = CGRectMake(0, 0, 300, 150);
    twoPlayers.center = CGPointMake(_chooseGameModeBtn.center.x, _chooseGameModeBtn.center.y+100);
    [twoPlayers setTitle:@"双人对决" forState:UIControlStateNormal];
    [twoPlayers addTarget:self action:@selector(startDualPlayersGame:) forControlEvents:UIControlEventTouchUpInside];
    
    [_chooseGameModeBtn addSubview:twoPlayers];
}
*/

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
        
    _questionSetView = [[GMGridView alloc] initWithFrame:_questionSetView_placeholder.frame];
    _questionSetView.style = GMGridViewStyleSwap;
    _questionSetView.itemSpacing = 41;
    _questionSetView.minEdgeInsets = UIEdgeInsetsMake(20, 20, 20, 20);
    _questionSetView.centerGrid = NO;
    _questionSetView.actionDelegate = self;
//    _questionSetView.sortingDelegate = self;
//    _questionSetView.transformDelegate = self;
    _questionSetView.dataSource = self;
    
    [self.view insertSubview:_questionSetView aboveSubview:_questionSetView_placeholder];
    [_questionSetView_placeholder removeFromSuperview];
    
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 5.0f) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyBoardHeightChange:) name:UIKeyboardDidChangeFrameNotification object:nil];
    } else
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyBoardHeightChange:) name:UIKeyboardDidShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyBoardHeightChange:) name:UIKeyboardDidHideNotification object:nil];
    }
    
    [self checkCachedQuestionSets];
    
    if (_viewControllerType == kChooseGameSet) {
//        [self prepareGameModeChooser];
    }
    
    self.view.backgroundColor = [UIColor clearColor];
    ;
    _titleLabel.text = self.title;
    _titleLabel.font = [UIFont regularChineseFontWithSize:33];
}

- (void)viewDidUnload
{
    _titleLabel = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_questionSetView reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return LANDSCAPE_ORIENTATION;
}

#pragma mark - GMGridView DataSource
- (NSInteger)numberOfItemsInGMGridView:(GMGridView *)gridView
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:0];
    int addButton = _viewControllerType == kEditQuestionSet ? NUM_FOR_ADD_BUTTON : 0;
    return [sectionInfo numberOfObjects] + addButton;
}

- (CGSize)GMGridView:(GMGridView *)gridView sizeForItemsInInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    return CGSizeMake(164, 240);
}

- (GMGridViewCell*)GMGridView:(GMGridView *)gridView cellForItemAtIndex:(NSInteger)index
{
    GMGridViewCell *cell = [gridView dequeueReusableCell];
    
    if (!cell) 
    {
        cell = [[GMGridViewCell alloc] init];
        cell.deleteButtonIcon = [UIImage imageNamed:@"close_x.png"];
        cell.deleteButtonOffset = CGPointMake(-15, -15);
    }
    
    [self configureCell:cell atIndex:index];
    
    return cell;
}

- (BOOL)GMGridView:(GMGridView *)gridView canDeleteItemAtIndex:(NSInteger)index
{
    return YES; //index % 2 == 0;
}

#pragma mark - GMGridView Delegate
- (void)GMGridView:(GMGridView *)gridView didTapOnItemAtIndex:(NSInteger)position
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:0];
    if (position >= [sectionInfo numberOfObjects]) { 
        [self performSelector:@selector(insertNewObject)];
        
        QuestionSet *qn_set = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:position inSection:0]];
        QuestionListViewController *listVC = [[QuestionListViewController alloc] initWithManagedContext:self.managedObjectContext andQuestionSet:qn_set];
        [self.navigationController pushViewController:listVC animated:YES];
    } else
    {
        if (_viewControllerType == kEditQuestionSet) {
            QuestionSet *qn_set = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:position inSection:0]];
            QuestionListViewController *listVC = [[QuestionListViewController alloc] initWithManagedContext:self.managedObjectContext andQuestionSet:qn_set];
            
            [self.navigationController pushViewController:listVC animated:YES];
        } else
        {
            //Start game here
            AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
            if (self.isSinglePlayerMode) {
                [appDelegate prepareForSinglePlayerGame];
                [self dismissModalViewControllerAnimated:YES];
            } else
            {
                [appDelegate prepareForTwoPlayersGame];
                [self dismissModalViewControllerAnimated:YES];
            }
        }
    }
}

/*
- (void)startSinglePlayerGame:(UIButton*)btn
{
    
}

- (void)startDualPlayersGame:(UIButton*)btn
{
    
}

- (void)cancelGame:(UIButton*)btn
{
    [_chooseGameModeBtn removeFromSuperview];
}
*/

- (void)GMGridViewDidTapOnEmptySpace:(GMGridView *)gridView
{
    NSLog(@"Tap on empty space");
}

- (void)GMGridView:(GMGridView *)gridView processDeleteActionForItemAtIndex:(NSInteger)index
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Confirm" message:@"Are you sure you want to delete this item?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete", nil];
    
    [alert show];
    //TODO
}

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
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"QuestionSet" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate. (Not applicable)
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"modify_timestamp" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"QuestionSet"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
	    /*
	     Replace this implementation with code to handle the error appropriately.
         
	     abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
	     */
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return __fetchedResultsController;
}    

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
//    [_questionSetListView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    //Should never call this!
//    switch(type) {
//        case NSFetchedResultsChangeInsert:
//            _questionSetListView insertObjectAtIndex:<#(NSInteger)#> withAnimation:<#(GMGridViewItemAnimation)#>
//            break;
//            
//        case NSFetchedResultsChangeDelete:
//            [_questionSetListView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
//            break;
//    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [_questionSetView insertObjectAtIndex:newIndexPath.row withAnimation:GMGridViewItemAnimationScroll];
            break;
            
        case NSFetchedResultsChangeDelete:
            [_questionSetView removeObjectAtIndex:indexPath.row withAnimation:GMGridViewItemAnimationScroll];
            break;
            
        case NSFetchedResultsChangeUpdate:
            //TODO
            break;
            
        case NSFetchedResultsChangeMove:
            //TODO
//            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
//            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
}

- (void)configureCell:(GMGridViewCell *)cell atIndex:(NSInteger)index
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:0];
    if (index >= [sectionInfo numberOfObjects]) {
        //Add Button
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 140, 210)];
        view.backgroundColor = [UIColor redColor];
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 180, 140, 30)];
        lbl.textAlignment = UITextAlignmentCenter;
        lbl.text = @"+";
        
        cell.contentView = view;
    } else
    {
        QuestionSet *managedObject = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 164, 240)];
//        view.backgroundColor = [UIColor redColor];
        
        UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(10, 0, 144, 192)];
        img.backgroundColor = [UIColor blackColor];
        img.tag = 0;
        img.image = [UIImage imageNamed:@"qn_set_cover_default"];
        [view addSubview:img];
        
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(10, 192, 144, 48)];
        lbl.font = [UIFont regularChineseFontWithSize:26];
//        lbl.shadowColor = [UIColor whiteColor];
//        lbl.shadowOffset = CGSizeMake(0, 1);
        lbl.backgroundColor = [UIColor colorWithRed:1.0f green:0.41f blue:0.41f alpha:0.6f];
//        lbl.shadowColor = [UIColor darkTextColor];
//        lbl.shadowOffset = CGSizeMake(0, -1);
        lbl.adjustsFontSizeToFitWidth = YES;
        lbl.minimumFontSize = 9;
        lbl.textAlignment = UITextAlignmentCenter;
        lbl.text = managedObject.name;
        lbl.tag = 1;
        [view addSubview:lbl];
        
        cell.contentView = view;
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

- (BOOL)_parseQuestionSetDictionary:(NSDictionary*)question_set filePath:(NSString*)path fileNameAsSetID:(NSString*)set_id andInsertToCoreDataIfNil:(QuestionSet*)qnSet
{
    if (!set_id) {
        return NO;
    }
    NSString *name = [question_set objectForKey:@"name"];
    NSString *author = [question_set objectForKey:@"author"];
    NSArray *questionRawData = [question_set objectForKey:@"questions"];
    NSDate *createDate = [question_set objectForKey:@"create_timestamp"];
    NSDate *modifyDate = [question_set objectForKey:@"modify_timestamp"];
    NSArray *questions = [Question parseJSONDictionaryArray:questionRawData context:[self.fetchedResultsController managedObjectContext]];
    if (!questions) {
        NSLog(@"FAIL TO PARSE QUESTIONS FROM QSJ FILE");
    } else
    {
    }
    
    if (!qnSet) {
        return [self insertNewObjectWithSetID:set_id name:name author:author createDate:createDate modifyDate:modifyDate questions:questions];
    } else
    {
        return [self _assignValuesToQuestionSetAndSave:qnSet withContext:self.managedObjectContext SetID:set_id name:name author:author createDate:createDate modifyDate:modifyDate questions:questions];
    }

}

- (BOOL)_assignValuesToQuestionSetAndSave:(QuestionSet*)set withContext:(NSManagedObjectContext*)context SetID:(NSString*)set_id name:(NSString*)name author:(NSString*)author createDate:(NSDate*)create_date modifyDate:(NSDate*)modifyDate questions:(NSArray*)questions
{
    // If appropriate, configure the new managed object.
    // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
    [set setValueIfNotNil:create_date forKey:@"create_timestamp"];
    [set setValueIfNotNil:modifyDate forKey:@"modify_timestamp"];
    [set setValueIfNotNil:set_id forKey:@"set_id"];
    [set setValueIfNotNil:name forKey:@"name"];
    [set setValueIfNotNil:author forKey:@"author"];
    if (questions) {
        for (Question *question in questions) {
            question.belongs_to = set;
        }
        [set addQuestions:[NSSet setWithArray:questions]];
    }
    
    // Save the context.
    NSError *error = nil;
    if (![context save:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort(); //TODO
        return NO;
    }
    return YES;
}

- (BOOL)insertNewObjectWithSetID:(NSString*)set_id name:(NSString*)name author:(NSString*)author createDate:(NSDate*)create_date modifyDate:(NSDate*)modifyDate questions:(NSArray*)questions
{
    // Create a new instance of the entity managed by the fetched results controller.
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
    QuestionSet *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
    
    return [self _assignValuesToQuestionSetAndSave:newManagedObject withContext:context SetID:set_id name:name author:author createDate:create_date modifyDate:modifyDate questions:questions];
}

- (BOOL)insertNewObject
{
    NSString *uniqueID = [NSString stringWithFormat:@"user_%@_on_%d", [OpenUDID value], [[NSDate date] timeIntervalSinceReferenceDate]];
    return [self insertNewObjectWithSetID:uniqueID name:@"我的题库" author:@"" createDate:[NSDate date] modifyDate:[NSDate date] questions:nil];
}

#pragma mark - NSNotifications

- (void)onKeyBoardHeightChange:(NSNotification *)notification
{
    CGRect keyboardFrame;
    [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardFrame];
    
    CGRect realKeyboardFrame = [self.view convertRect:keyboardFrame toView:nil];
    //CGRect keyBoardRect = keyHeightValues 
    //TODO here we only take care of lanscape mode, need to consider portrait mode or other types of keyboard if possible
    _questionSetView.contentInset = UIEdgeInsetsMake(0, 0, realKeyboardFrame.origin.y>=0? realKeyboardFrame.size.height : 0, 0);
//    [_questionSetListView scrollRectToVisible:[_questionSetListView rectForRowAtIndexPath:_indexPathForEditingTextField] animated:YES];
}

@end

