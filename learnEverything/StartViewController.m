//
//  StartViewController.m
//  learnEverything
//
//  Created by Yuanfeng on 12-06-02.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
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
        self.title = @"开始游戏";
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
//    self.view.backgroundColor = [UIColor clearColor];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

/*
- (void)_animateCurl
{
    
    // Curl the image up or down
    CATransition *animation = [CATransition animation];
    [animation setDuration:1.5];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    animation.delegate = self;
    animation.type = @"pageCurl";
    animation.subtype = @"fromRight";
    animation.fillMode = kCAFillModeBoth;
    animation.endProgress = 0.89;
    
    animation.removedOnCompletion = NO;
    
    [self.view.layer addAnimation:animation forKey:@"pageCurlAnimation"];
}*/

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return LANDSCAPE_ORIENTATION;
}

- (void)pushQuestionSetViewController:(BOOL)isSinglePlayer
{
    QuestionSetViewController *chooseQuestionSet = [[QuestionSetViewController alloc] initWithViewControllerType:kChooseGameSet];
    
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    chooseQuestionSet.managedObjectContext = appDelegate.managedObjectContext;
    
    chooseQuestionSet.isSinglePlayerMode = isSinglePlayer;
    
    [self.navigationController pushViewController:chooseQuestionSet animated:YES];
}

- (IBAction)onSinglePlayerGameClicked:(id)sender {

    [self pushQuestionSetViewController:YES];
}

- (IBAction)onTwoPlayersGameClicked:(id)sender
{
    [self pushQuestionSetViewController:NO];
}

- (IBAction)onEditQuestionSetList:(id)sender {
    ParentControlViewController *parentControl = [[ParentControlViewController alloc] initWithNibName:nil bundle:nil];
    
    [self.navigationController pushViewController:parentControl animated:YES];
}

@end
