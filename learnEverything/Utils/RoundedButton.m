//
//  RoundedButton.m
//  learnEverything
//
//  Created by Yuanfeng on 12-06-28.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "RoundedButton.h"

@implementation RoundedButton

- (id)initButtonWithFrame:(CGRect)frame
{
    self = [UIButton buttonWithType:UIButtonTypeCustom];
    if (self) {
        self.frame = frame;
        self.titleLabel.font = [UIFont regularChineseFontWithSize:32];
        self.layer.cornerRadius = 20;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext(); 
    //    //CGRect rectangle = CGRectMake(self.center.x-RECT_WIDTH/2, self.center.y-RECT_HEIGHT/2-20, RECT_WIDTH, RECT_HEIGHT);
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetStrokeColorWithColor(context, [[UIColor redColor] CGColor]);
    CGContextStrokeRectWithWidth(context, rect, 6);

}

@end
