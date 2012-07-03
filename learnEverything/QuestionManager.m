//
//  QuestionManager.m
//  learnEverything
//
//  Created by Yuanfeng on 12-06-20.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "QuestionManager.h"
#import "Question.h"
#import <QuartzCore/QuartzCore.h>
#import "NSMutableArray+Shuffling.h"

@implementation QuestionManager
@synthesize isFlipCards;
@synthesize questionList = _questionList;
@synthesize questionManagerDelegate;

- (id)initWithGridView:(NonScrollableGridView*)gv questionList:(NSMutableArray*)list questionType:(QuestionType)type
{
    self = [super init];
    if (self) {
        self.questionList = list;
        _grid_view = gv;
        _currentQuestionSetHead = -1;
        _currentQuestionSetTail = -1;
        _answeredCardIndexPaths = [[NSMutableArray alloc] init];
        _questionType = type;
    }
    return self;
}

- (UIView*)viewForNonScrollableGridViewAtRowIndex:(NSInteger)rowIndex columnIndex:(NSInteger)columnIndex
{
    //if _currentQuestionSetTail and _currentQuestionSetHead not set yet, init them
    if (_currentQuestionSetHead == _currentQuestionSetTail && _currentQuestionSetHead == -1) {
        //first time visit here
        _currentQuestionSetHead = 0;
        _currentQuestionSetTail = _grid_view.numberOfRows*_grid_view.numberOfColumns/2;
    }
    
    BOOL hasChosen = NO;
    NSString *toShowText = nil;
    UIImage *picToShow = nil;
    QuestionCard *aCard = [[QuestionCard alloc] initWithFrame:CGRectMake(0, 0, 200, 123)];
    
    GVIndexPath *indexPath = [GVIndexPath indexPathWithRow:rowIndex andColumn:columnIndex];
    
    while (!hasChosen) {
        int index = _currentQuestionSetHead + arc4random() % (_currentQuestionSetTail-_currentQuestionSetHead);
        Question *qn = [_questionList objectAtIndex:index];
        id qnHasShown = [_indexPathForQuestion objectAtIndex:index];
        id ansHasShown = [_indexPathForAnswer objectAtIndex:index];
        if ([qnHasShown isKindOfClass:[GVIndexPath class]] && [ansHasShown isKindOfClass:[GVIndexPath class]]) {
            continue;
        } else
        {
            //Found one available qn/answer to put in
            hasChosen = YES;
            if (![qnHasShown isKindOfClass:[GVIndexPath class]]) {
                [_indexPathForQuestion replaceObjectAtIndex:index withObject:indexPath];
                aCard.cardType = answer;
                aCard.questionIndex = index;
                
                if (_questionType == kTxtPlusPic) {
                    picToShow = [UIImage imageWithData:qn.answer_in_image];
                } else
                {
                    //Txt Plus Txt
                    toShowText = qn.answer_in_text;
                }
            } else if (![ansHasShown isKindOfClass:[GVIndexPath class]])
            {
                [_indexPathForAnswer replaceObjectAtIndex:index withObject:indexPath];
                toShowText = qn.question_in_text;
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
    
    if (_questionType == kTxtPlusPic && aCard.cardType == answer) {
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:aCard.frame];
        imgView.contentMode = UIViewContentModeScaleAspectFit;
        imgView.image = picToShow;
        [aCard addSubview:imgView];
        [aCard sendSubviewToBack:imgView];
    } else {
        //need to put txt
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 180, 110)]; 
        lbl.center = aCard.center;
        lbl.layer.borderWidth = 3.0f;
        lbl.layer.borderColor = [[UIColor orangeColor] CGColor];
        lbl.layer.cornerRadius = 10.0f;
        lbl.font = [UIFont boldSystemFontOfSize:40];
        lbl.text = toShowText;
        lbl.textAlignment = UITextAlignmentCenter;
        lbl.backgroundColor = [UIColor clearColor];
        [aCard addSubview:lbl];
        [aCard sendSubviewToBack:lbl];
        
        UIImageView *bg = [[UIImageView alloc] initWithFrame:lbl.frame];
        bg.image = [UIImage imageNamed:@"card_bg_1"];
        [aCard addSubview:bg];
        [aCard sendSubviewToBack:bg];
    }
    
    [aCard addTarget:self action:@selector(onUnitClicked:) forControlEvents:UIControlEventTouchUpInside];
    return aCard;
}

