//
//  YFImageShelfCell.h
//  InklingChallenge
//
//  Created by Yuanfeng on 2012-10-01.
//  Copyright (c) 2012 Inkling. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YFImageShelfCell : UITableViewCell
{
    UIView *_imagesContainer;
}
@property CGPoint imageContainerOffsetFromCenter;
@property (nonatomic, readonly) UIView* imagesContainer;
@end
