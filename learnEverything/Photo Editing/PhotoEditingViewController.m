//
//  PhotoEditingViewController.m
//  PhotoUploader
//
//  Created by Yuanfeng on 12-04-21.
//  Copyright (c) 2012 ____Yuanfeng Gao___. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "PhotoEditingViewController.h"
#import "AppDelegate.h"

@implementation PhotoEditingViewController

@synthesize delegate;

- (id)initWithImage:(UIImage*)image using3To4Ratio:(BOOL)is3To4
{
    
    self = [super initWithNibName:is3To4? @"PhotoEditingViewController_3To4Ratio" : @"PhotoEditingViewController_3To2Ratio" bundle:nil];
    if (self) {
        // Custom initialization
        _isUsing3To4Ratio = is3To4;
        _image = image;
        self.title = @"裁剪图片";
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _photoView = [[UIImageView alloc] initWithImage:_image];
    _photoView.contentMode = UIViewContentModeScaleAspectFit;
    _scroll_view = [[UIScrollView alloc] initWithFrame:self.view.frame];
    _photoView.frame = self.view.frame;
    [_scroll_view addSubview:_photoView];
    _scroll_view.delegate = self;
    _scroll_view.showsVerticalScrollIndicator = NO;
    _scroll_view.showsHorizontalScrollIndicator = NO;
    _scroll_view.bouncesZoom = YES;
    //give some margins to around the photo 

    //_scroll_view.contentSize = CGSizeMake(_photoView.image.size.width+300, _photoView.image.size.height+300);
    [self.view addSubview:_scroll_view];
    
    //calculate scale size needed
//    CGSize boundsSize = _scroll_view.bounds.size;
//    CGFloat xScale = boundsSize.width / _photoView.image.size.width;    // the scale needed to perfectly fit the image width-wise
//    CGFloat yScale = boundsSize.height / _photoView.image.size.width;  // the scale needed
//    CGFloat minScale = MIN(xScale, yScale); 
    _scroll_view.maximumZoomScale=10.0f;
    _scroll_view.minimumZoomScale=0.1f;
    _scroll_view.minimumZoomScale = 0.1f;
    
    [self.view bringSubviewToFront:upper_mask_view];
    [self.view bringSubviewToFront:lower_mask_view];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(onDoneClicked:)];
    [self.navigationItem setRightBarButtonItem:item];
}

- (void)viewDidUnload
{
    _photoView = nil;
    _scroll_view = nil;
    upper_mask_view = nil;
    lower_mask_view = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UIScrollView Delegate
- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    if (_scroll_view) {
        return _photoView;
    }
    return nil;
}


- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale
{
    if (scale < 1) { //Special case for scale less than 1, we need to center it
        scrollView.contentInset = UIEdgeInsetsMake(scrollView.center.y-view.center.y, scrollView.center.x-view.center.x,0,0);
    }
}

- (UIImage*)getViewShot
{
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)])
        UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, NO, [UIScreen mainScreen].scale);
    else
        UIGraphicsBeginImageContext(self.view.bounds.size);
    
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

#pragma mark - Bar Actions
- (void)onDoneClicked:(id)sender
{
    UIImage *croppedImage = [self getViewShot];
    CGRect imageCropRect;
    if (_isUsing3To4Ratio)
    {
        //execute cropping, here taking 360 as 540 for 3:4 ratio
        imageCropRect = CGRectMake(upper_mask_view.frame.origin.x+upper_mask_view.frame.size.width, 0, 360, 480);
    } else
    {
        //3:2 ratio, as 480 to 320
        imageCropRect = CGRectMake(0, upper_mask_view.frame.origin.y+upper_mask_view.frame.size.height, 480, 320);
    }

    CGImageRef imageRef = CGImageCreateWithImageInRect([croppedImage CGImage], imageCropRect);
    croppedImage = [UIImage imageWithCGImage:imageRef];
    
    [self.delegate PhotoEditingVC:self didFinishCropWithOriginalImage:_photoView.image editedImage:croppedImage];
}

@end
