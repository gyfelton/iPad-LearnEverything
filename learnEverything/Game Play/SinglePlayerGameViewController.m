//
//  ViewController.m
//  learnEverything
//
//  Created by Yuanfeng on 12-06-01.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SinglePlayerGameViewController.h"
#import "NSMutableArray+Shuffling.h"
#import "AppDelegate.h"
#import "Question.h"
#import "QuestionCard.h"

//Make sure ROW_NUMBER * COLUMN_NUMBER gives a even number!
#define ROW_NUMBER 4
#define COLUMN_NUMBER 5

@implementation SinglePlayerGameViewController

-(id)initWithManagedContext:(NSManagedObjectContext *)context questionSet:(QuestionSet *)questionSet
{
    self = [super initWithNibName:@"SinglePlayerGameViewController_iPad" bundle:nil];
    if (self)
    {
        self.managedObjectContext = context;
        _questionSet = questionSet;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - Animations
- (void)showInitialDialog1
{
    [super showLeftDialogAtPosition:CGPointMake(100, 141) withText:@"小朋友快来帮忙!"];
    [self performSelector:@selector(showInitialDialog2) withObject:nil afterDelay:2.0f];
}

- (void)showInitialDialog2
{
    [super showLeftDialogAtPosition:CGPointMake(100, 141) withText:@"正确配对下面的英文和图片,"];
    [self performSelector:@selector(showInitialDialog3) withObject:nil afterDelay:2.0f];
}

- (void)showInitialDialog3
{
    [super showLeftDialogAtPosition:CGPointMake(100, 141) withText:@"就能给我力量帮助打倒怪兽!"];
    [self performSelector:@selector(dismissLeftDialog) withObject:nil afterDelay:2.0f];
    [self performSelector:@selector(showInitialRightDialog1) withObject:nil afterDelay:2.0f];
}

- (void)showInitialRightDialog1
{
    [super dismissLeftDialog];
    [super showRightDialogAtPosition:CGPointMake(700, 133) withText:@"哈哈哈哈哈!"];
    [super performSelector:@selector(showInitialRightDialog2) withObject:nil afterDelay:2.0f];
}

- (void)showInitialRightDialog2
{
    [super dismissLeftDialog];
    [super showRightDialogAtPosition:CGPointMake(700, 133) withText:@"你打不倒我的!!!"];
    [super performSelector:@selector(dismissRightDialog) withObject:nil afterDelay:2.0f];
}
 
- (void)presentCardsAnimated
{   
    _grid_view.hidden = NO;
    [_grid_view layoutUnitsAnimatedWithAnimationDirection:kGridViewAnimationFlowFromBottom];
    [self performSelector:@selector(showInitialDialog1) withObject:nil afterDelay:0.1f];
}

- (void)showCountDown:(NSNumber*)num
{
    int number = [num intValue];
    if (!_countdownImageView) {
        _countdownImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 300, 450)];
        [self.view addSubview:_countdownImageView];
    }
    
    _countdownImageView.center = CGPointMake(512, 500);
    
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

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.wantsFullScreenLayout = YES;
	// Do any additional setup after loading the view, typically from a nib.
    
    _grid_view = [[NonScrollableGridView alloc] initWithFrame:_grid_view_place_holder.frame];
    _grid_view.dataSource = self;
    _grid_view.backgroundColor = [UIColor clearColor];
    
    [self.view insertSubview:_grid_view aboveSubview:_grid_view_place_holder];
    
    //Hide the grid view first
    _grid_view.hidden = YES;
    
    [_grid_view_place_holder removeFromSuperview];
    
    [self reinitGame];
    
    _animationVC = [[AnimationViewController alloc] initInSinglePlayerMode:YES];
    [_animationStageView addSubview:_animationVC.view];
    
    [self performSelector:@selector(startMusicAndShowCountDown) withObject:nil afterDelay:1.0f];
}

- (void)dismissCountdownAndStartGame
{
    [_countdownImageView removeFromSuperview];
    _countdownImageView = nil;
    
    [self presentCardsAnimated];
    
    //Not used:
    //flip cards here
    //[_questionManager flipAllCardsWithAnimation:NO]; //YES will not work
}

- (void)viewDidUnload
{
    _grid_view_place_holder = nil;
    _grid_view = nil;
    _questionList = nil;
    _questionManager = nil;
    _progressBar = nil;
    _animationStageView = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return LANDSCAPE_ORIENTATION;
}

