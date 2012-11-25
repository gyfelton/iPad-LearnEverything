//
//  ImageSearchViewController.h
//  learnEverything
//
//  Created by Yuanfeng on 2012-11-23.
//
//

#import <UIKit/UIKit.h>
#import "SDWebImageDownloaderDelegate.h"
#import "MBProgressHUD.h"
#import "SDWebImageDownloader.h"

@interface ImageSearchViewController : UIViewController<SDWebImageDownloaderDelegate, UITableViewDataSource, UITableViewDelegate>
{
    MBProgressHUD *_hud;
    NSArray *_searchStringArray;
    
    NSMutableArray *_resultArray;
    
    int _imagesPerRow;
    
    int _currentNumberofPages;
    
    SDWebImageDownloader *_imageDownloader;
}

- (id)initWithSearchStringArray:(NSArray*)array delegate:(id<UIImagePickerControllerDelegate>)delegate;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, unsafe_unretained) id<UIImagePickerControllerDelegate>delegate;
@end
