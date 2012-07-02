//
//  BaseGameViewController.m
//  learnEverything
//
//  Created by Yuanfeng on 12-06-05.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BaseGameViewController.h"
#import "AppDelegate.h"

@implementation BaseGameViewController
@synthesize managedObjectContext;
@synthesize isGameOnPause;
@synthesize audioPlayer;

- (NSMutableArray*)allQuestions
{
    NSManagedObjectContext *moc = self.managedObjectContext;
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"Question" inManagedObjectContext:moc];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    // Set example predicate and sort orderings...
    NSPredicate *predicate = [NSPredicate predicateWithValue:YES];
    [request setPredicate:predicate];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
                                        initWithKey:@"create_timestamp" ascending:YES];
    [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    NSError *error = nil;
    NSArray *array = [moc executeFetchRequest:request error:&error];
    if (array == nil)
    {
        NSLog(@"ERROR: array is empty");
        // Deal with error...
    }
    
    return [[NSMutableArray alloc] initWithArray:array];
}

- (IBAction)onMenuClicked:(id)sender {
    self.audioPlayer.volume = 0.2f;
    [self.view addSubview:_pauseMenuBackground];
}

- (void)onMainMenuClicked:(id)sender
{
    [self gameDidTerminate];
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate showStartScreenAnimated];
}

- (void)onResumeGameClicked:(id)sender
{
    self.audioPlayer.volume = 1.0f;
    self.isGameOnPause = NO;
    [_pauseMenuBackground removeFromSuperview];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _pauseMenuBackground = [[UIView alloc] initWithFrame:self.view.frame];
    _pauseMenuBackground.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    _pauseMenuBackground.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.6f];
    
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"PauseMenuView" owner:nil options:nil];
    _pauseMenuContainer = [array lastObject];
    _pauseMenuContainer.backgroundColor = [UIColor clearColor];
    _pauseMenuContainer.center = _pauseMenuBackground.center;
    [_pauseMenuBackground addSubview:_pauseMenuContainer];
    
    _mainMenuButton = (UIButton*)[_pauseMenuContainer viewWithTag:33];
    [_mainMenuButton addTarget:self action:@selector(onMainMenuClicked:) forControlEvents:UIControlEventTouchUpInside];
    _mainMenuButton.titleLabel.font = [UIFont regularChineseFontWithSize:22];
    
    _resumeGameButton = (UIButton*)[_pauseMenuContainer viewWithTag:36];
    [_resumeGameButton addTarget:self action:@selector(onResumeGameClicked:) forControlEvents:UIControlEventTouchUpInside];
    _resumeGameButton.titleLabel.font = [UIFont regularChineseFontWithSize:22];
    
    array = [[NSBundle mainBundle] loadNibNamed:@"DialogViews" owner:nil options:nil];
    _leftDialog = [array objectAtIndex:0];
    _rightDialog = [array objectAtIndex:1];
    
    _leftDialogLbl = (UILabel*)[_leftDialog viewWithTag:22];
    _leftDialogLbl.font = [UIFont regularChineseFontWithSize:16];
    
    _rightDialogLbl = (UILabel*)[_rightDialog viewWithTag:22];
    _rightDialogLbl.font = [UIFont regularChineseFontWithSize:16];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onWillResignAvtiveNotificationReceived:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDidBecomeAvtiveNotificationReceived:) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    //store sounds needed
    NSString *thesoundFilePath = [[NSBundle mainBundle] pathForResource:@"correct" ofType:@"caf"];    //创建音乐文件路径
    CFURLRef thesoundURL = (__bridge CFURLRef) [NSURL fileURLWithPath:thesoundFilePath];
    AudioServicesCreateSystemSoundID(thesoundURL, &_correctSound);
    
    thesoundFilePath = [[NSBundle mainBundle] pathForResource:@"click" ofType:@"wav"];
    thesoundURL = (__bridge CFURLRef) [NSURL fileURLWithPath:thesoundFilePath];
    AudioServicesCreateSystemSoundID(thesoundURL, &_clickSound);
    
    thesoundFilePath = [[NSBundle mainBundle] pathForResource:@"wrongAnswer" ofType:@"mp3"];
    thesoundURL = (__bridge CFURLRef) [NSURL fileURLWithPath:thesoundFilePath];
    AudioServicesCreateSystemSoundID(thesoundURL, &_wrongAnswerSound);
    
    if (!self.audioPlayer) {
        NSError *error;
        NSURL *url = [[NSURL alloc] initFileURLWithPath:[[NSBundle mainBundle] pathForResource:@"xj" ofType:@"mp3"]];
        self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
        if (![self.audioPlayer prepareToPlay]) {
            //handle error for failure here
            //            [self showErrorMsg];
            NSLog(@"Cannot play music!!!reason: %@", error.debugDescription);
        }
    }
    [self.audioPlayer setDelegate:self];
    self.audioPlayer.volume = 0.6f; //Because it's too loud
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.audioPlayer stop];
    self.audioPlayer = nil;
}

#pragma mark - Dialog related
- (void)showLeftDialogAtPosition:(CGPoint)originPosition withText:(NSString*)text
{
    _leftDialog.frame = CGRectMake(originPosition.x, originPosition.y, _leftDialog.frame.size.width, _leftDialog.frame.size.height);
    if (!_leftDialog.superview) {
        [self.view addSubview:_leftDialog];
    }
    _leftDialogLbl.text = text;
}

- (void)showRightDialogAtPosition:(CGPoint)originPosition withText:(NSString*)text
{
    _rightDialog.frame = CGRectMake(originPosition.x, originPosition.y, _rightDialog.frame.size.width, _rightDialog.frame.size.height);
    if (!_rightDialog.superview)
    {
        [self.view addSubview:_rightDialog];
    }
    _rightDialogLbl.text = text;
}


- (void)dismissLeftDialog
{
    [_leftDialog removeFromSuperview];
}

- (void)dismissRightDialog
{
    [_rightDialog removeFromSuperview];
}

- (void)playBackgroundMusic
{
	[self.audioPlayer play];
}

- (void)onWillResignAvtiveNotificationReceived:(NSNotification*)notification
{
    [self.audioPlayer pause];
}

- (void)onDidBecomeAvtiveNotificationReceived:(NSNotification*)notification
{
    if (!_gameDidTerminate) {
        [self.audioPlayer play];
    }
}

- (void)gameDidTerminate
{
    _gameDidTerminate = YES;
    [self.audioPlayer stop];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    if (_gameDidTerminate) {
         
    } else
    {
        [self.audioPlayer play];
    }
}

@end
