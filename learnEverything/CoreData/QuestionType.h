//
//  QuestionType.h
//  learnEverything
//
//  Created by Yuanfeng on 12-07-02.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

enum QuestionType {
    kUnknownQuestionType = -1,
    kTxtPlusTxt = 0,
    kTxtPlusPic = 1
};

typedef enum QuestionType QuestionType;


enum QuestionSubType {
    subtype_UnknownQuestionSubType = -1,
    subtype_MathQuestion = 0,
    subtype_ChineseEnglishTranslation = 1,
    subtype_ChinesePicture = 2,
    subtype_EnglishPicture = 3
};

typedef enum QuestionSubType QuestionSubType;