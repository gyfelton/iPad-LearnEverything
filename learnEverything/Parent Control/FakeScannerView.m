//
//  FakeScannerView.m
//  fakeFingerPrintScanner
//
//  Created by Yuanfeng on 12-03-23.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FakeScannerView.h"

@implementation FakeScannerView
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

#define RECT_WIDTH 140
#define RECT_HEIGHT 210

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    //TODO handle rotation problem
//    CGContextRef context = UIGraphicsGetCurrentContext(); 
//    //CGRect rectangle = CGRectMake(self.center.x-RECT_WIDTH/2, self.center.y-RECT_HEIGHT/2-20, RECT_WIDTH, RECT_HEIGHT);
//    CGContextSetLineCap(context, kCGLineCapRound);
//    CGContextStrokeRectWithWidth(context, rect, 6);
}

- (BOOL)_isAdultFinger:(NSSet*)touches
{
    UITouch *touch = [touches anyObject];
    float vf = 10.0f; 
    id valFloat = [touch valueForKey:@"pathMajorRadius"]; 
    if(valFloat != nil) {
        vf = [valFloat floatValue]; 
    }
    //NSLog(@"touch begin: count: %d, radius: %f", [[event allTouches] count],vf);
    if (vf > 10.0f) {
        return YES;
    }
    return NO;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [delegate respondsToSelector:@selector(didBeginDetectFinger:)] ? [delegate didBeginDetectFinger:[self _isAdultFinger:touches]] : nil;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [delegate respondsToSelector:@selector(didDetectFingerMoving:)] ? [delegate didBeginDetectFinger:[self _isAdultFinger:touches]] : nil;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [delegate didEndDetectFinger];
}

@end
