//
//  BaseGameViewController.m
//  learnEverything
//
//  Created by Yuanfeng on 12-06-05.
//  Copyright (c) 2012 ____Yuanfeng Gao___. All rights reserved.
//

#import "BaseGameViewController.h"
#import "AppDelegate.h"
#import "SinglePlayerGameViewController.h"
#import "TwoPlayersGameViewController.h"

#define REGULAR_VOLUME 0.5f

@implementation BaseGameViewController
@synthesize managedObjectContext;
@synthesize isGameOnPause;
@synthesize audioPlayer;
@synthesize expandedQuestionList = _expandedQuestionList;
 
- (NSMutableArray*)_questionsWithPredicate:(NSPredicate*)predicate
{
    NSManagedObjectContext *moc = self.managedObjectContext;
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"Question" inManagedObjectContext:moc];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    // Set example predicate and sort orderings...
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

#pragma mark - Getting questions
//Should not use this one!
- (NSMutableArray*)allQuestions
{
    return [self _questionsWithPredicate:[NSPredicate predicateWithValue:YES]];
}

- (NSMutableArray*)activeQuestionsFromQuestionSet
{
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
                                        initWithKey:@"create_timestamp" ascending:YES];
    NSArray *questions = [_questionSet.questions sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    NSMutableArray *mutable = [[NSMutableArray alloc] init];
    for (int i = 0; i< [questions count]; i++) {
        Question *qn = [questions objectAtIndex:i];
        if ([qn.is_active boolValue]) {
            [mutable addObject:qn];
        }
    }
    return mutable;
}

- (NSMutableArray*)activeAndCompleteQuestionsFromQuestionSet
{
    NSMutableArray *activeArray = [self activeQuestionsFromQuestionSet];
    NSMutableArray *activeAndCompleteArray = [[NSMutableArray alloc] init];
    for (int i = 0; i< [activeArray count]; i++) {
        Question *qn = [activeArray objectAtIndex:i];
        if ([_questionSet.question_type intValue] == kTxtPlusTxt) {
            if (qn.question_in_text && (qn.answer_in_text || qn.answer_id)) {
                [activeAndCompleteArray addObject:qn];
            }
        } else
        {
            if (qn.question_in_text && qn.answer_in_image) {
                [activeAndCompleteArray addObject:qn];
            }
        }
    }
    return activeAndCompleteArray;
}

#pragma mark - IBActions

- (IBAction)onPauseClicked:(id)sender {
    if ([self allowSound]) {
        self.audioPlayer.volume = 0.2f;
    }
    
    [self.view addSubview:_pauseMenuBackground];
}

- (IBAction)onSpeakerClicked:(id)sender
{
    _speakerBtn.selected = !_speakerBtn.selected;
    BOOL speakerON = !_speakerBtn.selected;
    _speakerBtn2.selected = _speakerBtn.selected;
    if (speakerON) {
        self.audioPlayer.volume = REGULAR_VOLUME;
    } else
    {
        self.audioPlayer.volume = 0.0f;
    }
}

- (void)onMainMenuClicked:(id)sender
{
    [self gameDidTerminate];
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate showStartScreenAnimated];
}

- (void)onRestartGameClicked:(id)sender
{
    [self gameDidTerminate];
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    BOOL singlePlayerGame = [self isMemberOfClass:[SinglePlayerGameViewController class]];
    if (singlePlayerGame) {
        [appDelegate prepareForSinglePlayerGameWithQuestionSet:_questionSet];
    } else
    {
        [appDelegate prepareForTwoPlayersGameQuestionSet:_questionSet];
    }
}

- (void)onResumeGameClicked:(id)sender
{
    if ([self allowSound])
    {
        self.audioPlayer.volume = REGULAR_VOLUME;
    }
    
    self.isGameOnPause = NO;
    [_pauseMenuBackground removeFromSuperview];
}

- (BOOL)allowSound
{
    return !_speakerBtn.selected;
}

#pragma mark - View Lifecycles

