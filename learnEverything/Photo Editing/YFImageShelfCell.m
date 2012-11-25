//
//  YFImageShelfCell.m
//  InklingChallenge
//
//  Created by Yuanfeng on 2012-10-01.
//  Copyright (c) 2012 Inkling. All rights reserved.
//

#import "YFImageShelfCell.h"

@implementation YFImageShelfCell
@synthesize imagesContainer = _imagesContainer;
@synthesize imageContainerOffsetFromCenter;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
//        UIImageView *backgroundImage = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Bookshelf_cell"]] autorelease];
//        backgroundImage.frame = self.bounds;
//        
//        self.backgroundView = backgroundImage;
//        self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth + UIViewAutoresizingFlexibleHeight;
        _imagesContainer = [[UIView alloc] initWithFrame:self.bounds];
        _imagesContainer.autoresizingMask = UIViewAutoresizingFlexibleHeight+UIViewAutoresizingFlexibleWidth;
//        _imagesContainer.backgroundColor = [UIColor blueColor];
        [self.contentView addSubview:_imagesContainer];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)prepareForReuse
{
    for (UIView *subview in _imagesContainer.subviews) {
        [subview removeFromSuperview];
    }
}

- (void)dealloc
{
    for (UIView *subview in _imagesContainer.subviews) {
        [subview removeFromSuperview];
    }
}

@end
