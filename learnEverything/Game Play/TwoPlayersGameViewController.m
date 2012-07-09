//
//  TwoPlayersGameViewController.m
//  learnEverything
//
//  Created by Yuanfeng on 12-06-10.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TwoPlayersGameViewController.h"
#import "AnimationViewController.h"
#import "AppDelegate.h"
#import "NSMutableArray+Shuffling.h"

#define ROW_NUMBER 3
#define COLUMN_NUMBER 4

@implementation TwoPlayersGameViewController

- (id)initWithManagedContext:(NSManagedObjectContext *)context questionSet:(QuestionSet *)questionSet
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        // Custom initialization
        self.managedObjectContext = context;
        _questionSet = questionSet;
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

- (void)reinitGame
{
    //Prepare the expandedQuestionList
    _questionList = [super activeAndCompleteQuestionsFromQuestionSet];
    
    _expandedQuestionList = [[NSMutableArray alloc] initWithArray:_questionList];
    [_expandedQuestionList shuffle];
    
    _questionManager_light = [[QuestionManager alloc] initWithGridView:_grid_view_light questionList:_questionList questionType:[_questionSet.question_type intValue] numberOfCardsInGridView:ROW_NUMBER*COLUMN_NUMBER];
    _questionManager_light.questionManagerDelegate = self;
    
    _questionManager_dark = [[QuestionManager alloc] initWithGridView:_grid_view_dark questionList:_questionList questionType:[_questionSet.question_type intValue] numberOfCardsInGridView:ROW_NUMBER*COLUMN_NUMBER];
    _questionManager_dark.questionManagerDelegate = self;
    
    [_grid_view_dark reloadData];
    [_grid_view_light reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.wantsFullScreenLayout = YES;
	// Do any additional setup after loading the view, typically from a nib.
    
    _grid_view_light = [[NonScrollableGridView alloc] initWithFrame:_grid_view_light_place_holder.frame];
    _grid_view_light.dataSource = self;
    
    [_grid_view_light_place_holder.superview insertSubview:_grid_view_light aboveSubview:_grid_view_light_place_holder];
    [_grid_view_light_place_holder removeFromSuperview];
    
    _grid_view_dark = [[NonScrollableGridView alloc] initWithFrame:_grid_view_dark_place_holder.frame];
    _grid_view_dark.dataSource = self;
    
    _grid_view_dark.transform = CGAffineTransformMakeRotation(M_PI);
    
    [_grid_view_dark_place_holder.superview insertSubview:_grid_view_dark aboveSubview:_grid_view_dark_place_holder];
    [_grid_view_dark_place_holder removeFromSuperview];
    
    [self reinitGame];
    
    _animationVC = [[AnimationViewController alloc] initInSinglePlayerMode:NO];
    _animationVC.view.center = self.view.center;
    
    [self.view insertSubview:_animationVC.view aboveSubview:_animation_place_holder];
    [_animation_place_holder removeFromSuperview];
}

- (void)dismissCountdownAndStartGame
{
    [_countdownImageView removeFromSuperview];
    _countdownImageView = nil;
    
   // [self presentCardsAnimated];
}

- (void)showCountDown:(NSNumber*)num
{
    int number = [num intValue];
    if (!_countdownImageView) {
        _countdownImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 300, 450)];
        [self.view addSubview:_countdownImageView];
    }
    
    _countdownImageView.center = self.view.center;
    
    if (number == 1) {
        _countdownImageView.image = [UIImage imageNamed:@"countdown_one"];
        [self performSelector:@selector(dismissCountdownAndStartGame) withObject:nil afterDelay:1.0f];
    } else if (number == 2) {
        _countdownImageView.image = [UIImage imageNamed:@"countdown_two"];
        [self performSelector:@selector(showCountDown:) withObject:[NSNumber numberWithInt:1] afterDelay:1.0f];
    } else if (number == 3) {
        _countdownImageView.image = [UIImage imageNamed:@"countdown_three"];
        [self performSelector:@selector(showCountDown:) withObject:[NSNumber numberWithInt:2] afterDelay:1.0f];
    }
    
}

