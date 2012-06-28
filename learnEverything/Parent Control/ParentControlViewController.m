//
//  ParentControlViewController.m
//  learnEverything
//
//  Created by Yuanfeng on 12-06-25.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ParentControlViewController.h"
#import "QuestionSetViewController.h"
#import "AppDelegate.h"

#define DEFAULT_TEXT @"只有大人们可以编辑题库哦\n请让他们帮忙扫描指纹吧\n\n请将大拇指按在下方框内"

@interface ParentControlViewController (Private)
- (void)animateScanLightUp;
@end

@implementation ParentControlViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"访问受限";
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
    // Do any additional setup after loading the view from its nib.
    _fakeScannerView = [[FakeScannerView alloc] initWithFrame:scanArea_placeholder.frame];
    _fakeScannerView.delegate = self;
    _fakeScannerView.center = self.view.center;
    _fakeScannerView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_fakeScannerView];
    
    _topTitle.text = DEFAULT_TEXT;
    _topTitle.font = [UIFont regularChineseFontWithSize:24];
    
    _tipLbl.hidden = YES; //Not using this
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    _topTitle.text = DEFAULT_TEXT;
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)animateScanLightDown
{
    [UIView animateWithDuration:2.0f animations:^{
        _scanImage.frame = CGRectOffset(_scanImage.frame, 0, 194-22);
    } completion:^(BOOL finished) {
        [self animateScanLightUp];
    }];
}

- (void)animateScanLightUp
{
    [UIView animateWithDuration:2.0f animations:^{
        _scanImage.frame = CGRectOffset(_scanImage.frame, 0, -194+22);
    } 
        completion:^(BOOL finished) {
        [self animateScanLightDown];
    }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (!_scanImageStarted) {
        _scanImageStarted = YES;
        [self animateScanLightUp];
    }
}

- (void)dealloc
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    _fakeScannerView.delegate = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return LANDSCAPE_ORIENTATION;
}

#pragma mark - Finger Detect Delegate
- (void)pushToQuestionSet
{
    QuestionSetViewController *questionSet = [[QuestionSetViewController alloc] initWithViewControllerType:kEditQuestionSet];
    questionSet.managedObjectContext = ((AppDelegate*)[UIApplication sharedApplication].delegate).managedObjectContext;
    [self.navigationController pushViewController:questionSet animated:YES];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    //TODO if back from question set, should not show this
}

- (void)accessGranted
{
        _topTitle.text = @"扫描成功！";
        [self performSelector:@selector(pushToQuestionSet) withObject:nil afterDelay:1.0f];
}

- (void)accessDenied
{
    _topTitle.text = @"扫描失败！请重新扫描";
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void)showNormalText 
{
    _topTitle.text = DEFAULT_TEXT;
}

- (void)didBeginDetectFinger:(BOOL)isAdult
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    if (isAdult) {
        _allowAccess = YES;
        _topTitle.text = @"扫描中...不要移动手指";
        [self performSelector:@selector(accessGranted) withObject:nil afterDelay:0.6f];
    } else
    {
        _allowAccess = NO;
        [self accessDenied];
    }
}

- (void)didDetectFingerMoving:(BOOL)isAdult
{
//    if (!isAdult) {
//        _allowAccess = NO;
//        [self accessDenied];
//    }
}

- (void)didEndDetectFinger
{
    if (!_allowAccess) {
        [self accessDenied];
        [self performSelector:@selector(showNormalText) withObject:nil afterDelay:1];
    }
}

- (IBAction)onByPassClicked:(id)sender {
    _allowAccess = YES;
    [self accessGranted];
}

- (void)viewDidUnload {
    _tipLbl = nil;
    scanArea_placeholder = nil;
    _scanImage = nil;
    [super viewDidUnload];
}
@end
