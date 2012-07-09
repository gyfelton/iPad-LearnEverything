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
//@synthesize isFlipCards;
//@synthesize questionList = _questionList;
@synthesize questionManagerDelegate;

- (void)incrementLastUsedQuestionPointer
{
    _lastUsedQuestionPointer++;
    if (_lastUsedQuestionPointer >= [_expandedQuestionList count]) {
        _lastUsedQuestionPointer = 0; //防止数组超界
    }
}

- (void)initCurrentQuestionsOnView
{
    for (int i = 0 ; i < _numberOfCardsInGridView; i++) {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [_dictForCurrentQuestionsOnView addObject:dict];
    }
    
    _lastUsedQuestionPointer = 0;
    for (int i = 0; i < _numberOfQuestionsNeeded; i++) {
        //Insert the question's q and a to two random places
        BOOL hadFoundForQn = NO;
        NSInteger indexForQn;
        NSInteger indexForAns;
        BOOL hadFoundForAns = NO;
        do {
            int indexToInsert = arc4random() % _numberOfCardsInGridView;
            if (indexToInsert != indexForQn) {
                NSMutableDictionary *dict = [_dictForCurrentQuestionsOnView objectAtIndex:indexToInsert];
                if ([[dict allKeys] count] == 0) {
                    //找到个位置
                    if (!hadFoundForQn) {
                        indexForQn = indexToInsert;
                        hadFoundForQn = YES;
                    } else
                    {
                        indexForAns = indexToInsert;
                        hadFoundForAns = YES;
                    }
                }
            }
        } while (!hadFoundForQn || !hadFoundForAns);
        
        //插入到对应位置
        NSMutableDictionary *dict = [_dictForCurrentQuestionsOnView objectAtIndex:indexForQn];
        NSMutableDictionary *dictAns = [_dictForCurrentQuestionsOnView objectAtIndex:indexForAns];
        
        [dict setObject:[NSNumber numberWithInt:_lastUsedQuestionPointer] forKey:@"index"];
        [dictAns setObject:[NSNumber numberWithInt:_lastUsedQuestionPointer] forKey:@"index"];
        
        [dict setObject:[NSNumber numberWithBool:YES] forKey:@"is_question"];
        [dictAns setObject:[NSNumber numberWithBool:NO] forKey:@"is_question"];
        
        [self incrementLastUsedQuestionPointer];
    }
}

- (void)refillAnsweredQuestions
{
    BOOL hasUsedQuestion = NO;
    for (GVIndexPath *indexPath in _answeredCardIndexPaths) {
        NSInteger targetIndex = indexPath.row * _grid_view.numberOfColumns + indexPath.column;
        NSMutableDictionary *dict = [_dictForCurrentQuestionsOnView objectAtIndex:targetIndex];
        [dict setObject:[NSNumber numberWithInt:_lastUsedQuestionPointer] forKey:@"index"];
        if (!hasUsedQuestion) {
            [dict setObject:[NSNumber numberWithBool:YES] forKey:@"is_question"];
            hasUsedQuestion = YES;
        } else
        {
            [dict setObject:[NSNumber numberWithBool:NO] forKey:@"is_question"];
            [self incrementLastUsedQuestionPointer];
            hasUsedQuestion = NO;
        }
    }
}

- (id)initWithGridView:(NonScrollableGridView*)gv questionList:(NSMutableArray*)list questionType:(QuestionType)type numberOfCardsInGridView:(NSInteger)numCards
{
    self = [super init];
    if (self) {
        _expandedQuestionList = list;
        _grid_view = gv;
        _numberOfCardsInGridView = numCards;
        _numberOfQuestionsNeeded = _numberOfCardsInGridView/2;
        if (numCards % 2 != 0) {
            abort(); //Campulsory: even number of cards
        }
        
        _questionType = type;
        _answeredCardIndexPaths = [[NSMutableArray alloc] init];
        _dictForCurrentQuestionsOnView = [[NSMutableArray alloc] initWithCapacity:_numberOfCardsInGridView];
        [self initCurrentQuestionsOnView];
    }
    return self;
}

- (UIView*)viewForNonScrollableGridViewAtRowIndex:(NSInteger)rowIndex columnIndex:(NSInteger)columnIndex
{
    NSInteger targetIndex = rowIndex*_grid_view.numberOfColumns + columnIndex;
    
    NSString *toShowText = nil;
    UIImage *picToShow = nil;
    QuestionCard *aCard = [[QuestionCard alloc] initWithFrame:CGRectMake(0, 0, 200, 123)];
    GVIndexPath *indexPath = [GVIndexPath indexPathWithRow:rowIndex andColumn:columnIndex];
    
    NSDictionary *dict = [_dictForCurrentQuestionsOnView objectAtIndex:targetIndex];
    aCard.cardType = [[dict objectForKey:@"is_question"] boolValue] ? question : answer;
    aCard.arrayIndex = targetIndex; //card指向对应的数组
    
    Question *qn = [_expandedQuestionList objectAtIndex:[[dict objectForKey:@"index"] intValue]];
    if (aCard.cardType == question) {
        toShowText = qn.question_in_text;
    } else
    {
        if (_questionType == kTxtPlusPic) {
            picToShow = [UIImage imageWithData:qn.answer_in_image];
        } else
        {
            //Txt Plus Txt
            toShowText = qn.answer_in_text;
        }
    }
    
    aCard.associatedIndexPath = indexPath;
    
    UIImageView *bg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 180, 110)];
    bg.image = [UIImage imageNamed:@"card_bg_1"];
    bg.backgroundColor = [UIColor whiteColor];