- (void)reinitGame
{
    //Prepare the expandedQuestionList
    _questionList = [super activeAndCompleteQuestionsFromQuestionSet];
    _expandedQuestionList = [[NSMutableArray alloc] initWithArray:_questionList];
    [_expandedQuestionList shuffle];
    
    //Assign a new QuestionCardsManager
    _questionManager = [[QuestionCardsManager alloc] initWithGridView:_grid_view questionList:self.expandedQuestionList questionType:[_questionSet.question_type intValue] numberOfCardsInGridView:ROW_NUMBER*COLUMN_NUMBER];
    _questionManager.customDelegate = self;
    
    [_grid_view reloadData];
}

#pragma mark - NonScrollableGridView DataSource
- (NSInteger)numberOfRowsForNonScrollableGridView:(NonScrollableGridView *)gridView
{
    return [_expandedQuestionList count]>0? ROW_NUMBER : 0;
}

- (NSInteger)numberOfColumnsForNonScrollableGridView:(NonScrollableGridView *)gridView
{
    return [_expandedQuestionList count]>0? COLUMN_NUMBER : 0;
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
    return [_questionManager viewForNonScrollableGridViewAtRowIndex:rowIndex columnIndex:columnIndex];
}

#pragma mark - QuestionCardsManager Delegate
- (void)_animateStarMovement:(UIView*)star
{
    [UIView animateWithDuration:0.6f delay:0.1f 
                        options:UIViewAnimationOptionCurveEaseInOut + UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         CGFloat scale = 0.2f;
                         star.frame = CGRectMake(65, 133, star.frame.size.width*scale, star.frame.size.height*scale);
                         //CGAffineTransform movement = CGAffineTransformMakeTranslation(/scale, (80 - star.frame.origin.y)/scale);
                         //CGAffineTransform shrinkDown = CGAffineTransformMakeScale(scale, scale);
                         //star.transform = CGAffineTransformConcat(movement, shrinkDown);
                         star.transform = CGAffineTransformMakeRotation(M_PI);
                     } 
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.2f 
                                               delay:0.0f 
                                             options:UIViewAnimationOptionAllowUserInteraction
                                          animations:^{
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
                        options:UIViewAnimationOptionCurveEaseInOut + UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         CGFloat scale = 0.2f;
                         flame.frame = CGRectMake(930, 130, flame.frame.size.width*scale, flame.frame.size.height*scale);
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

- (void)QuestionCardsManager:(QuestionCardsManager *)manager answerCorrectlyWithCard1:(QuestionCard *)card1 card2:(QuestionCard *)card2
{
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

- (void)QuestionCardsManager:(QuestionCardsManager *)manager answerWronglyWithCard1:(QuestionCard *)card1 card2:(QuestionCard *)card2
{
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
    
    if ([self allowSound]) AudioServicesPlaySystemSound(_wrongAnswerSound);  // 播放SoundID声音
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

- (void)QuestionCardsManager:(QuestionCardsManager *)manager clickOnCard:(QuestionCard *)card
{
    if ([self allowSound]) AudioServicesPlaySystemSound(_clickSound);  // 播放SoundID声音
}

- (void)QuestionCardsManager:(QuestionCardsManager *)manager clickOnSameTypeCardsWithCard1:(QuestionCard *)card1 card2:(QuestionCard *)card2
{
    if ([self allowSound]) AudioServicesPlaySystemSound(_errorSound);  // 播放SoundID声音
}


#pragma mark - Game Progress
- (void)showLeftDialogCritical
{
    [super showLeftDialogAtPosition:CGPointMake(100, 141) withText:@"快配对正确的卡片！" dismissAfterDelay:2.0f];
    [super performSelector:@selector(showLeftDialogCritical2) withObject:nil afterDelay:2.0f];
}


- (void)showLeftDialogCritical2
{
    [super showLeftDialogAtPosition:CGPointMake(100, 141) withText:@"我快撑不住了！" dismissAfterDelay:2.0f];
    [super performSelector:@selector(showLeftDialogCritical3) withObject:nil afterDelay:2.0f];
}

- (void)showLeftDialogCritical3
{
    [super showRightDialogAtPosition:CGPointMake(700, 133) withText:@"哈哈哈哈哈!" dismissAfterDelay:2.0f];
}

- (void)showLeftDialogNearlyWin
{
    [super showLeftDialogAtPosition:CGPointMake(100, 141) withText:@"就差一点了，\nCome on！" dismissAfterDelay:2.0f];
}

- (void)onGameProgressDictReceived:(NSNotification*)notification
{
    NSDictionary *info = [notification object];
    CGFloat leftWidth = [[info objectForKey:@"left_width"] floatValue];
    CGFloat rightWidth = [[info objectForKey:@"right_width"] floatValue];
    CGFloat totalWidth = [[info objectForKey:@"total_width"] floatValue];

    if (leftWidth == 255) {
        [self showLeftDialogCritical];
    }
    if (rightWidth == 255) {
        [self showLeftDialogNearlyWin];
    }
    
    if (leftWidth <= 10) {
        //Lose
        if (!_hasShowResultScreen) {
            _hasShowResultScreen = YES;
            
            UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
            UIView *bg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
            bg.backgroundColor = [UIColor colorWithRed:0.87f green:0.18f blue:0.12f alpha:1.0f];
            bg.alpha = 0.0f;
            [container addSubview:bg];
            container.backgroundColor = [UIColor clearColor];
            
            //Back to menu btn
            SimulatePressButton *backToMenu = [SimulatePressButton buttonWithType:UIButtonTypeCustom];
            [backToMenu setImage:[UIImage imageNamed:@"backToMenu"] forState:UIControlStateNormal];
            backToMenu.frame = CGRectMake(0, 0, 274, 102);
            backToMenu.center = CGPointMake(container.center.x, container.center.y+100);
            [backToMenu addTarget:self action:@selector(onMainMenuClicked:) forControlEvents:UIControlEventTouchUpInside];
            [container addSubview:backToMenu];
            
            SimulatePressButton *restartGame = [SimulatePressButton buttonWithType:UIButtonTypeCustom];
            [restartGame setImage:[UIImage imageNamed:@"restartGame"] forState:UIControlStateNormal];
            restartGame.frame = CGRectMake(0, 0, 300, 100);
            restartGame.center = CGPointMake(container.center.x,container.center.y+190);
            [restartGame addTarget:self action:@selector(onRestartGameClicked:) forControlEvents:UIControlEventTouchUpInside];
            [container addSubview:restartGame];
            
            [self.view addSubview:container];
            
            UIImageView *img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lose_Screen"]];
            [container addSubview:img];
            [UIView animateWithDuration:3.2f 
                                  delay:0.0f 
                                options:UIViewAnimationOptionAllowUserInteraction
                             animations:^{
                                 bg.alpha = 0.8f;
                             } completion:^(BOOL finished) {
                                 
                             }];
            [_animationVC showLeftHeroDown];
            [super playBattleLoseMusic];
        }
    } else if (rightWidth <= 10) {
        //Win
        if (!_hasShowResultScreen) {
            _hasShowResultScreen = YES;
            
            UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
            [self.view addSubview:container];
            container.backgroundColor =  [UIColor clearColor];
            UIView *bg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
            bg.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.4f];
            [container addSubview:bg];
            
            UIImageView *winScreen1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"win_screen_1"]];
            UIImageView *winScreen2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"win_screen_2"]];
            winScreen1.backgroundColor = [UIColor clearColor];
            winScreen2.backgroundColor = [UIColor clearColor];
            winScreen1.transform = CGAffineTransformMakeScale(0.01f, 0.01f);
            winScreen2.transform = CGAffineTransformMakeScale(0.01f, 0.01f);
            [container addSubview:winScreen1];
            [container addSubview:winScreen2];
            
            [UIView animateWithDuration:0.3f animations:^{
                winScreen1.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.3f 
                                      delay:0.2f 
                                    options:UIViewAnimationOptionAllowAnimatedContent
                                 animations:^{
                    winScreen2.transform = CGAffineTransformIdentity;
                }
                                 completion:^(BOOL finished) {
                                     SimulatePressButton *backToMenu = [SimulatePressButton buttonWithType:UIButtonTypeCustom];
                                     [backToMenu setImage:[UIImage imageNamed:@"backToMenu"] forState:UIControlStateNormal];
                                     backToMenu.frame = CGRectMake(0, 0, 274, 102);
                                     backToMenu.center = CGPointMake(container.center.x, container.center.y+100);
                                     [backToMenu addTarget:self action:@selector(onMainMenuClicked:) forControlEvents:UIControlEventTouchUpInside];
                                     [container addSubview:backToMenu];
                                     
                                     SimulatePressButton *restartGame = [SimulatePressButton buttonWithType:UIButtonTypeCustom];
                                     [restartGame setImage:[UIImage imageNamed:@"restartGame"] forState:UIControlStateNormal];
                                     restartGame.frame = CGRectMake(0, 0, 300, 100);
                                     restartGame.center = CGPointMake(container.center.x,container.center.y+190);
                                     [restartGame addTarget:self action:@selector(onRestartGameClicked:) forControlEvents:UIControlEventTouchUpInside];
                                     [container addSubview:restartGame];
                                 }];
            }];
            [_animationVC showRightDinasourDown];
            [super playBattleWinMusic];
        }
    }
}
@end
