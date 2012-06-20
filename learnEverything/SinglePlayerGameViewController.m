//
//  ViewController.m
//  learnEverything
//
//  Created by Yuanfeng on 12-06-01.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SinglePlayerGameViewController.h"
#import "NSMutableArray+Shuffling.h"
#import "AppDelegate.h"
#import "Question.h"
#import "QuestionCard.h"

#define ROW_NUMBER 4
#define COLUMN_NUMBER 5

@implementation SinglePlayerGameViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.wantsFullScreenLayout = YES;
	// Do any additional setup after loading the view, typically from a nib.
    _questionList = [super allQuestions];
    
    _grid_view = [[NonScrollableGridView alloc] initWithFrame:_grid_view_place_holder.frame];
    _grid_view.dataSource = self;
    
    [self.view insertSubview:_grid_view aboveSubview:_grid_view_place_holder];
    [_grid_view_place_holder removeFromSuperview];
    
    _questionManager = [[QuestionManager alloc] initWithGridView:_grid_view questionList:_questionList];
    
    [self reinitGame];
}

- (void)viewDidUnload
{
    _grid_view_place_holder = nil;
    _grid_view = nil;
    _questionList = nil;
    _questionManager = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [_grid_view layoutUnitsAnimatedWithAnimationDirection:kGridViewAnimationFlowFromBottom];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return LANDSCAPE_ORIENTATION;
    }
}

- (void)reinitGame
{
    //Init the question list
    [_questionManager reinitGame];
}

#pragma mark - NonScrollableGridView DataSource
- (NSInteger)numberOfRowsForNonScrollableGridView:(NonScrollableGridView *)gridView
{
    return [_questionList count]>0? ROW_NUMBER : 0;
}

- (NSInteger)numberOfColumnsForNonScrollableGridView:(NonScrollableGridView *)gridView
{
    return [_questionList count]>0? COLUMN_NUMBER : 0;
}

- (CGFloat)widthForEachUnit:(NonScrollableGridView *)gridView
{
    return 200;
}

- (CGFloat)heightForEachUnit:(NonScrollableGridView *)gridView
{
    return 123;
}

-(UIView*)viewForNonScrollableGridView:(NonScrollableGridView *)gridView atRowIndex:(NSInteger)rowIndex columnIndex:(NSInteger)columnIndex
{
    return [_questionManager viewForNonScrollableGridViewAtRowIndex:rowIndex columnIndex:columnIndex];
}

@end
