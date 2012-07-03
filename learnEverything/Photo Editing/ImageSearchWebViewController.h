//
//  WebViewController.h
//  adminapp
//
//  Created by Yuanfeng on 12-04-11.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDWebImageDownloaderDelegate.h"
#import "MBProgressHUD.h"

#define USER_DID_CHOOSE_IMAGE_NOTIFICATION @"USER_DID_CHOOSE_IMAGE_NOTIFICATION"

@interface ImageSearchWebViewController : UIViewController <UIWebViewDelegate, SDWebImageDownloaderDelegate>
{
    NSArray *_searchStringArray;
    UIWebView *_webView;
    MBProgressHUD *_hud;
    SDWebImageDownloader *_imageDownloader;
}
- (id)initWithSearchStringArray:(NSArray*)array delegate:(id<UIImagePickerControllerDelegate>)delegate;

@property (nonatomic, unsafe_unretained) id<UIImagePickerControllerDelegate>delegate;
@end