- (void)startMusicAndShowCountDown
{
    [super playBackgroundMusic];
    [_animationVC viewDidAppear:NO];
    [self showCountDown:[NSNumber numberWithInt:3]];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self startMusicAndShowCountDown];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return interfaceOrientation == UIInterfaceOrientationPortrait;
}

#pragma mark - NonScrollableGridView DataSource

- (NSInteger)numberOfRowsForNonScrollableGridView:(NonScrollableGridView *)gridView
{
    if (_grid_view_dark == gridView) {
        return [_expandedQuestionList count]>0? ROW_NUMBER : 0;
    } else if (gridView == _grid_view_light)
    {
        return [_expandedQuestionList count]>0? ROW_NUMBER : 0;
    }
    return 0;
}

- (NSInteger)numberOfColumnsForNonScrollableGridView:(NonScrollableGridView *)gridView
{
    if (_grid_view_dark == gridView) {
        return [_expandedQuestionList count]>0? COLUMN_NUMBER : 0;
    } else if (gridView == _grid_view_light)
    {
        return [_expandedQuestionList count]>0? COLUMN_NUMBER : 0;
    }
    return 0;
}

- (CGFloat)widthForEachUnit:(NonScrollableGridView *)gridView
{
    return 200;
}

- (CGFloat)heightForEachUnit:(NonScrollableGridView *)gridView
{
    return 123;
}

-(UIView*)viewForNonScrollableGridView:(NonScrollableGridView *)gridView atRowIndex:(NSInteger)rowIndex columnIndex:(NSInteger)columnIndex
{
    if (gridView == _grid_view_light) {
        return [_questionManager_light viewForNonScrollableGridViewAtRowIndex:rowIndex columnIndex:columnIndex];
    } else if (gridView == _grid_view_dark)
    {
        return [_questionManager_dark viewForNonScrollableGridViewAtRowIndex:rowIndex columnIndex:columnIndex];
    }
    return nil;
}

