//
//  StartViewController.m
//  learnEverything
//
//  Created by Yuanfeng on 12-06-02.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StartViewController.h"
#import "AppDelegate.h"
#import "SinglePlayerGameViewController.h"
#import "ParentControlViewController.h"
#import "QuestionSetViewController.h"

@implementation StartViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return LANDSCAPE_ORIENTATION;
}

- (IBAction)onSinglePlayerGameClicked:(id)sender {
    QuestionSetViewController *chooseQuestionSet = [[QuestionSetViewController alloc] initWithViewControllerType:kChooseGameSet];
    
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    chooseQuestionSet.managedObjectContext = appDelegate.managedObjectContext;
    
    [self.navigationController pushViewController:chooseQuestionSet animated:YES];
//    
//    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
//    [appDelegate prepareForSinglePlayerGame];
//    
//    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)onTwoPlayersGameClicked:(id)sender
{
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate prepareForTwoPlayersGame];
    
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)onEditQuestionSetList:(id)sender {
    ParentControlViewController *parentControl = [[ParentControlViewController alloc] initWithNibName:nil bundle:nil];
    
    [self.navigationController pushViewController:parentControl animated:YES];
}

@end
