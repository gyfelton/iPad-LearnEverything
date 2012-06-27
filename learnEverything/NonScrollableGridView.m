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
        _unitDictSet = [[NSMutableSet alloc] init];
    }
    return self;
}

- (void)_addUnitToSubviewHelper:(UIView*)unit indexPath:(GVIndexPath*)ip
{
    [self addSubview:unit];
    
    //Construct the relating info into a dictionary and store it
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:unit, @"view", ip, @"indexPath", [NSValue valueWithCGRect:unit.frame], @"frame", nil];
    [_unitDictSet addObject:dict];
}

- (void)reloadData
{
    //Clear away old views
    for (NSDictionary *dict in _unitDictSet) {
        UIView *view = [dict objectForKey:@"view"];
        [view removeFromSuperview];
    }
    [_unitDictSet removeAllObjects];
    
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
                [self _addUnitToSubviewHelper:unit indexPath:[GVIndexPath indexPathWithRow:r andColumn:c]];
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

- (NSArray*)allUnits
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (NSDictionary *dict in _unitDictSet) {
        UIView *v = [dict objectForKey:@"view"];
        [array addObject:v];
    }
    return [NSArray arrayWithArray:array];
}

- (GVIndexPath*)indexPathForUnitView:(UIView *)view
{
    for (NSDictionary *dict in _unitDictSet) {
        UIView *v = [dict objectForKey:@"view"];
        if (v == view) {
            GVIndexPath *indexPath = [dict objectForKey:@"indexPath"];
            return indexPath;
        }
    }
    return nil;
}

- (NSDictionary *)_dictionaryForIndexPath:(GVIndexPath*)indexPath
{
    for (NSDictionary *dict in _unitDictSet) {
        GVIndexPath *ip = [dict objectForKey:@"indexPath"];
        if (ip.row == indexPath.row && ip.column == indexPath.column) {
            return dict;
        }
    }
    return nil;
}

- (UIView*)viewForIndexPath:(GVIndexPath *)indexPath
{
    UIView *view = [[self _dictionaryForIndexPath:indexPath] objectForKey:@"view"];
    return view;
}

- (void)layoutUnitsAnimatedWithAnimationDirection:(GridViewAnimationType)animationType
{
    if (animationType == kGridViewAnimationFlowFromBottom) {
        //First, shift all elements down
        for (NSDictionary *dict in _unitDictSet) {
            UIView *view = [dict objectForKey:@"view"];
            view.frame = CGRectOffset(view.frame, 0, self.frame.size.height);
        }
        
        //Next, put them back in a animated way
        CGFloat delay = 0.0f;
        for (NSDictionary *dict in _unitDictSet) {
            UIView *view = [dict objectForKey:@"view"];
            GVIndexPath *ip = [dict objectForKey:@"indexPath"];
            delay = 0.1f + ip.column/self.numberOfColumns * 0.1f;
            [UIView animateWithDuration:0.4f 
                                  delay:delay
                                options:UIViewAnimationOptionAllowAnimatedContent 
                             animations:^(){
                                 view.frame = CGRectOffset(view.frame, 0, -1*self.frame.size.height);
                             }
                             completion:^(BOOL finished){}];
        }
    }
}

- (void)reloadUnitsWithIndexPathArray:(NSArray*)array withReloadMode:(GridViewReloadAnimationModes)mode
{
    for (GVIndexPath *ip in array) {
        NSDictionary *dict = [self _dictionaryForIndexPath:ip];
        UIView *old = [dict objectForKey:@"view"];
        CGRect frame;
        [[dict objectForKey:@"frame"] getValue:&frame];
        [old removeFromSuperview];
        [_unitDictSet removeObject:dict];

        //Now ask for new unit
        UIView *new = [self.dataSource viewForNonScrollableGridView:self atRowIndex:ip.row columnIndex:ip.column];
        new.frame = frame;
        [self _addUnitToSubviewHelper:new indexPath:ip];
        
        //Animate if needed
        if (mode != kGridViewReloadAnimationModeNone) {
            //default for now
            new.transform = CGAffineTransformMakeScale(0.01f, 0.01f);
            [UIView animateWithDuration:0.5f 
                             animations:^(){
                                 new.transform = CGAffineTransformIdentity;
            }];
        }
    }
}

@end
