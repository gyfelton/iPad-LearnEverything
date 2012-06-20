//
//  NonScrollableGridView.m
//  learnEverything
//
//  Created by Yuanfeng on 12-06-04.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NonScrollableGridView.h"

@implementation GVIndexPath
@synthesize row = _row, column = _column;
- (GVIndexPath*)initIndexPathWithRow:(NSInteger)r andColumn:(NSInteger)c
{
    self = [super init];
    if (self) {
        _row = r;
        _column = c;
    }
    return self;
}

+ (GVIndexPath*)indexPathWithRow:(NSInteger)row andColumn :(NSInteger)column
{
    return [[GVIndexPath alloc] initIndexPathWithRow:row andColumn:column];
}

@end

@implementation NonScrollableGridView
@synthesize dataSource;
@synthesize numberOfRows = _numberOfRows, numberOfColumns = _numberOfColumns;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _unitDictArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)reloadData
{
    //Clear away old views
    for (NSDictionary *dict in _unitDictArray) {
        UIView *view = [dict objectForKey:@"view"];
        [view removeFromSuperview];
    }
    [_unitDictArray removeAllObjects];
    
    NSInteger row = [self.dataSource numberOfRowsForNonScrollableGridView:self];
    _numberOfRows = row;
    NSInteger column = [self.dataSource numberOfColumnsForNonScrollableGridView:self];
    _numberOfColumns = column;
      
    if ([self.dataSource respondsToSelector:@selector(widthForEachUnit:)] && [self.dataSource respondsToSelector:@selector(heightForEachUnit:)]) {
        CGFloat width = [self.dataSource widthForEachUnit:self];
        CGFloat height = [self.dataSource heightForEachUnit:self];
        
        for (int r = 0; r<row; r++) {
            for (int c = 0; c<column; c++) {
                CGFloat xBaseValue = self.frame.size.width-column*width;
                xBaseValue/=2;
                CGFloat yBaseValue = self.frame.size.height-row*height;
                yBaseValue/=2;
                CGFloat xOrigin = xBaseValue+width*c;
                CGFloat yOrigin = yBaseValue+height*r;
                
                UIView *unit = [self.dataSource viewForNonScrollableGridView:self atRowIndex:r columnIndex:c];
                unit.frame = CGRectMake(xOrigin+(width-unit.frame.size.width)/2, yOrigin+(height-unit.frame.size.height), unit.frame.size.width, unit.frame.size.height);
                
                [self addSubview:unit];
                
                //Construct the relating info into a dictionary and store it
                NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:unit, @"view", [GVIndexPath indexPathWithRow:r andColumn:c], @"indexPath", nil];
                [_unitDictArray addObject:dict];
            }
        }
    } else
    {
        //TODO do automatic calculation
    }
}

- (void)layoutSubviews
{
//    [self reloadData];
}

- (GVIndexPath*)indexPathForUnitView:(UIView *)view
{
    for (NSDictionary *dict in _unitDictArray) {
        UIView *v = [dict objectForKey:@"view"];
        if (v == view) {
            GVIndexPath *indexPath = [dict objectForKey:@"indexPath"];
            return indexPath;
        }
    }
    return nil;
}

- (UIView*)viewForIndexPath:(GVIndexPath *)indexPath
{
    for (NSDictionary *dict in _unitDictArray) {
        GVIndexPath *ip = [dict objectForKey:@"indexPath"];
        if (ip.row == indexPath.row && ip.column == indexPath.column) {
            UIView *view = [dict objectForKey:@"view"];
            return view;
        }
    }
    return nil;
}

- (void)layoutUnitsAnimatedWithAnimationDirection:(GridViewAnimationType)animationType
{
    if (animationType == kGridViewAnimationFlowFromBottom) {
        //First, shift all elements down
        for (NSDictionary *dict in _unitDictArray) {
            UIView *view = [dict objectForKey:@"view"];
            view.frame = CGRectOffset(view.frame, 0, self.frame.size.height);
        }
        
        //Next, put them back in a animated way
        CGFloat delay = 0.0f;
        NSInteger index = 0;
        for (NSDictionary *dict in _unitDictArray) {
            UIView *view = [dict objectForKey:@"view"];
            delay = 0.1f + index%_numberOfColumns*0.1f;
            [UIView animateWithDuration:0.4f 
                                  delay:delay
                                options:UIViewAnimationOptionAllowAnimatedContent 
                             animations:^(){
                                 view.frame = CGRectOffset(view.frame, 0, -1*self.frame.size.height);
                             }
                             completion:^(BOOL finished){}];
            index++;
        }
    }
}

@end
