//
//  QuestionManager.m
//  learnEverything
//
//  Created by Yuanfeng on 12-06-20.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "QuestionManager.h"
#import "QuestionCard.h"
#import "Question.h"
#import <QuartzCore/QuartzCore.h>
#import "NSMutableArray+Shuffling.h"

@implementation QuestionManager

@synthesize questionList = _questionList;

- (id)initWithGridView:(NonScrollableGridView*)gv questionList:(NSMutableArray*)list
{
    self = [super init];
    if (self) {
        self.questionList = [[NSMutableArray alloc] initWithArray:list];
        _grid_view = gv;
        _currentQuestionSetHead = -1;
        _currentQuestionSetTail = -1;
    }
    return self;
}

-(UIView*)viewForNonScrollableGridViewAtRowIndex:(NSInteger)rowIndex columnIndex:(NSInteger)columnIndex
{
    //if _currentQuestionSetTail and _currentQuestionSetHead not set yet, init them
    if (_currentQuestionSetHead == _currentQuestionSetTail) {
        _currentQuestionSetHead = 0;
        _currentQuestionSetTail = _grid_view.numberOfRows*_grid_view.numberOfColumns/2;
    }
    
    BOOL hasChosen = NO;
    NSString *toShow = nil;
    QuestionCard *aCard = [[QuestionCard alloc] initWithFrame:CGRectMake(0, 0, 200, 123)];
    GVIndexPath *indexPath = [GVIndexPath indexPathWithRow:rowIndex andColumn:columnIndex];
    
    while (!hasChosen) {
        int index = _currentQuestionSetHead + arc4random() % _currentQuestionSetTail;
        Question *qn = [_questionList objectAtIndex:index];
        id qnHasShown = [_indexPathForQuestion objectAtIndex:index];
        id ansHasShown = [_indexPathForAnswer objectAtIndex:index];
        if ([qnHasShown isKindOfClass:[GVIndexPath class]] && [ansHasShown isKindOfClass:[GVIndexPath class]]) {
            continue;
        } else
        {
            hasChosen = YES;
            if (![qnHasShown isKindOfClass:[GVIndexPath class]]) {
                [_indexPathForQuestion replaceObjectAtIndex:index withObject:indexPath];
                toShow = qn.answer_in_text;
                aCard.cardType = answer;
                aCard.questionIndex = index;
            } else if (![ansHasShown isKindOfClass:[GVIndexPath class]])
            {
                [_indexPathForAnswer replaceObjectAtIndex:index withObject:indexPath];
                toShow = qn.question_in_text;
                aCard.cardType = question;
                aCard.questionIndex = index;
            } else
            {
                //Should never reach here
                [NSException raise:@"Exception at getting question/ans for card" format:nil];
            }
        }
    }
    
    aCard.associatedIndexPath = indexPath;
    
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 180, 110)]; 
    lbl.center = aCard.center;
    lbl.layer.borderWidth = 3.0f;
    lbl.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    lbl.layer.cornerRadius = 5.0f;
    lbl.font = [UIFont boldSystemFontOfSize:40];
    lbl.text = toShow;
    lbl.textAlignment = UITextAlignmentCenter;
    lbl.backgroundColor = [UIColor clearColor];
    [aCard addSubview:lbl];
    [aCard sendSubviewToBack:lbl];
    
    [aCard addTarget:self action:@selector(onUnitClicked:) forControlEvents:UIControlEventTouchUpInside];
    return aCard;
}

- (void)clearUsedUnitsIfNeeded
{
    
}

- (void)onUnitClicked:(id)sender
{
    QuestionCard *card = sender;
    if (card.checkmark.hidden == NO) {
        return; //clicked on used card
    }
    
    GVIndexPath *indexPath = [_grid_view indexPathForUnitView:card];
    card.selected = !card.selected;
    
    if (!_clickedBtnIndexPath || (_clickedBtnIndexPath.row == indexPath.row && _clickedBtnIndexPath.column == indexPath.column)) {
        _clickedBtnIndexPath = indexPath;
    } else
    {
        //Clicked on second btn, react corrdingly
        QuestionCard *card1 = (QuestionCard*)[_grid_view viewForIndexPath:_clickedBtnIndexPath];
        
        if (card1.cardType == card.cardType) {
            //Do nothing
            card.selected = NO;
            card1.selected = NO;
        } else
        {
            //            QuestionCard *questionCard = card.cardType==question?card:card1;
            //            GVIndexPath *questionIndex = [_grid_view indexPathForUnitView:questionCard];
            //            QuestionCard *answerCard = card.cardType==answer?card:card1;
            //            
            //            NSInteger index = 0;
            //            for (GVIndexPath *ip in _indexPathForQuestion) {
            //                if ([ip isKindOfClass:[GVIndexPath class]]) {
            //                    if (ip.row == questionIndex.row && ip.column == questionIndex.column) {
            //                        break;
            //                    }
            //                }
            //                index++;
            //            }
            //            GVIndexPath *answerIndex = [_indexPathForAnswer objectAtIndex:index];
            //            GVIndexPath *answerIndexToCompare = [_grid_view indexPathForUnitView:answerCard];
            if (card1.questionIndex == card.questionIndex) {
                //Answer is correct
                card1.checkmark.hidden = NO;
                card.checkmark.hidden = NO;
            } else
            {
                card.selected = NO;
                card1.selected = NO;
            }
        }
        
        _clickedBtnIndexPath = nil;
        
        [self clearUsedUnitsIfNeeded];
    }
}

- (void)reinitGame
{
    //Init the question list
    _indexPathForQuestion = [[NSMutableArray alloc] initWithCapacity:[_questionList count]];
    _indexPathForAnswer = [[NSMutableArray alloc] initWithCapacity:[_questionList count]];
    for (int i = 0; i<[_questionList count]; i++) {
        NSNumber *hasShown = [NSNumber numberWithInt:NO];
        NSNumber *hasShown2 = [NSNumber numberWithBool:NO];
        [_indexPathForQuestion addObject:hasShown];
        [_indexPathForAnswer addObject:hasShown2];
    }
    
    //Shuffle the question list 
    [_questionList shuffle];
    
    [_grid_view reloadData];
}

@end