//    bg.layer.borderWidth = 3.0f;
//    bg.layer.borderColor = [[UIColor orangeColor] CGColor];
//    bg.layer.cornerRadius = 0.0f;
    bg.center = aCard.center;
    [aCard addSubview:bg];
    [aCard sendSubviewToBack:bg];
    
    if (_questionType == kTxtPlusPic && aCard.cardType == answer) {
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:bg.frame];
        imgView.contentMode = UIViewContentModeScaleAspectFit;
        imgView.image = picToShow;
        [aCard insertSubview:imgView aboveSubview:bg];
    } else {
        //need to put txt
        UILabel *lbl = [[UILabel alloc] initWithFrame:bg.frame]; 
        lbl.numberOfLines = 0;
        lbl.lineBreakMode = UILineBreakModeWordWrap;
        lbl.center = aCard.center;
        lbl.font = [UIFont boldSystemFontOfSize:40];
        lbl.adjustsFontSizeToFitWidth = YES;
        lbl.minimumFontSize = 15;
        lbl.text = toShowText;
        lbl.textAlignment = UITextAlignmentCenter;
        lbl.backgroundColor = [UIColor clearColor];
        [aCard insertSubview:lbl aboveSubview:bg];
    }
    
    [aCard addTarget:self action:@selector(onUnitClicked:) forControlEvents:UIControlEventTouchUpInside];
    return aCard;
}

- (void)reloadAnsweredCardsHelper
{
    [self refillAnsweredQuestions];
    [_grid_view reloadUnitsWithIndexPathArray:_answeredCardIndexPaths withReloadMode:kGridViewReloadAnimationModeDefault];
    [_answeredCardIndexPaths removeAllObjects];
}

- (void)shrinkAnsweredCardsHelper
{
    [UIView animateWithDuration:0.5f 
                          delay:0.0f
                        options:UIViewAnimationOptionAllowUserInteraction
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
        
        [UIView animateWithDuration:0.15f 
                              delay:0.0f   
                            options:UIViewAnimationOptionAllowUserInteraction
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
    
        if (!_clickedBtnIndexPath) {
            _clickedBtnIndexPath = nowClickIndexPath;
        
        } else
        {
            _clickedBtnIndexPath = nil;
        }
    } else
    {
        //Clicked on second btn, react corrdingly
        QuestionCard *card1 = (QuestionCard*)[_grid_view viewForIndexPath:_clickedBtnIndexPath];
        
        if (card1.cardType == card.cardType) {
            //Same card type, revert pressed state
            card.pressed = NO;
            card1.pressed = NO;
            
            //Play DU sound
            if ([self.questionManagerDelegate respondsToSelector:@selector(QuestionManager:clickOnSameTypeCardsWithCard1:card2:)]) {
                [self.questionManagerDelegate QuestionManager:self clickOnSameTypeCardsWithCard1:card card2:(QuestionCard*)[_grid_view viewForIndexPath:_clickedBtnIndexPath]];
            }
            
            //Seet clicked to nil
            _clickedBtnIndexPath = nil;
            
        } else
        {
            BOOL answerCorrectly = NO;
            NSDictionary *dict1 = [_dictForCurrentQuestionsOnView objectAtIndex:card.arrayIndex];
            NSDictionary *dict2 = [_dictForCurrentQuestionsOnView objectAtIndex:card1.arrayIndex];
            NSInteger index1 = [[dict1 objectForKey:@"index"] intValue];
            NSInteger index2 = [[dict2 objectForKey:@"index"] intValue];
            if (index1 == index2) {
                answerCorrectly = YES;
            } else
            {
                Question *q1 = [_expandedQuestionList objectAtIndex:index1];
                Question *q2 = [_expandedQuestionList objectAtIndex:index2];
                if ([q1.answer_id isEqualToString:q2.answer_id]) {
                    answerCorrectly = YES;
                }
            }
            
            if (answerCorrectly) {
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
            } else
            {
                //Wrong answer
                //show cross and DU sound
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
                
                _clickedBtnIndexPath = nil;
            }
        }
    }
}

/*
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
//    [_questionList shuffle];
    
    [_grid_view reloadData];
}
*/

/*
- (void)flipAllCardsWithAnimation:(BOOL)animation
{
    if (isFlipCards) {
        NSArray *array = [_grid_view allUnits];
        for (QuestionCard *card in array) {
            [card flipCardWithDuration:0.5f completion:NULL];
        }
    }
}
 */

@end
