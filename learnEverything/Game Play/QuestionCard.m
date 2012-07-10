//
//  QuestionCardView.m
//  learnEverything
//
//  Created by Yuanfeng on 12-06-06.
//  Copyright (c) 2012 ____Yuanfeng Gao___. All rights reserved.
//

#import "QuestionCard.h"

@implementation QuestionCard
@synthesize cardType, associatedIndexPath;
@synthesize checkmark, wrongcross;
@synthesize arrayIndex;
@synthesize isShowingCardBack = _isShowingCardBack;
@synthesize pressed = _pressed;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        //Put a check mark for now
        checkmark = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmark"]];
        checkmark.contentMode = UIViewContentModeScaleAspectFit;
        checkmark.frame = self.frame;
        checkmark.frame = CGRectMake(0, 0, checkmark.frame.size.width, checkmark.frame.size.height);
        [self addSubview:checkmark];
        checkmark.hidden = YES;
        
        wrongcross = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"wrong_cross"]];
        wrongcross.contentMode = UIViewContentModeScaleAspectFit;
        wrongcross.frame = self.frame;
        wrongcross.frame = CGRectMake(0, 0, checkmark.frame.size.width, checkmark.frame.size.height);
        [self addSubview:wrongcross];
        wrongcross.hidden = YES;
    }
    return self;
}

- (void)flipCardWithDuration:(NSTimeInterval)duration completion:(void (^)(BOOL finished))completion
{
    if (!_isShowingCardBack) {
        [UIView transitionWithView:self 
                          duration:duration
                           options:UIViewAnimationOptionTransitionFlipFromRight + UIViewAnimationOptionAllowUserInteraction
                        animations:^(){
                            _cardBack.hidden = NO;
                            _isShowingCardBack = YES;
                        } 
                        completion:completion];
    } else
    {
        [UIView transitionWithView:self 
                          duration:duration
                           options:UIViewAnimationOptionTransitionFlipFromLeft + UIViewAnimationOptionAllowUserInteraction
                        animations:^(){
                            _cardBack.hidden = YES;
                            _isShowingCardBack = NO;
                        } 
                        completion:completion];
    }
}

- (void)setPressed:(BOOL)press
{
    _pressed = press;
    if (press) {
        [UIView animateWithDuration:0.1f animations:^{self.transform = CGAffineTransformMakeScale(0.75f, 0.75f);}];
    } else
    {
        [UIView animateWithDuration:0.1f animations:^{self.transform = CGAffineTransformIdentity;}];
    }
}

@end
