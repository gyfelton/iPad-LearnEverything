//
//  ViewController.h
//  learnEverything
//
//  Created by Yuanfeng on 12-06-01.
//  Copyright (c) 2012 ____Yuanfeng Gao___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "BaseGameViewController.h"
#import "NonScrollableGridView.h"
#import "QuestionCardsManager.h"
#import "AnimationViewController.h"

@interface SinglePlayerGameViewController : BaseGameViewController <NonScrollableGridViewDataSource, QuestionCardsManagerDelegate>
{
    __unsafe_unretained IBOutlet UIView *_grid_view_place_holder;
    NonScrollableGridView *_grid_view;
    
    NSMutableArray *_questionList;
    
//    NSMutableArray *_indexPathForQuestion;
//    NSMutableArray *_indexPathForAnswer;
    
    QuestionCardsManager *_questionManager;
    
    UIImageView *_countdownImageView;
    
    __unsafe_unretained IBOutlet UIProgressView *_progressBar;
    __unsafe_unretained IBOutlet UIView *_animationStageView;
}
- (id)initWithManagedContext:(NSManagedObjectContext*)context questionSet:(QuestionSet*)questionSet;
- (void)reinitGame;
@end
