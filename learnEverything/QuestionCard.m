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
@synthesize checkmark, wrongcross;
@synthesize questionIndex;
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
        
        _cardBack = [[UIImageView alloc] initWithFrame:frame];
        _cardBack.frame = CGRectMake(0, 0, _cardBack.frame.size.width, _cardBack.frame.size.height);
        _cardBack.image = [UIImage imageNamed:@"card_back"];
        [self addSubview:_cardBack];
        _cardBack.hidden = YES;
        
//        [self setBackgroundImage:[UIImage imageNamed:@"wood_bg"] forState:UIControlStateNormal];
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

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)setPressed:(BOOL)press
{
    _pressed = press;
    if (press) {
        [UIView animateWithDuration:0.1f animations:^{self.transform = CGAffineTransformMakeScale(0.8f, 0.8f);}];
    } else
    {
        [UIView animateWithDuration:0.1f animations:^{self.transform = CGAffineTransformIdentity;}];
    }
}

@end
