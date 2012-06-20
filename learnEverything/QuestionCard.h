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

@property (nonatomic, strong) UIImageView *checkmark;

@property (nonatomic, strong) GVIndexPath *associatedIndexPath;

@property cardType cardType;

@property NSInteger questionIndex;
@end