- (void)viewDidLoad
{
    [super viewDidLoad];
    _pauseMenuBackground = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
    _pauseMenuBackground.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.6f];
    
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"PauseMenuView" owner:nil options:nil];
    _pauseMenuContainer = [array lastObject];
    _pauseMenuContainer.backgroundColor = [UIColor clearColor];
    _pauseMenuContainer.center = _pauseMenuBackground.center;
    [_pauseMenuBackground addSubview:_pauseMenuContainer];
    
    _mainMenuButton = (SimulatePressButton*)[_pauseMenuContainer viewWithTag:33];
    [_mainMenuButton addTarget:self action:@selector(onMainMenuClicked:) forControlEvents:UIControlEventTouchUpInside];
    _mainMenuButton.titleLabel.font = [UIFont regularChineseFontWithSize:22];
    
    _resumeGameButton = (SimulatePressButton*)[_pauseMenuContainer viewWithTag:36];
    [_resumeGameButton addTarget:self action:@selector(onResumeGameClicked:) forControlEvents:UIControlEventTouchUpInside];
    _resumeGameButton.titleLabel.font = [UIFont regularChineseFontWithSize:22];
    
    _resrartGameButton = (SimulatePressButton*)[_pauseMenuContainer viewWithTag:35];
    [_resrartGameButton addTarget:self action:@selector(onRestartGameClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    array = [[NSBundle mainBundle] loadNibNamed:@"DialogViews" owner:nil options:nil];
    _leftDialog = [array objectAtIndex:0];
    _rightDialog = [array objectAtIndex:1];
    
    _leftDialogLbl = (UILabel*)[_leftDialog viewWithTag:22];
    _leftDialogLbl.font = [UIFont regularChineseFontWithSize:30];
    
    _rightDialogLbl = (UILabel*)[_rightDialog viewWithTag:22];
    _rightDialogLbl.font = [UIFont regularChineseFontWithSize:30];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onWillResignAvtiveNotificationReceived:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDidBecomeAvtiveNotificationReceived:) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    //store sounds needed
    // Set the sound to always play
    int setTo0 = 0;
    AudioServicesSetProperty( kAudioServicesPropertyIsUISound,0,nil,
                             4,&setTo0 );
    
    NSString *thesoundFilePath = [[NSBundle mainBundle] pathForResource:@"correct" ofType:@"caf"];    //创建音乐文件路径
    CFURLRef thesoundURL = (__bridge CFURLRef) [NSURL fileURLWithPath:thesoundFilePath];
    AudioServicesCreateSystemSoundID(thesoundURL, &_correctSound);
    
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    
    _clickSound = delegate.clickSound;
    
    thesoundFilePath = [[NSBundle mainBundle] pathForResource:@"wrong_music" ofType:@"wav"];
    thesoundURL = (__bridge CFURLRef) [NSURL fileURLWithPath:thesoundFilePath];
    AudioServicesCreateSystemSoundID(thesoundURL, &_wrongAnswerSound);
    
    thesoundFilePath = [[NSBundle mainBundle] pathForResource:@"errorSound" ofType:@"mp3"];
    thesoundURL = (__bridge CFURLRef) [NSURL fileURLWithPath:thesoundFilePath];
    AudioServicesCreateSystemSoundID(thesoundURL, &_errorSound);
    
    if (!self.audioPlayer) {
        NSError *error;
        NSString *path = [delegate getBattleMusicPath];
        NSURL *url = [[NSURL alloc] initFileURLWithPath:path];
        self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
        if (![self.audioPlayer prepareToPlay]) {
            //handle error for failure here
            //            [self showErrorMsg];
            NSLog(@"Cannot play music!!!reason: %@", error.debugDescription);
        }
    }
    [self.audioPlayer setDelegate:self];
    self.audioPlayer.volume = REGULAR_VOLUME; //Because it's too loud
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onGameProgressDictReceived:) name:GameProgressNotificationWithInfoDictionry_KEY object:nil];
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
    [self.audioPlayer stop];
    self.audioPlayer = nil;
        [[NSNotificationCenter defaultCenter] removeObserver:self name:GameProgressNotificationWithInfoDictionry_KEY object:nil];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

#pragma mark - Dialog related

- (void)showLeftDialogAtPosition:(CGPoint)originPosition withText:(NSString*)text
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(dismissLeftDialog) object:nil];
    _leftDialog.frame = CGRectMake(originPosition.x, originPosition.y, _leftDialog.frame.size.width, _leftDialog.frame.size.height);
    if (!_leftDialog.superview) {
        [self.view addSubview:_leftDialog];
        _leftDialog.transform = CGAffineTransformMakeScale(0.01f, 0.01f);
        _leftDialog.transform = CGAffineTransformTranslate(_leftDialog.transform, _leftDialog.frame.size.width/2*(-1), _leftDialog.frame.size.height/2*(-1));
        [UIView animateWithDuration:0.2f
                              delay:0.0f 
                            options:UIViewAnimationOptionAllowUserInteraction 
                         animations:^{
            _leftDialog.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            
        }];
    }
    _leftDialogLbl.text = text;
}