#pragma mark - Super class methods override
- (void)onPauseClicked:(id)sender
{
    //Config the pause view
    [_pauseMenuContainer removeFromSuperview];
    _pauseMenuBackground.frame = CGRectMake(0, 0, 768, 1024);
    _pauseMenuContainer.center = CGPointMake(384, 830);
    [_pauseMenuBackground addSubview:_pauseMenuContainer];
    
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"PauseMenuView" owner:nil options:nil];
    UIView *secondMenu = [array lastObject];
    secondMenu.backgroundColor = [UIColor clearColor];
    secondMenu.center = CGPointMake(384, 183);
    [_pauseMenuBackground addSubview:secondMenu];
    secondMenu.transform = CGAffineTransformMakeRotation(M_PI);
    
    SimulatePressButton *pauseBtn = (SimulatePressButton*)[secondMenu viewWithTag:33];
    [pauseBtn addTarget:self action:@selector(onMainMenuClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    SimulatePressButton *resumeBtn = (SimulatePressButton*)[secondMenu viewWithTag:36];
    [resumeBtn addTarget:self action:@selector(onResumeGameClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    SimulatePressButton *restartBtn = (SimulatePressButton*)[secondMenu viewWithTag:35];
    [restartBtn addTarget:self action:@selector(onRestartGameClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [super onPauseClicked:sender];
}

#pragma mark - QuestionManager Delegate
- (void)_animateStarMovement:(UIView*)star
{
    [UIView animateWithDuration:0.6f delay:0.1f 
                        options:(UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction)
                     animations:^{
                         CGFloat scale = 0.2f;
                         star.frame = CGRectMake(53, 516, star.frame.size.width*scale, star.frame.size.height*scale);
                         //CGAffineTransform movement = CGAffineTransformMakeTranslation(/scale, (80 - star.frame.origin.y)/scale);
                         //CGAffineTransform shrinkDown = CGAffineTransformMakeScale(scale, scale);
                         //star.transform = CGAffineTransformConcat(movement, shrinkDown);
                         star.transform = CGAffineTransformMakeRotation(M_PI);
                     } 
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.2f animations:^{
                             //                             star.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
                         } completion:^(BOOL finished) {
                             [star removeFromSuperview];
                         }];
                         
                         //                         _progressBar.progress +=0.025f;
                         _animationVC.score += 0.025f;
                         
                     }];
}

- (void)_animateFlameMovement:(UIView*)flame
{
    [UIView animateWithDuration:0.6f delay:0.1f 
                        options:(UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction)
                     animations:^{
                         CGFloat scale = 0.2f;
                         flame.frame = CGRectMake(710, 499, flame.frame.size.width*scale, flame.frame.size.height*scale);
                         //CGAffineTransform movement = CGAffineTransformMakeTranslation(/scale, (80 - star.frame.origin.y)/scale);
                         //CGAffineTransform shrinkDown = CGAffineTransformMakeScale(scale, scale);
                         //star.transform = CGAffineTransformConcat(movement, shrinkDown);
                     } 
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.2f delay:0.0f 
                                             options:UIViewAnimationOptionAllowUserInteraction
                                          animations:^{
                                              //                             star.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
                                          } completion:^(BOOL finished) {
                                              [flame removeFromSuperview];
                                          }];
                         
                         //                         _progressBar.progress -=0.025f;
                         _animationVC.score -= 0.025f;
                         
                     }];
}

- (void)animateStarToLightHeroAndIncrementScore:(UIView*)star
{
    star.transform = CGAffineTransformMakeScale(0.01, 0.01);
    [UIView animateWithDuration:0.1f 
                          delay:0.0f 
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^(){
                         star.transform = CGAffineTransformIdentity;
                     }
                     completion:^(BOOL finished){
                         [self _animateStarMovement:star];
                     }
     ];
}

- (void)animateFlameToDarkSideAndDecrementScore:(UIView*)flame
{
    flame.transform = CGAffineTransformMakeScale(0.01, 0.01);
    [UIView animateWithDuration:0.1f 
                          delay:0.0f 
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^(){
                         flame.transform = CGAffineTransformIdentity;
                     }
                     completion:^(BOOL finished){
                         [self _animateFlameMovement:flame];
                     }
     ];
}

- (void)QuestionManager:(QuestionManager *)manager answerCorrectlyWithCard1:(QuestionCard *)card1 card2:(QuestionCard *)card2
{
    if (manager == _questionManager_light) {
        //Animate star
        CGRect rect = [card1 convertRect:card1.bounds toView:self.view];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:rect];
        imageView.image = [UIImage imageNamed:@"star_score"];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        [self.view addSubview:imageView];
        [self animateStarToLightHeroAndIncrementScore:imageView];
        
        
        CGRect rect2 = [card2 convertRect:card2.bounds toView:self.view];
        UIImageView *imageView2 = [[UIImageView alloc] initWithFrame:rect2];
        imageView2.image = [UIImage imageNamed:@"star_score"];
        imageView2.contentMode = UIViewContentModeScaleAspectFit;
        [self.view addSubview:imageView2];
        [self animateStarToLightHeroAndIncrementScore:imageView2];
        
        if ([self allowSound]) AudioServicesPlaySystemSound(_correctSound);  // 播放SoundID声音
    }
    if (manager == _questionManager_dark) {
        //Animate flame
        CGRect rect = [card1 convertRect:card1.bounds toView:self.view];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:rect];
        imageView.image = [UIImage imageNamed:@"flame"];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        [self.view addSubview:imageView];
        [self animateFlameToDarkSideAndDecrementScore:imageView];
        
        
        CGRect rect2 = [card2 convertRect:card2.bounds toView:self.view];
        UIImageView *imageView2 = [[UIImageView alloc] initWithFrame:rect2];
        imageView2.image = [UIImage imageNamed:@"flame"];
        imageView2.contentMode = UIViewContentModeScaleAspectFit;
        [self.view addSubview:imageView2];
        [self animateFlameToDarkSideAndDecrementScore:imageView2];
        
        if ([self allowSound]) AudioServicesPlaySystemSound(_correctSound);  // 播放SoundID声音
    }
}

- (void)QuestionManager:(QuestionManager *)manager answerWronglyWithCard1:(QuestionCard *)card1 card2:(QuestionCard *)card2
{
    //双人游戏，我们不惩罚答错
    if ([self allowSound]) AudioServicesPlaySystemSound(_errorSound);  // 播放SoundID声音
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    return;
    
}

