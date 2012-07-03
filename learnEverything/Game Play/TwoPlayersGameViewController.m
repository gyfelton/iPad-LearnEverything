//
//  TwoPlayersGameViewController.m
//  learnEverything
//
//  Created by Yuanfeng on 12-06-10.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TwoPlayersGameViewController.h"
#import "AppDelegate.h"

#define ROW_NUMBER 3
#define COLUMN_NUMBER 4

@implementation TwoPlayersGameViewController

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

- (void)reinitGame
{
    [_questionManager_dark reinitGame];
    [_questionManager_light reinitGame];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.wantsFullScreenLayout = YES;
	// Do any additional setup after loading the view, typically from a nib.
    
    _questionList = [super allQuestions];
    
    _grid_view_light = [[NonScrollableGridView alloc] initWithFrame:_grid_view_light_place_holder.frame];
    _grid_view_light.dataSource = self;
    
    [self.view insertSubview:_grid_view_light aboveSubview:_grid_view_light_place_holder];
    [_grid_view_light_place_holder removeFromSuperview];
    
    _grid_view_dark = [[NonScrollableGridView alloc] initWithFrame:_grid_view_dark_place_holder.frame];
    _grid_view_dark.dataSource = self;
    
    _grid_view_dark.transform = CGAffineTransformMakeRotation(M_PI);
    
    [self.view insertSubview:_grid_view_dark aboveSubview:_grid_view_dark_place_holder];
    [_grid_view_dark_place_holder removeFromSuperview];
    
    _questionManager_light = [[QuestionManager alloc] initWithGridView:_grid_view_light questionList:_questionList questionType:[_questionSet.question_type intValue]];
    _questionManager_dark = [[QuestionManager alloc] initWithGridView:_grid_view_dark questionList:_questionList questionType:[_questionSet.question_type intValue]];
    
    [self reinitGame];
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
    return interfaceOrientation == UIInterfaceOrientationPortrait;
}

#pragma mark - NonScrollableGridView DataSource
- (NSInteger)numberOfRowsForNonScrollableGridView:(NonScrollableGridView *)gridView
{
    if (_grid_view_dark == gridView) {
        return [_questionList count]>0? ROW_NUMBER : 0;
    } else if (gridView == _grid_view_light)
    {
        return [_questionList count]>0? ROW_NUMBER : 0;
    }
    return 0;
}

- (NSInteger)numberOfColumnsForNonScrollableGridView:(NonScrollableGridView *)gridView
{
    if (_grid_view_dark == gridView) {
        return [_questionList count]>0? COLUMN_NUMBER : 0;
    } else if (gridView == _grid_view_light)
    {
        return [_questionList count]>0? COLUMN_NUMBER : 0;
    }
    return 0;
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
    if (gridView == _grid_view_light) {
        return [_questionManager_light viewForNonScrollableGridViewAtRowIndex:rowIndex columnIndex:columnIndex];
    } else if (gridView == _grid_view_dark)
    {
        return [_questionManager_dark viewForNonScrollableGridViewAtRowIndex:rowIndex columnIndex:columnIndex];
    }
    return nil;
}

@end
