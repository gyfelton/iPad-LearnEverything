//
//  QuestionSetViewController.m
//  learnEverything
//
//  Created by Yuanfeng on 12-06-02.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "QuestionListViewController.h"

#import "QuestionSetViewController.h"
#import "QuestionSet.h"

#import "AppDelegate.h"
#import "FileIOSharedManager.h"

@interface QuestionSetViewController (Private) 
- (void)configureCell:(GMGridViewCell *)cell atIndex:(NSInteger)index;
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
        self.title = _viewControllerType == kEditQuestionSet ? @"题库列表" : @"选择题库开始游戏";
    }
    
    return self;
}

- (IBAction)onBackClicked:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:NO];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


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
    _questionSetView.clipsToBounds = YES;
    _questionSetView.style = GMGridViewStyleSwap;
    _questionSetView.itemSpacing = 0;
    _questionSetView.minEdgeInsets = UIEdgeInsetsMake(10, 92, 10, 92);
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
    
//    [self checkCachedQuestionSets];
    [[FileIOSharedManager sharedManager] checkCachedQuestionSets];
    
    if (_viewControllerType == kChooseGameSet) {
//        [self prepareGameModeChooser];
    }
    
    self.view.backgroundColor = [UIColor clearColor];
    ;
    _titleLabel.text = self.title;
    _titleLabel.font = [UIFont regularChineseFontWithSize:33];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self fetchedResultsController]; //Specify the delegate
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
    [self.navigationController setNavigationBarHidden:YES];
    [_questionSetView reloadData];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if ([FileIOSharedManager sharedManager].fetchedResultsController.delegate == self) {
        [FileIOSharedManager sharedManager].fetchedResultsController.delegate = nil;
    }
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
    return CGSizeMake(210, 290);
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
        [[FileIOSharedManager sharedManager] performSelector:@selector(insertNewObject)];
        
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
            QuestionSet *qn_set = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:position inSection:0]];
            AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
            if (self.isSinglePlayerMode) {
                [appDelegate prepareForSinglePlayerGameWithQuestionSet:qn_set];
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
        if (__fetchedResultsController.delegate != self)
        {
            __fetchedResultsController.delegate = self;
        }
        return __fetchedResultsController;
    }
    
    __fetchedResultsController = [FileIOSharedManager sharedManager].fetchedResultsController;
    __fetchedResultsController.delegate = self;
    
    //Set up the fetch result controller with SharedManager
    //Set the delegate, very important

    /*
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
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    */
    
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
            //Don't do this for now
//            [_questionSetView insertObjectAtIndex:newIndexPath.row withAnimation:GMGridViewItemAnimationScroll];
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
        UIImageView *view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 210, 290)];
        view.image = [UIImage imageNamed:@"question_set_add_new"];
        view.userInteractionEnabled = YES;
        
        cell.contentView = view;
    } else
    {
        QuestionSet *managedObject = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        
        UIImageView *view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 210, 290)];
        view.image = [UIImage imageNamed:@"question_set_bg_2"];
        view.userInteractionEnabled = YES;
//        view.backgroundColor = [UIColor redColor];
        
        UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(30, 16, 153, 204)];
        img.backgroundColor = [UIColor clearColor];
        img.contentMode = UIViewContentModeScaleAspectFit;
        img.tag = 0;
        img.image = [UIImage imageWithData:managedObject.cover_data];
        [view addSubview:img];
        
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(21, 224, 176, 40)];
        lbl.font = [UIFont regularChineseFontWithSize:33];
        lbl.shadowColor = [UIColor blackColor];
        lbl.shadowOffset = CGSizeMake(1, -1);
        lbl.backgroundColor = [UIColor clearColor];
        lbl.textColor = [UIColor whiteColor];
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

