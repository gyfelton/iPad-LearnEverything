//
//  YFGridView.m
//  adminapp
//
//  Created by Yuanfeng on 12-04-18.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "YFGridView.h"

@implementation YFGridView
@synthesize gvDelegate,gvDatasource;

- (id)initWithFrame:(CGRect)frame layoutStyle:(GridViewLayoutStyle)style
{
    self = [super initWithFrame:frame style:UITableViewStylePlain]; //should always be plain for now
    if (self)
    {
        //We draw the separator line later....
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        _layoutStyle = style;
        self.delegate = self;
        self.dataSource = self;
    }
    return self;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ([self.gvDelegate respondsToSelector:@selector(gridView:heightForHeaderInSection:)]) {
        return [self.gvDelegate gridView:self heightForHeaderInSection:section];
    }
    return 0;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if ([self.gvDelegate respondsToSelector:@selector(gridView:viewForHeaderInSection:)]) {
        return [self.gvDelegate gridView:self viewForHeaderInSection:section];
    } else if ([self.gvDelegate respondsToSelector:@selector(gridView:viewForHeaderAtIndex:atSection:)])
    {
        GridViewCell *cell = [[GridViewCell alloc] initWithLayoutStyle:_layoutStyle reuseIdentifier:@"GridViewCell_header"];
        [cell clearColumns];
        NSInteger columnCount = [self.gvDatasource gridView:self numberOfColumnsForRow:[NSIndexPath indexPathForRow:0 inSection:section]]; //TODO refractor, should not use indexPath right?
        CGFloat startingPointX = 0;//the x coord for each view
        for (int i=0; i<columnCount; i++) {
            UIView *view = [self.gvDelegate gridView:self viewForHeaderAtIndex:i atSection:section];
            view.frame = CGRectMake(startingPointX, view.frame.origin.y, view.frame.size.width, view.frame.size.height);
            startingPointX += view.frame.size.width;
            [cell.columns addObject:view];
            [cell.contentView addSubview:view];
        }
        cell.backgroundColor = [UIColor clearColor];
        return cell;
    }
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([gvDatasource respondsToSelector:@selector(numberOfSectionsInGridView:)]) {
        return [gvDatasource numberOfSectionsInGridView:self];
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [gvDatasource gridView:self numberOfRowsInSection:section];
}
            
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GridViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GridViewCell"];
    if (!cell) {
        cell = [[GridViewCell alloc] initWithLayoutStyle:_layoutStyle reuseIdentifier:@"GridViewCell"];
    }
    [cell clearColumns];
    NSInteger columnCount = [self.gvDatasource gridView:self numberOfColumnsForRow:indexPath];
    CGFloat startingPointX = 0;//the x coord for each view
    for (int i=0; i<columnCount; i++) {
        UIView *view = [self.gvDatasource gridView:self viewForColumnAtIndex:i atIndexPath:indexPath];
        view.frame = CGRectMake(startingPointX, view.frame.origin.y, view.frame.size.width, view.frame.size.height);
        startingPointX += view.frame.size.width;
        [cell.columns addObject:view];
        [cell.contentView addSubview:view];
    }
    if ([self.gvDatasource respondsToSelector:@selector(gridView:selectedBackgroundViewForIndexPath:)]) {
        cell.selectedBackgroundView = [self.gvDatasource gridView:self selectedBackgroundViewForIndexPath:indexPath];
    }
    return cell;
}

@end

@implementation GridViewCell
@synthesize delegate;
@synthesize columns,columSeperatorStyle,columnSeperatorWidth, rowSeperatorStyle;

- (id)initWithLayoutStyle:(GridViewLayoutStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        _layoutStyle = style;
        self.columns = [[NSMutableArray alloc] init];
        self.columSeperatorStyle = UITableViewCellSeparatorStyleSingleLine;
        self.rowSeperatorStyle = UITableViewCellSeparatorStyleSingleLine;
        self.columnSeperatorWidth = 0.25f;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)clearColumns
{
    for (UIView *view in self.columns) {
        [view removeFromSuperview];
    }
    [self.columns removeAllObjects];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (_layoutStyle == GridViewAlwaysCenterContent) {
        CGFloat totalWidth = 0;
        for (UIView *view in self.columns)
        {
            totalWidth += view.frame.size.width;
        }
        
        CGFloat startingX = self.contentView.frame.size.width - totalWidth;
        startingX /= 2;
        startingX = startingX<0?0:startingX; //if totalWidth is longer than contentView width, align first view to first
        for (UIView *view in self.columns)
        {
            view.frame = CGRectMake(startingX, view.frame.origin.y, view.frame.size.width, view.frame.size.height);
            startingX += view.frame.size.width;
        }
    } else if (_layoutStyle == GridViewAlwaysExpandCellWidth)
    {
        //TODO expand cell width is not good
        CGFloat totalWidth;
        for (UIView *view in self.columns)
        {
            totalWidth += view.frame.size.width;
        }
        
        CGFloat extraWidth = self.contentView.frame.size.width - totalWidth;
        extraWidth = extraWidth<0?0:extraWidth; //if totalWidth is longer than contentView width, align first view to first
        extraWidth /= [self.columns count]; //give each cell a share of extra width;
        CGFloat startingX = 0;
        for (UIView *view in self.columns)
        {
            view.frame = CGRectMake(startingX, view.frame.origin.y, view.frame.size.width+extraWidth, view.frame.size.height);
            startingX += view.frame.size.width;
        }
    }
}

- (void)drawRect:(CGRect)rect {
    if (self.columSeperatorStyle != UITableViewCellSeparatorStyleNone) {
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        // Use the same color and width as the default cell separator for now
        CGContextSetRGBStrokeColor(ctx, 0.5, 0.5, 0.5, 1.0);
        CGContextSetLineWidth(ctx, self.columnSeperatorWidth);
        
        CGFloat startingPointX = 0;
        for (int i = 0; i < [self.columns count]; i++) {
            UIView *view =  [self.columns objectAtIndex:i];
            startingPointX = view.frame.origin.x;
            CGContextMoveToPoint(ctx, startingPointX, 0);
            //Add the vertical line
            CGContextAddLineToPoint(ctx, startingPointX, self.bounds.size.height);
            //NSLog(@"drawline at %f", startingPointX);
            
            if (self.rowSeperatorStyle == UITableViewCellSeparatorStyleSingleLine) {
                //Draw bottom line
                CGContextMoveToPoint(ctx, startingPointX, self.bounds.size.height);
                CGContextAddLineToPoint(ctx, startingPointX+view.frame.size.width, self.bounds.size.height);
            }
        }
        //add one at the end
        if ([self.columns lastObject]) {
            UIView *v = [self.columns lastObject];
            startingPointX+= v.frame.size.width;
            CGContextMoveToPoint(ctx, startingPointX, 0);
            CGContextAddLineToPoint(ctx, startingPointX, self.bounds.size.height);
            //NSLog(@"drawline at %f", startingPointX);
        }
        
        CGContextStrokePath(ctx);
    }
    
    [super drawRect:rect];
}
@end
