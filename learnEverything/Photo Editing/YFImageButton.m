//
//  YFImageButton.m
//  InklingChallenge
//
//  Created by Yuanfeng on 2012-10-02.
//  Copyright (c) 2012 Inkling. All rights reserved.
//

#import "YFImageButton.h"

@implementation YFImageButton
@synthesize dictionary;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)dealloc
{
    self.dictionary = nil;
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
