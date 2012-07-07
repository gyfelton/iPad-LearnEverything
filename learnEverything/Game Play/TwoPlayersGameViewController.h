//
//  TwoPlayersGameViewController.h
//  learnEverything
//
//  Created by Yuanfeng on 12-06-10.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "BaseGameViewController.h"
#import "QuestionManager.h"
#import "QuestionCard.h"
#import "Question.h"
#import "NonScrollableGridView.h"

@interface TwoPlayersGameViewController : BaseGameViewController <NonScrollableGridViewDataSource, QuestionManagerDelegate>
{
    NonScrollableGridView *_grid_view;

    NSMutableArray *_questionList;
    
    UIImageView *_countdownImageView;
    
    //Light side
//    NSMutableArray *_questionList_light;
    QuestionManager *_questionManager_light;
    IBOutlet UIView *_grid_view_light_place_holder;
    NonScrollableGridView *_grid_view_light;
    
    //Dark side
    QuestionManager *_questionManager_dark;  
    IBOutlet UIView *_grid_view_dark_place_holder;
    NonScrollableGridView *_grid_view_dark;
    
    IBOutlet UIView *_animation_place_holder;
    
    UIView *_menuContainer1;
    UIView *_menuContainer2;
}

- (id)initWithManagedContext:(NSManagedObjectContext *)context questionSet:(QuestionSet *)questionSet;

@end