- (void)reloadAnsweredCardsHelper
{
    [_answeredCardIndexPaths shuffle];
    [_grid_view reloadUnitsWithIndexPathArray:_answeredCardIndexPaths withReloadMode:kGridViewReloadAnimationModeDefault];
    [_answeredCardIndexPaths removeAllObjects];
}

- (void)shrinkAnsweredCardsHelper
{
    [UIView animateWithDuration:0.5f 
                     animations:^(){
        for (GVIndexPath *ip in _answeredCardIndexPaths) {
            UIView *view = [_grid_view viewForIndexPath:ip];
            view.transform = CGAffineTransformMakeScale(0.01f, 0.01f);
        }
    } 
                     completion:^(BOOL finished){
                         [self reloadAnsweredCardsHelper];
    }];
}

- (void)clearUsedUnitsIfNeeded
{
    //When clicked cards are more than half of total
    
    if ([_answeredCardIndexPaths count]*2 >= _grid_view.numberOfRows*_grid_view.numberOfColumns) {
        
        _currentQuestionSetHead = (_currentQuestionSetTail+1)%[_questionList count];
        _currentQuestionSetTail = (_currentQuestionSetHead+[_answeredCardIndexPaths count]/2)%[_questionList count];
        
        [UIView animateWithDuration:0.15f 
                         animations:^(){
                for (GVIndexPath *ip in _answeredCardIndexPaths) {
                    UIView *view = [_grid_view viewForIndexPath:ip];
                    view.transform = CGAffineTransformMakeScale(1.1f, 1.1f);}
                }
                         completion:^(BOOL finished){
                             [self shrinkAnsweredCardsHelper];
                }];
    }
}

