//
//  GridView.h
//  adminapp
//
//  Created by Yuanfeng on 12-04-18.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

//---------------------------------
//Grid View Delegate and DataSource
//---------------------------------
@class YFGridView;

@protocol YFGridViewDelegate <NSObject>
@optional
- (void)gridView:(YFGridView*)gridView didSelectViewAtColumIndex:(NSInteger)index ofIndexPath:(NSIndexPath*)indexPath;
- (UIView*)gridView:(YFGridView*)gridView viewForHeaderAtIndex:(NSInteger)headerIndex atSection:(NSInteger)section;
- (CGFloat)gridView:(YFGridView*)gridView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
- (CGFloat)gridView:(YFGridView*)gridView heightForHeaderInSection:(NSInteger)section;
- (UIView*)gridView:(YFGridView*)gridView viewForHeaderInSection:(NSInteger)section;
@end

@protocol YFGridViewDataSource <NSObject>
@required
- (NSInteger)gridView:(YFGridView*)gridView numberOfRowsInSection:(NSInteger)section;
- (NSInteger)gridView:(YFGridView*)gridView numberOfColumnsForRow:(NSIndexPath*)indexPath;
@optional
- (NSInteger)numberOfSectionsInGridView:(YFGridView*)gridView;
//- (CGFloat)gridView:(GridView*)gridView widthForColumnAtIndex:(NSInteger)index atIndexPath:(NSIndexPath*)indexPath;
- (UIView*)gridView:(YFGridView*)gridView viewForColumnAtIndex:(NSInteger)index atIndexPath:(NSIndexPath*)indexPath;
- (UIView*)gridView:(YFGridView *)gridView selectedBackgroundViewForIndexPath:(NSIndexPath*)indexPath;
@end

//---------------------------------
//Grid View
//---------------------------------
enum GridViewLayoutStyle {
    GridViewAlwaysCenterContent = 0,
    GridViewAlwaysExpandCellWidth = 1
    };

typedef enum GridViewLayoutStyle GridViewLayoutStyle;

@interface YFGridView : UITableView <UITableViewDataSource, UITableViewDelegate>
{
    GridViewLayoutStyle _layoutStyle;
}

/**
 * The only method to be used for init GridView
 * GridViewAlwaysCenterContent means when width of table expands, content is always centered
 * GridViewAlwaysExpandCellWidth means when witdth expands, width of each view in column is expanded accordingly
 */
- (id)initWithFrame:(CGRect)frame layoutStyle:(GridViewLayoutStyle)style;

@property (nonatomic, unsafe_unretained) id<YFGridViewDataSource> gvDatasource;
@property (nonatomic, unsafe_unretained) id<YFGridViewDelegate> gvDelegate;

@end

//---------------------------------
//Grid View Cell Delegate
//---------------------------------
@class GridViewCell;
@protocol GridViewCellDelegate <NSObject>
@optional
- (CGFloat)GridViewCell:(GridViewCell*)cell widthForColumnAtIndex:(int)index; //TODO never implemented before
@end

//---------------------------------
//Grid View Cell
//---------------------------------
@interface GridViewCell : UITableViewCell {
    NSMutableArray *_columns;
    GridViewLayoutStyle _layoutStyle;
}

- (id)initWithLayoutStyle:(GridViewLayoutStyle)style reuseIdentifier:(NSString *)reuseIdentifier;
- (void)clearColumns;

@property (nonatomic, unsafe_unretained) id<GridViewCellDelegate> delegate;
//@property CGColorRef *columnSeperatorColor;
@property UITableViewCellSeparatorStyle columSeperatorStyle;
@property UITableViewCellSeparatorStyle rowSeperatorStyle;
@property CGFloat columnSeperatorWidth;
@property (nonatomic, retain) NSMutableArray *columns;

@end