- (void)showLeftDialogAtPosition:(CGPoint)originPosition withText:(NSString*)text dismissAfterDelay:(NSTimeInterval)delay
{
    [self showLeftDialogAtPosition:originPosition withText:text];
    [self performSelector:@selector(dismissLeftDialog) withObject:nil afterDelay:delay];
}

- (void)showRightDialogAtPosition:(CGPoint)originPosition withText:(NSString*)text
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(dismissRightDialog) object:nil];
    _rightDialog.frame = CGRectMake(originPosition.x, originPosition.y, _rightDialog.frame.size.width, _rightDialog.frame.size.height);
    if (!_rightDialog.superview)
    {
        [self.view addSubview:_rightDialog];
        _rightDialog.transform = CGAffineTransformMakeScale(0.01f, 0.01f);
        _rightDialog.transform = CGAffineTransformTranslate(_rightDialog.transform, _rightDialog.frame.size.width/2, _rightDialog.frame.size.height/2);
        [UIView animateWithDuration:0.2f
                              delay:0.0f 
                            options:UIViewAnimationOptionAllowUserInteraction 
                         animations:^{
                             _rightDialog.transform = CGAffineTransformIdentity;
                         } completion:^(BOOL finished) {
                             
                         }];
    }
    _rightDialogLbl.text = text;
}

- (void)showRightDialogAtPosition:(CGPoint)originPosition withText:(NSString*)text dismissAfterDelay:(NSTimeInterval)delay
{
    [self showRightDialogAtPosition:originPosition withText:text];
    [self performSelector:@selector(dismissRightDialog) withObject:nil afterDelay:delay];
}

- (void)dismissLeftDialog
{
    [_leftDialog removeFromSuperview];
}

- (void)dismissRightDialog
{
    [_rightDialog removeFromSuperview];
}

#pragma mark - Playing musics

- (void)playBackgroundMusic
{
	[self.audioPlayer play];
}

- (void)playBattleWinMusic
{
    [self gameDidTerminate];
    [self.audioPlayer stop];
    if ([self allowSound]) {
        NSError *error;
        NSURL *url = [[NSURL alloc] initFileURLWithPath:[[NSBundle mainBundle] pathForResource:@"battle_win" ofType:@"mp3"]];
        self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
        if (![self.audioPlayer prepareToPlay]) {
            //handle error for failure here
            //            [self showErrorMsg];
            NSLog(@"Cannot play music!!!reason: %@", error.debugDescription);
        }
        [self.audioPlayer setDelegate:self];
        self.audioPlayer.volume = REGULAR_VOLUME; //Because it's too loud
        [self.audioPlayer play];
    }
}

- (void)playBattleLoseMusic
{
    [self gameDidTerminate];
    [self.audioPlayer stop];
    if ([self allowSound]) {
        NSError *error;
        NSURL *url = [[NSURL alloc] initFileURLWithPath:[[NSBundle mainBundle] pathForResource:@"battle_lose" ofType:@"mp3"]];
        self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
        if (![self.audioPlayer prepareToPlay]) {
            //handle error for failure here
            //            [self showErrorMsg];
            NSLog(@"Cannot play music!!!reason: %@", error.debugDescription);
        }
        [self.audioPlayer setDelegate:self];
        self.audioPlayer.volume = REGULAR_VOLUME; //Because it's too loud
        [self.audioPlayer play];
    }
}

#pragma mark - NSNotifications

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

- (void)onGameProgressDictReceived:(NSNotification*)notification
{
    //Subclass implement this
//    NSDictionary *info = [notification object];
//    CGFloat leftWidth = [[info objectForKey:@"left_width"] floatValue];
//    CGFloat rightWidth = [[info objectForKey:@"right_width"] floatValue];
//    CGFloat totalWidth = [[info objectForKey:@"total_width"] floatValue];
//    NSLog(@"%f, %f, %f", leftWidth, rightWidth, totalWidth);
}
@end
