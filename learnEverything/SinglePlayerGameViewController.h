//
//  ViewController.h
//  learnEverything
//
//  Created by Yuanfeng on 12-06-01.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "BaseGameViewController.h"
#import "NonScrollableGridView.h"
#import "QuestionManager.h"

@interface SinglePlayerGameViewController : BaseGameViewController <NonScrollableGridViewDataSource>
{
    __unsafe_unretained IBOutlet UIView *_grid_view_place_holder;
    NonScrollableGridView *_grid_view;
    
    NSMutableArray *_questionList;
//    NSMutableArray *_indexPathForQuestion;
//    NSMutableArray *_indexPathForAnswer;
    
    QuestionManager *_questionManager;
}

- (void)reinitGame;
@end
