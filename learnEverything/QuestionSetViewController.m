//
//  QuestionListViewController.m
//  learnEverything
//
//  Created by Yuanfeng on 12-06-02.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "QuestionSetViewController.h"
#import "QuestionSet.h"
#import "OpenUDID.h"

@interface QuestionSetViewController (Private) 
- (void)configureCell:(GMGridViewCell *)cell atIndex:(NSInteger)index;
@end

@implementation QuestionSetViewController
@synthesize managedObjectContext;
@synthesize fetchedResultsController = __fetchedResultsController;

#define NUM_FOR_ADD_BUTTON 1

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"题库列表";
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
        
    _questionSetView = [[GMGridView alloc] initWithFrame:_questionSetView_placeholder.frame];
    _questionSetView.style = GMGridViewStyleSwap;
    _questionSetView.itemSpacing = 30;
    _questionSetView.minEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    _questionSetView.centerGrid = YES;
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
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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
    return [sectionInfo numberOfObjects] + NUM_FOR_ADD_BUTTON;
}

- (CGSize)GMGridView:(GMGridView *)gridView sizeForItemsInInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    return CGSizeMake(200, 300);
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
    } else
    {
        
    }
}

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
        UILabel *view = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 300)];
        view.backgroundColor = [UIColor redColor];
        view.text = @"+";
        
        cell.contentView = view;
    } else
    {
        QuestionSet *managedObject = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        
        UILabel *view = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 300)];
        view.backgroundColor = [UIColor redColor];
        view.text = managedObject.name;
        
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

- (void)insertNewObject
{
    // Create a new instance of the entity managed by the fetched results controller.
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
    QuestionSet *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
    
    // If appropriate, configure the new managed object.
    // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
    [newManagedObject setValue:[NSDate date] forKey:@"create_timestamp"];
    [newManagedObject setValue:[NSDate date] forKey:@"modify_timestamp"];
    NSString *uniqueID = [NSString stringWithFormat:@"user_%@_on_%d", [OpenUDID value], [[NSDate date] timeIntervalSinceReferenceDate]];
    [newManagedObject setValue:uniqueID forKey:@"set_id"];
    [newManagedObject setValue:uniqueID forKey:@"name"]; //TODO
    
    // Save the context.
    NSError *error = nil;
    if (![context save:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
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
    _questionSetView.contentInset = UIEdgeInsetsMake(0, 0, realKeyboardFrame.origin.y>=0? realKeyboardFrame.size.height : 0, 0);
//    [_questionSetListView scrollRectToVisible:[_questionSetListView rectForRowAtIndexPath:_indexPathForEditingTextField] animated:YES];
}

@end

