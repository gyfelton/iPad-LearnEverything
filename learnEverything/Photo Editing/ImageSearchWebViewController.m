//
//  WebViewController.m
//  adminapp
//
//  Created by Yuanfeng on 12-04-11.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ImageSearchWebViewController.h"
#import "SDWebImageDownloader.h"

@implementation ImageSearchWebViewController
@synthesize delegate;


#define BING_IMAGE_SEARCH_URL @"http://m.bing.com/search/search.aspx?A=imageresults&Q=%@&D=Image&SCO=0"
#define BING_IMAGE_SEARCH_URL_EMPTY_STRING @"http://m.bing.com/search/search.aspx?A=imageresults";

- (id)initWithSearchStringArray:(NSArray*)array delegate:(id<UIImagePickerControllerDelegate>)d;
{
    self = [super init];
    if (self) {
        // Custom initialization
        self.delegate = d;
        _searchStringArray = array;
        self.title = @"必应图片搜索";
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

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:_hud];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _webView = [[UIWebView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:_webView];
    _webView.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.view bringSubviewToFront:_hud];
    
    NSString *searchQuery = @"";
    
    for (NSString *q in _searchStringArray) {
        NSString *q2 = [q stringByReplacingOccurrencesOfString:@" " withString:@"+"];
        searchQuery = [searchQuery stringByAppendingString:q2];
        searchQuery = [searchQuery stringByAppendingString:@"+"];
    }
    NSString *compiledString = [NSString stringWithFormat:BING_IMAGE_SEARCH_URL, [searchQuery stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];//], @"1024", @"672"];
    BOOL can = [[UIApplication sharedApplication]  canOpenURL:[NSURL URLWithString:compiledString]];
    if (!can) { //if cannot load it, switch to basic image search webpage
        compiledString = BING_IMAGE_SEARCH_URL_EMPTY_STRING;
    }
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:compiledString]]];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    _webView.delegate = nil;
    [_imageDownloader cancel];
    _imageDownloader.delegate = nil;
    _imageDownloader = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UIWebView Delegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *url = [request URL].absoluteString;
    NSArray *components = [url componentsSeparatedByString:@"&"];
    NSString *imgURL = nil;
    for (NSString *str in components) {
        if ([str hasPrefix:@"UR"]) {
            imgURL = [str substringFromIndex:3];
            imgURL = [imgURL stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            if (_imageDownloader)
            {
                [_imageDownloader cancel];
                _imageDownloader.delegate = nil;
                _imageDownloader = nil;
            }
            _imageDownloader = [SDWebImageDownloader downloaderWithURL:[NSURL URLWithString:imgURL] delegate:self];
            _hud.labelText = @"下载图片中...";
            [_hud show:YES];
            break;
        }
    }
    if (imgURL) {
        return NO;
    }
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    _hud.labelText = @"载入中...";
    [_hud show:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [_hud hide:YES];
}

#pragma mark - SDWebImageDownloader Delegate

- (void)imageDownloader:(SDWebImageDownloader *)downloader didFinishWithImage:(UIImage *)image
{
    NSMutableDictionary *infoDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:image, UIImagePickerControllerOriginalImage, nil];
    __unsafe_unretained id s = self;
    [delegate imagePickerController:s didFinishPickingMediaWithInfo:infoDict]; //fake the callback
    [_hud hide:YES];
}

- (void)imageDownloader:(SDWebImageDownloader *)downloader didFailWithError:(NSError *)error
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"图片下载失败" message:@"请再试一遍" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [_hud hide:YES];
    [alert show];
}
@end
