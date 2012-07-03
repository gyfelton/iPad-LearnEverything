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

#define DEFAULT_TEXT @"请使用大拇指扫描指纹"

@interface ParentControlViewController (Private)
- (void)animateScanLightUp;
@end

@implementation ParentControlViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"身份确认";
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
    _topTitle.font = [UIFont regularChineseFontWithSize:38];
    
    _bottom_tip.font = [UIFont regularChineseFontWithSize:38];
    
    _tipLbl.hidden = YES; //Not using this
    
    _main_title.text = self.title;
    _main_title.font = [UIFont regularChineseFontWithSize:33];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    _topTitle.text = DEFAULT_TEXT;
}

- (void)animateScanLightDown
{
    [UIView animateWithDuration:2.0f delay:0.0f options:UIViewAnimationOptionAllowUserInteraction animations:^{
        _scanImage.frame = CGRectOffset(_scanImage.frame, 0, 194-22);
    } completion:^(BOOL finished) {
        [self animateScanLightUp];
    }];
}

- (void)animateScanLightUp
{
    [UIView animateWithDuration:2.0f delay:0.0f options:UIViewAnimationOptionAllowUserInteraction  animations:^{
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
//        [self performSelector:@selector(pushToQuestionSet) withObject:nil afterDelay:1.0f];
    [self pushToQuestionSet];
}

- (void)accessDenied
{
    _topTitle.text = @"扫描失败 >_<\n只有大人才能打开这里哦\n";
    _bottom_tip.hidden = YES;
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void)showNormalText 
{
    _topTitle.text = DEFAULT_TEXT;
    _bottom_tip.hidden = NO;
}

- (void)didBeginDetectFinger:(BOOL)isAdult
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    if (isAdult) {
        _allowAccess = YES;
        _topTitle.text = @"扫描中...请不要移动手指";
//        [self performSelector:@selector(accessGranted) withObject:nil afterDelay:0.6f];
        [self accessGranted];
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

- (IBAction)onBackClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onByPassClicked:(id)sender {
    _allowAccess = YES;
    [self accessGranted];
}

- (void)viewDidUnload {
    _tipLbl = nil;
    scanArea_placeholder = nil;
    _scanImage = nil;
    _main_title = nil;
    _bottom_tip = nil;
    [super viewDidUnload];
}
@end
