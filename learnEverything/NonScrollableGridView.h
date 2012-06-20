//
//  NonScrollableGridView.h
//  learnEverything
//
//  Created by Yuanfeng on 12-06-04.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NonScrollableGridView;
@protocol NonScrollableGridViewDataSource <NSObject>

@required
- (NSInteger)numberOfRowsForNonScrollableGridView:(NonScrollableGridView*)gridView;
- (NSInteger)numberOfColumnsForNonScrollableGridView:(NonScrollableGridView*)gridView;
- (UIView*)viewForNonScrollableGridView:(NonScrollableGridView*)gridView atRowIndex:(NSInteger)rowIndex columnIndex:(NSInteger)columnIndex;

@optional
- (CGFloat)widthForEachUnit:(NonScrollableGridView*)gridView;
- (CGFloat)heightForEachUnit:(NonScrollableGridView*)gridView;

@end

@interface GVIndexPath : NSObject
{
    NSInteger _row;
    NSInteger _column;
}

- (GVIndexPath*)initIndexPathWithRow:(NSInteger)row andColumn:(NSInteger)column;
+ (GVIndexPath*)indexPathWithRow:(NSInteger)row andColumn:(NSInteger)column;

@property (nonatomic, readonly) NSInteger row;
@property (nonatomic, readonly) NSInteger column;
@end

enum GridViewAnimationType {
    kGridViewAnimationFlowFromBottom = 0,
    kGridViewAnimationFlowFromTop = 1
    };
typedef enum GridViewAnimationType GridViewAnimationType;

/**
 If you want to make it Scrollable, better just put this on the scrollView
 */
@interface NonScrollableGridView : UIView
{
    NSMutableArray *_unitDictArray; //A Dictionary containing the view and its corresponding GVIndexPath
    
    NSInteger _numberOfRows;
    NSInteger _numberOfColumns;
}

- (void)reloadData;
- (GVIndexPath*)indexPathForUnitView:(UIView*)view;
- (UIView*)viewForIndexPath:(GVIndexPath*)indexPath;
- (void)layoutUnitsAnimatedWithAnimationDirection:(GridViewAnimationType)animationType;

@property (nonatomic, unsafe_unretained) id<NonScrollableGridViewDataSource> dataSource;
@property NSInteger numberOfRows;
@property NSInteger numberOfColumns;
@end
