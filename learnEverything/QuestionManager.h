//
//  QuestionManager.h
//  learnEverything
//
//  Created by Yuanfeng on 12-06-20.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NonScrollableGridView.h"
#import "QuestionCard.h"

@class  QuestionManager;
@protocol QuestionManagerDelegate <NSObject>

- (void)QuestionManager:(QuestionManager*)manager answerCorrectlyWithCard1:(QuestionCard*)card1 card2:(QuestionCard*)card2;

@end

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

@property BOOL isFlipCards;
@property (nonatomic, strong) NSMutableArray *questionList;
@property (nonatomic, unsafe_unretained) id<QuestionManagerDelegate> questionManagerDelegate;

- (id)initWithGridView:(NonScrollableGridView*)gv questionList:(NSMutableArray*)list;

-(UIView*)viewForNonScrollableGridViewAtRowIndex:(NSInteger)rowIndex columnIndex:(NSInteger)columnIndex;

- (void)reinitGame;

- (void)flipAllCardsWithAnimation:(BOOL)withAnimation;

@end
