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

#define DEFAULT_TEXT @"只有父母们可以编辑题库哦\n请让他们帮忙扫描指纹吧"

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
    _fakeScannerView = [[FakeScannerView alloc] initWithFrame:CGRectMake(0, 0, 200, 300)];
    _fakeScannerView.delegate = self;
    _fakeScannerView.center = self.view.center;
    _fakeScannerView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_fakeScannerView];
    
    _topTitle.text = DEFAULT_TEXT;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
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
- (void)accessGranted
{
    if (_allowAccess) {
        QuestionSetViewController *questionSet = [[QuestionSetViewController alloc] initWithViewControllerType:kEditQuestionSet];
        questionSet.managedObjectContext = ((AppDelegate*)[UIApplication sharedApplication].delegate).managedObjectContext;
        [self.navigationController pushViewController:questionSet animated:YES];
        //TODO if back from question set, should not show this
    }
}

- (void)accessDenied
{
    _topTitle.text = @"扫描失败！请重新扫描";
}

- (void)didBeginDetectFinger:(BOOL)isAdult
{
    if (isAdult) {
        _allowAccess = YES;
        _topTitle.text = @"扫描中...";
        [self performSelector:@selector(accessGranted) withObject:nil afterDelay:2.0f];
    } else
    {
        _allowAccess = NO;
        [self accessDenied];
    }
}

- (void)didDetectFingerMoving:(BOOL)isAdult
{
    if (!isAdult) {
        _allowAccess = NO;
        [self accessDenied];
    }
}

- (void)didEndDetectFinger
{
    if (!_allowAccess) {
        _topTitle.text = DEFAULT_TEXT;
    }
}

- (IBAction)onByPassClicked:(id)sender {
    _allowAccess = YES;
    [self accessGranted];
}
@end
