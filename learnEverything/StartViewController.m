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

- (IBAction)onSinglePlayerGameClicked:(id)sender {
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate prepareForSinglePlayerGame];
    
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)onTwoPlayersGameClicked:(id)sender
{
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate prepareForTwoPlayersGame];
    
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)onEditQuestionSetList:(id)sender {
    QuestionSetViewController *questionEditVC = [[QuestionSetViewController alloc] initWithNibName:nil bundle:nil];
    questionEditVC.managedObjectContext = ((AppDelegate*)[UIApplication sharedApplication].delegate).managedObjectContext;
    
    [self.navigationController pushViewController:questionEditVC animated:YES];
}

@end
