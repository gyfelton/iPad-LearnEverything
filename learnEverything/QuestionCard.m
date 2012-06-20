//
//  QuestionCardView.m
//  learnEverything
//
//  Created by Yuanfeng on 12-06-06.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "QuestionCard.h"

@implementation QuestionCard
@synthesize cardType, associatedIndexPath;
@synthesize checkmark;
@synthesize questionIndex;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        [self setBackgroundImage:[UIImage imageNamed:@"green1"] forState:UIControlStateSelected];
        
        //Put a check mark for now
        checkmark = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmark"]];
        checkmark.contentMode = UIViewContentModeScaleAspectFit;
        checkmark.frame = self.frame;
        checkmark.frame = CGRectMake(0, 0, checkmark.frame.size.width, checkmark.frame.size.height);
        [self addSubview:checkmark];
        checkmark.hidden = YES;
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