- (void)QuestionManager:(QuestionManager *)manager clickOnCard:(QuestionCard *)card
{
    if ([self allowSound]) AudioServicesPlaySystemSound(_clickSound);  // 播放SoundID声音
}

- (void)QuestionManager:(QuestionManager *)manager clickOnSameTypeCardsWithCard1:(QuestionCard *)card1 card2:(QuestionCard *)card2
{
    if ([self allowSound]) AudioServicesPlaySystemSound(_errorSound);  // 播放SoundID声音
}

#pragma mark - Game Progress
- (void)onGameProgressDictReceived:(NSNotification*)notification
{
    NSDictionary *info = [notification object];
    CGFloat leftWidth = [[info objectForKey:@"left_width"] floatValue];
    CGFloat rightWidth = [[info objectForKey:@"right_width"] floatValue];
    CGFloat totalWidth = [[info objectForKey:@"total_width"] floatValue];
    //NSLog(@"%f, %f, %f", leftWidth, rightWidth, totalWidth)
    
    if (!_hasShowResultScreen)
    {
        if (leftWidth <= 10 || rightWidth <= 10) {
            _hasShowResultScreen = YES;
            //准备两个view
            UIView *winScreenContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 768, 366)];
            [self.view addSubview:winScreenContainer];
            
            winScreenContainer.backgroundColor =  [UIColor clearColor];
            UIView *bg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 768, 366)];
            bg.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.4f];
            [winScreenContainer addSubview:bg];
            UIImageView *winScreen1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"two_players_win_screen_1"]];
            UIImageView *winScreen2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"two_players_win_screen_2"]];
            winScreen1.backgroundColor = [UIColor clearColor];
            winScreen2.backgroundColor = [UIColor clearColor];
            winScreen1.transform = CGAffineTransformMakeScale(0.01f, 0.01f);
            winScreen2.transform = CGAffineTransformMakeScale(0.01f, 0.01f);
            [winScreenContainer addSubview:winScreen1];
            [winScreenContainer addSubview:winScreen2];
            
            //输的
            UIView *loseScreenContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 768, 366)];
            UIView *lose_bg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 768, 366)];
            lose_bg.backgroundColor = [UIColor colorWithRed:0.87f green:0.18f blue:0.12f alpha:1.0f];
            lose_bg.alpha = 0.0f;
            [loseScreenContainer addSubview:lose_bg];
            loseScreenContainer.backgroundColor = [UIColor clearColor];
            [self.view addSubview:loseScreenContainer];
            
            UIImageView *loseImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"two_players_lose_screen"]];
            [loseScreenContainer addSubview:loseImg];
            
            //输家的主菜单按钮
            SimulatePressButton *backToMenu = [SimulatePressButton buttonWithType:UIButtonTypeCustom];
            [backToMenu setImage:[UIImage imageNamed:@"backToMenu"] forState:UIControlStateNormal];
            backToMenu.frame = CGRectMake(0, 0, 274, 102);
            backToMenu.center = CGPointMake(loseScreenContainer.center.x, loseScreenContainer.center.y+60);
            [backToMenu addTarget:self action:@selector(onMainMenuClicked:) forControlEvents:UIControlEventTouchUpInside];
            [loseScreenContainer addSubview:backToMenu];
            
            SimulatePressButton *restartGame = [SimulatePressButton buttonWithType:UIButtonTypeCustom];
            [restartGame setImage:[UIImage imageNamed:@"restartGame"] forState:UIControlStateNormal];
            restartGame.frame = CGRectMake(0, 0, 300, 100);
            restartGame.center = CGPointMake(loseScreenContainer.center.x, loseScreenContainer.center.y+140);
            [restartGame addTarget:self action:@selector(onRestartGameClicked:) forControlEvents:UIControlEventTouchUpInside];
            [loseScreenContainer addSubview:restartGame];
            
            [super playBattleWinMusic];
            
            if (leftWidth <= 10) {
                //邪恶方赢了
                //正义方的输界面
                loseScreenContainer.center = CGPointMake(384, 841);
                [UIView animateWithDuration:3.2f 
                                      delay:0.0f 
                                    options:UIViewAnimationOptionAllowUserInteraction
                                 animations:^{
                                     lose_bg.alpha = 0.8f;
                                 } completion:^(BOOL finished) {
                                     
                                 }];
                
                //邪恶方的赢界面，需要rotate
                winScreenContainer.transform = CGAffineTransformMakeRotation(M_PI);
                [UIView animateWithDuration:0.3f animations:^{
                    winScreen1.transform = CGAffineTransformIdentity;
                } completion:^(BOOL finished) {
                    [UIView animateWithDuration:0.3f animations:^{
                        winScreen2.transform = CGAffineTransformIdentity;
                    }
                                     completion:^(BOOL finished) {
                                         SimulatePressButton *backToMenu = [SimulatePressButton buttonWithType:UIButtonTypeCustom];
                                         [backToMenu setImage:[UIImage imageNamed:@"backToMenu"] forState:UIControlStateNormal];
                                         backToMenu.frame = CGRectMake(0, 0, 274, 102);
                                         backToMenu.center = CGPointMake(winScreenContainer.center.x, 257);
                                         [backToMenu addTarget:self action:@selector(onMainMenuClicked:) forControlEvents:UIControlEventTouchUpInside];
                                         [winScreenContainer addSubview:backToMenu];
                                         
                                         SimulatePressButton *restartGame = [SimulatePressButton buttonWithType:UIButtonTypeCustom];
                                         [restartGame setImage:[UIImage imageNamed:@"restartGame"] forState:UIControlStateNormal];
                                         restartGame.frame = CGRectMake(0, 0, 300, 100);
                                         restartGame.center = CGPointMake(loseScreenContainer.center.x,330);
                                         [restartGame addTarget:self action:@selector(onRestartGameClicked:) forControlEvents:UIControlEventTouchUpInside];
                                         [winScreenContainer addSubview:restartGame];
                                     }];
                }];
            } else if (rightWidth <= 10) {
                //正义方赢了
                //正义方的赢界面
                winScreenContainer.center = CGPointMake(384, 841);
                [UIView animateWithDuration:0.3f animations:^{
                    winScreen1.transform = CGAffineTransformIdentity;
                } completion:^(BOOL finished) {
                    [UIView animateWithDuration:0.3f animations:^{
                        winScreen2.transform = CGAffineTransformIdentity;
                    }
                                     completion:^(BOOL finished) {
                                         SimulatePressButton *backToMenu = [SimulatePressButton buttonWithType:UIButtonTypeCustom];
                                         [backToMenu setImage:[UIImage imageNamed:@"backToMenu"] forState:UIControlStateNormal];
                                         backToMenu.frame = CGRectMake(0, 0, 274, 102);
                                         backToMenu.center = CGPointMake(winScreenContainer.center.x, 257);
                                         [backToMenu addTarget:self action:@selector(onMainMenuClicked:) forControlEvents:UIControlEventTouchUpInside];
                                         [winScreenContainer addSubview:backToMenu];
                                         
                                         SimulatePressButton *restartGame = [SimulatePressButton buttonWithType:UIButtonTypeCustom];
                                         [restartGame setImage:[UIImage imageNamed:@"restartGame"] forState:UIControlStateNormal];
                                         restartGame.frame = CGRectMake(0, 0, 300, 100);
                                         restartGame.center = CGPointMake(loseScreenContainer.center.x,330);
                                         [restartGame addTarget:self action:@selector(onRestartGameClicked:) forControlEvents:UIControlEventTouchUpInside];
                                         [winScreenContainer addSubview:restartGame];
                                     }];
                }];
                
                //邪恶方的输界面，需要旋转
                loseScreenContainer.transform = CGAffineTransformMakeRotation(M_PI);
                [UIView animateWithDuration:3.2f 
                                      delay:0.0f 
                                    options:UIViewAnimationOptionAllowUserInteraction
                                 animations:^{
                                     lose_bg.alpha = 0.8f;
                                 } completion:^(BOOL finished) {
                                     
                                 }];
            }
        }
    }
}

@end
