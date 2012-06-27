//
//  QuestionCardView.h
//  learnEverything
//
//  Created by Yuanfeng on 12-06-06.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NonScrollableGridView.h"

enum cardType {
    question = 0,
    answer = 1
    };

typedef enum cardType cardType;

@interface QuestionCard : UIButton
{
    UIImageView *_cardBack;
    BOOL _isShowingCardBack;
    BOOL _pressed;
}

@property (nonatomic, strong) UIImageView *checkmark;
@property (nonatomic, strong) UIImageView *wrongcross;

@property (nonatomic, strong) GVIndexPath *associatedIndexPath;

@property cardType cardType;

@property NSInteger questionIndex;

@property BOOL isShowingCardBack;

@property (nonatomic, setter = setPressed:) BOOL pressed;

- (void)flipCardWithDuration:(NSTimeInterval)duration completion:(void (^)(BOOL finished))completion;

@end
