//
//  ShareOptionsTableViewController.h
//  learnEverything
//
//  Created by Yuanfeng on 12-07-03.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ShareOptionsTableViewControllerDataSourceAndDelegate <NSObject>
- (BOOL)isSwitchOnOnRow:(NSInteger)row;
- (void)didToggleSwitchOnRow:(NSInteger)row isOn:(BOOL)on;
- (void)didSelectCellOnIndexPath:(NSIndexPath*)indexPath;

@end

@interface ShareOptionsTableViewController : UITableViewController
@property (nonatomic, unsafe_unretained) id<ShareOptionsTableViewControllerDataSourceAndDelegate> customDelegate;
@end
