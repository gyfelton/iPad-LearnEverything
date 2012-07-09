//
//  SimulatePressButton.m
//  learnEverything
//
//  Created by Yuanfeng on 12-07-08.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SimulatePressButton.h"

@implementation SimulatePressButton 

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    if (highlighted) {
        [UIView animateWithDuration:0.1f delay:0.0f options:UIViewAnimationOptionAllowUserInteraction animations:^{self.transform = CGAffineTransformMakeScale(0.9f, 0.9f);} completion:^(BOOL finished) {
        }];
    } else
    {
        [UIView animateWithDuration:0.05f animations:^{self.transform = CGAffineTransformIdentity;}];
    }
}

@end
