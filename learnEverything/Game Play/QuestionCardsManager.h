//
//  QuestionCardsManager.h
//  learnEverything
//
//  Created by Yuanfeng on 12-06-20.
//  Copyright (c) 2012 ____Yuanfeng Gao___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NonScrollableGridView.h"
#import "QuestionCard.h"
#import "QuestionType.h"

@class  QuestionCardsManager;
@protocol QuestionCardsManagerDelegate <NSObject>

- (void)QuestionCardsManager:(QuestionCardsManager*)manager clickOnSameTypeCardsWithCard1:(QuestionCard*)card1 card2:(QuestionCard*)card2;
- (void)QuestionCardsManager:(QuestionCardsManager*)manager answerCorrectlyWithCard1:(QuestionCard*)card1 card2:(QuestionCard*)card2;
- (void)QuestionCardsManager:(QuestionCardsManager *)manager answerWronglyWithCard1:(QuestionCard *)card1 card2:(QuestionCard *)card2;
- (void)QuestionCardsManager:(QuestionCardsManager *)manager clickOnCard:(QuestionCard*)card;
@end

@interface QuestionCardsManager : NSObject {
    //指定当前使用的是那一组题目，需要除余保证不越界
    NSInteger _lastUsedQuestionPointer;
    
    NSInteger _numberOfCardsInGridView;
    NSInteger _numberOfQuestionsNeeded;
    
    //指向只读的questionList
    NSMutableArray *_expandedQuestionList;
    
    //array的个数跟卡片的个数相同，储存index＋Q或A，还有是否已经答对，指向expandedQuestionList
    NSMutableArray *_dictForCurrentQuestionsOnView;
    
    //用于储存答对的card的位置
    NSMutableArray *_answeredCardIndexPaths;
    
    //储存第一个激活按钮的位置
    GVIndexPath *_clickedBtnIndexPath;
    
    NonScrollableGridView *_grid_view;
    
    QuestionType _questionType;
}

//@property BOOL isFlipCards;
@property (nonatomic, unsafe_unretained) id<QuestionCardsManagerDelegate> customDelegate;

- (id)initWithGridView:(NonScrollableGridView*)gv questionList:(NSMutableArray*)list questionType:(QuestionType)type numberOfCardsInGridView:(NSInteger)numCards;

-(UIView*)viewForNonScrollableGridViewAtRowIndex:(NSInteger)rowIndex columnIndex:(NSInteger)columnIndex;

//- (void)reinitGame;

//- (void)flipAllCardsWithAnimation:(BOOL)withAnimation;

@end
