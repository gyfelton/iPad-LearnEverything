//
//  ImageSearchViewController.m
//  learnEverything
//
//  Created by Yuanfeng on 2012-11-23.
//
//

#import "ImageSearchViewController.h"
#import "BingImageSearchAPIWrapper.h"
#import "UIButton+WebCache.h"
#import "YFImageShelfCell.h"
#import "YFImageButton.h"

@interface ImageSearchViewController ()

@end

@implementation ImageSearchViewController
@synthesize tableView;

- (id)initWithSearchStringArray:(NSArray*)array delegate:(id<UIImagePickerControllerDelegate>)d;
{
    self = [super init];
    if (self) {
        // Custom initialization
        self.delegate = d;
        _searchStringArray = array;
        self.title = @"Bing Image Search"; //必应图片搜索
        _resultArray = [[NSMutableArray alloc] init];
        
        _imagesPerRow = 3;
        
        _currentNumberofPages = 0;
    }
    return self;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    _imageDownloader.delegate = nil;
    [_imageDownloader cancel];
}

- (void)requestImages:(int)currentPageNum
{
    [[BingImageSearchAPIWrapper sharedInstance] requestBingImageSearchInJSONWithQueryStringArray:_searchStringArray appID:@"BFRBMAgLq6XpoU7WTC2vN/5WB6GvzNe7PEfIWENGj1k=" numberOfImagesPerPage:18 currentPageNumberStartFrom0:currentPageNum completionBlock:^(id parsedJSONObject) {
        NSDictionary *dict = [parsedJSONObject objectForKey:@"d"];
        
        NSArray *result_array = [dict objectForKey:@"results"];
        if (!result_array) {
            [self displayErrorMessage];
        }
        [_resultArray addObjectsFromArray:result_array];
        
        [self.tableView reloadData];
        
        [_hud hide:NO];
        self.tableView.hidden = NO;
    } failedBlock:^(NSError *error) {
        [self displayErrorMessage];
    } usingCachedDataBlock:^(id parsedJSONObject) {
        //Nothing cached for now
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth+UIViewAutoresizingFlexibleHeight;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.view addSubview:self.tableView];
	// Do any additional setup after loading the view.
    _hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:_hud];
    self.tableView.hidden = YES;
//    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self requestImages:_currentNumberofPages];
}

- (void)displayErrorMessage
{
    //TODO
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    _hud.labelText = @"Loading...";
    [_hud show:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Helpers
- (NSString*)retrieveThumbnailURL:(NSDictionary*)dict
{
    NSDictionary *d = [dict objectForKey:@"Thumbnail"];
    return [d objectForKey:@"MediaUrl"];
}

- (void)onThumbnailClicked:(YFImageButton*)image
{
    NSDictionary *dict = image.dictionary;
    NSString *imgURL = [dict objectForKey:@"MediaUrl"];
    
    if (_imageDownloader)
    {
        [_imageDownloader cancel];
        _imageDownloader.delegate = nil;
        _imageDownloader = nil;
    }
    _imageDownloader = [SDWebImageDownloader downloaderWithURL:[NSURL URLWithString:imgURL] delegate:self];
    _hud.labelText = @"Downloading Image..."; //下载图片中...
    [_hud show:YES];
}

#pragma mark - Lazy Loading

- (void)loadDataForOnscreenRows
{
    NSArray *array = [self.tableView indexPathsForVisibleRows];
    for (NSIndexPath *indexPath in array) {
        YFImageShelfCell *cell = (YFImageShelfCell*)[self.tableView cellForRowAtIndexPath:indexPath];
        if ([cell isKindOfClass:[YFImageShelfCell class]]) {
            for (UIView *subview in cell.imagesContainer.subviews) {
                if ([subview isKindOfClass:[YFImageButton class]]) {
                    YFImageButton *image = (YFImageButton*)subview;
                    [image setImageWithURL:[NSURL URLWithString:[self retrieveThumbnailURL:image.dictionary]] placeholderImage:[UIImage imageNamed:@"question_list_default_pic"]];
                    //[image addTarget:self action:@selector(onThumbnailClicked:) forControlEvents:UIControlEventTouchUpInside];
                }
            }
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        //load images
        [self loadDataForOnscreenRows];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    //load images
    [self loadDataForOnscreenRows];
}

#pragma mark - UITableView Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row * _imagesPerRow >= [_resultArray count]) {
        return 66;
    }
    return 106;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row * _imagesPerRow >= [_resultArray count]) {
        _currentNumberofPages++;
        [self requestImages:_currentNumberofPages];
    }
}

#pragma mark - UITableView Datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //Get the ceiling of the number
    double countTemp = [_resultArray count]*1.0f / (_imagesPerRow*1.0f);
    int count = ceil(countTemp);
    
    return count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"ImageCell";
    
    int row = indexPath.row;
    if (row*_imagesPerRow >= [_resultArray count]) {
        static NSString *loadMoreCellIdentifier = @"loadMoreCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:loadMoreCellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:loadMoreCellIdentifier];
        }
        
        cell.textLabel.textAlignment = UITextAlignmentCenter;
        cell.textLabel.text = @"Load more";
        return cell; //RETURN CELL HERE!
    }
    
    CGFloat startingPoint = 0;
    
    int startingIndexForImage = row*_imagesPerRow;
    
    YFImageShelfCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[YFImageShelfCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }

    for (int i = startingIndexForImage; i < startingIndexForImage + _imagesPerRow; i++) {
        if (i < [_resultArray count] && i >= 0) {
            NSDictionary *imageDict = [_resultArray objectAtIndex:i];
            YFImageButton *image = [YFImageButton buttonWithType:UIButtonTypeCustom];
            image.dictionary = imageDict;
            image.frame = CGRectMake(startingPoint + i%_imagesPerRow * 143, 0, 134, 100);
            NSString *thumbnailURL = [self retrieveThumbnailURL:imageDict];
            //Lazy Loading
            if (self.tableView.dragging == NO && self.tableView.decelerating == NO) {
                [image setImageWithURL:[NSURL URLWithString:thumbnailURL] placeholderImage:[UIImage imageNamed:@"question_list_default_pic"]];
            } else {
                [image setImage:[UIImage imageNamed:@"question_list_default_pic"] forState:UIControlStateNormal];
            }
            
            image.imageView.contentMode = UIViewContentModeScaleAspectFill;
            image.imageView.userInteractionEnabled = NO;
//            image.backgroundColor = [UIColor redColor]; //TEST
            [image addTarget:self action:@selector(onThumbnailClicked:) forControlEvents:UIControlEventTouchDown];
            [cell.imagesContainer addSubview:image];
        }
    }

    return cell; //RETURN CELL HERE!
}

#pragma mark - SDWebImageDownloader Delegate

- (void)imageDownloader:(SDWebImageDownloader *)downloader didFinishWithImage:(UIImage *)image
{
    NSMutableDictionary *infoDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:image, UIImagePickerControllerOriginalImage, nil];
    __unsafe_unretained id s = self;
    [self.delegate imagePickerController:s didFinishPickingMediaWithInfo:infoDict]; //fake the callback
    [_hud hide:YES];
}

- (void)imageDownloader:(SDWebImageDownloader *)downloader didFailWithError:(NSError *)error
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Image Download Failed" message:@"Please try again" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil]; //图片下载失败 请再试一遍
    [_hud hide:YES];
    [alert show];
}

@end
