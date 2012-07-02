//
//  PhotoEditingViewController.h
//  PhotoUploader
//
//  Created by Yuanfeng on 12-04-21.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PhotoEditingViewController;

@protocol PhotoEditingViewControllerDelegate <NSObject>
@required
- (void)PhotoEditingVC:(PhotoEditingViewController*)vc didFinishCropWithOriginalImage:(UIImage*)originalImg editedImage:(UIImage*)editedImg;

@end

@interface PhotoEditingViewController : UIViewController <UIScrollViewDelegate>
{
    UIImage *_image;
    UIImageView *_photoView;
    UIScrollView *_scroll_view;
    IBOutlet UIView *upper_mask_view;
    IBOutlet UIView *lower_mask_view;
}

- (id)initWithImage:(UIImage*)image;

@property (nonatomic, unsafe_unretained) id<PhotoEditingViewControllerDelegate> delegate;
@end
