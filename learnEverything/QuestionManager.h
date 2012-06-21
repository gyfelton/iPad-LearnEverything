//
//  QuestionManager.h
//  learnEverything
//
//  Created by Yuanfeng on 12-06-20.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NonScrollableGridView.h"

@interface QuestionManager : NSObject {
    int _currentQuestionSetHead;
    int _currentQuestionSetTail;
    
    NSMutableArray *_questionList;
    NSMutableArray *_indexPathForQuestion;
    NSMutableArray *_indexPathForAnswer;
    
    GVIndexPath *_clickedBtnIndexPath;
    
    NonScrollableGridView *_grid_view;
    
    NSMutableArray *_answeredCardIndexPaths;
}

@property (nonatomic, strong) NSMutableArray *questionList;

- (id)initWithGridView:(NonScrollableGridView*)gv questionList:(NSMutableArray*)list;

-(UIView*)viewForNonScrollableGridViewAtRowIndex:(NSInteger)rowIndex columnIndex:(NSInteger)columnIndex;

- (void)reinitGame;

@end