- (void)onUnitClicked:(id)sender
{
    QuestionCard *card = sender;
    
    if (card.checkmark.hidden == NO) {
        return; //clicked on used card
    }
    
    GVIndexPath *nowClickIndexPath = [_grid_view indexPathForUnitView:card];
    card.pressed = !card.pressed;
    
    if ([questionManagerDelegate respondsToSelector:@selector(QuestionManager:clickOnCard:)]) {
        [questionManagerDelegate QuestionManager:self clickOnCard:card];
    }
    
    if (!_clickedBtnIndexPath || (_clickedBtnIndexPath.row == nowClickIndexPath.row && _clickedBtnIndexPath.column == nowClickIndexPath.column)) {
        
        //click on the same card
        if (!_clickedBtnIndexPath) {
            _clickedBtnIndexPath = nowClickIndexPath;
        
        } else
        {
            _clickedBtnIndexPath = nil;
        }
        
        //Not used
        //Flip card since it's first card (or click on same card)
        if (isFlipCards) {
            [card flipCardWithDuration:0.5f completion:NULL];
        }
    } else
    {
        //Clicked on second btn, react corrdingly
        QuestionCard *card1 = (QuestionCard*)[_grid_view viewForIndexPath:_clickedBtnIndexPath];
        
        if (card1.cardType == card.cardType) {
            //Same card type, revert pressed state
            card.pressed = NO;
            card1.pressed = NO;
            //TODO play the DU sound
            
            //Not used
            if (isFlipCards) {
                //Flip second one, then both flip back
                [card flipCardWithDuration:0.5f 
                                 completion:^(BOOL finished){
                                    [card flipCardWithDuration:0.5f completion:NULL];
                                    [card1 flipCardWithDuration:0.5f completion:NULL];
                                 }
                ];
            }
            
            //Seet clicked to nil
            _clickedBtnIndexPath = nil;
            
        } else
        {
            if (card1.questionIndex == card.questionIndex) {
                if (isFlipCards) {
                    //Not used
                    /*
                    [card flipCardWithDuration:0.5f 
                                    completion:^(BOOL finished){
                                        //same block as below!!!
                                        //Answer is correct
                                        card1.checkmark.hidden = NO;
                                        card.checkmark.hidden = NO;
                                        
                                        //Register answered cards
                                        [_answeredCardIndexPaths addObject:_clickedBtnIndexPath];
                                        [_answeredCardIndexPaths addObject:nowClickIndexPath];
                                        
                                        [self clearUsedUnitsIfNeeded];
                                        
                                        _clickedBtnIndexPath = nil;
                                    }
                     ];
                     */
                } else
                {
                    //Answer is correct
                    card1.checkmark.hidden = NO;
                    card1.checkmark.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
                    card.checkmark.hidden = NO;
                    card.checkmark.transform = card1.checkmark.transform;
                    
                    [UIView animateWithDuration:0.2f 
                                          delay:0.0f 
                                        options:UIViewAnimationOptionAllowUserInteraction
                                     animations:^{
                                        card.checkmark.transform = card1.checkmark.transform = CGAffineTransformIdentity;
                                    }
                                    completion:^(BOOL finished) {
                                        //Animate stars
                                        if ([questionManagerDelegate respondsToSelector:@selector(QuestionManager:answerCorrectlyWithCard1:card2:)]) {
                                            [questionManagerDelegate QuestionManager:self answerCorrectlyWithCard1:card card2:card1];
                                        }
                                        [self clearUsedUnitsIfNeeded];
                                    }
                     ];
                    
                    //Register answered cards
                    [_answeredCardIndexPaths addObject:_clickedBtnIndexPath];
                    [_answeredCardIndexPaths addObject:nowClickIndexPath];
                    
                    _clickedBtnIndexPath = nil;
                }
            } else
            {
                //Wrong answer
                //TODO show cross and DU sound
                card1.wrongcross.hidden = NO;
                card1.wrongcross.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
                card.wrongcross.hidden = NO;
                card.wrongcross.transform = card1.checkmark.transform;
                
                [UIView animateWithDuration:0.3f 
                                      delay:0.0f 
                                    options:UIViewAnimationOptionAllowUserInteraction
                                 animations:^{
                                     card.wrongcross.transform = card1.wrongcross.transform = CGAffineTransformIdentity;
                                 }
                                 completion:^(BOOL finished) {
                                     //Animate flame
                                     card.pressed = NO;
                                     card1.pressed = NO;
                                     if ([questionManagerDelegate respondsToSelector:@selector(QuestionManager:answerWronglyWithCard1:card2:)]) {
                                         [questionManagerDelegate QuestionManager:self answerWronglyWithCard1:card card2:card1];
                                     }
                                     [UIView animateWithDuration:0.0 delay:0.3f options:UIViewAnimationOptionAllowUserInteraction animations:^{
                                         card.wrongcross.hidden = YES;
                                         card1.wrongcross.hidden = YES;
                                     } completion:^(BOOL finished) {
                                         
                                     }];
                                 }
                 ];
                
                //Not used
                if (isFlipCards) {
                    //Flip second one, then both flip back
                    [card flipCardWithDuration:0.5f 
                                     completion:^(BOOL finished){
                                         [card flipCardWithDuration:0.5f completion:NULL];
                                         [card1 flipCardWithDuration:0.5f completion:NULL];
                                     }
                     ];
                }
                
                _clickedBtnIndexPath = nil;
            }
        }
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

- (void)flipAllCardsWithAnimation:(BOOL)animation
{
    if (isFlipCards) {
        NSArray *array = [_grid_view allUnits];
        for (QuestionCard *card in array) {
            [card flipCardWithDuration:0.5f completion:NULL];
        }
    }
}
@end
