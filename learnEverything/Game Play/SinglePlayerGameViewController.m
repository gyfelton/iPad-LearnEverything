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

#define ROW_NUMBER 4
#define COLUMN_NUMBER 5

@implementation SinglePlayerGameViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - Animations
- (void)showInitialDialogs
{
    [super showLeftDialogAtPosition:CGPointMake(100, 141) withText:@"小朋友快来帮忙！\n正确配对下面的英文和图片，\n就能给我力量帮助打倒怪兽！"];
    [self performSelector:@selector(showInitialRightDialog) withObject:nil afterDelay:2.0f];
}

- (void)showInitialRightDialog
{
    [super dismissLeftDialog];
    [super showRightDialogAtPosition:CGPointMake(700, 133) withText:@"ARR....\nARRRRR....."];
    [super performSelector:@selector(dismissRightDialog) withObject:nil afterDelay:2.0f];
}

- (void)presentCardsAnimated
{   
    _grid_view.hidden = NO;
    [_grid_view layoutUnitsAnimatedWithAnimationDirection:kGridViewAnimationFlowFromBottom];
    [self performSelector:@selector(showInitialDialogs) withObject:nil afterDelay:0.1f];
}

- (void)showCountDown:(NSNumber*)num
{
    int number = [num intValue];
    if (!_countdownImageView) {
        _countdownImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 200, 300)];
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
    [self showCountDown:[NSNumber numberWithInt:3]];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.wantsFullScreenLayout = YES;
	// Do any additional setup after loading the view, typically from a nib.
    _questionList = [super allQuestions];
    
    _grid_view = [[NonScrollableGridView alloc] initWithFrame:_grid_view_place_holder.frame];
    _grid_view.dataSource = self;
    
    [self.view insertSubview:_grid_view aboveSubview:_grid_view_place_holder];
    
    //Hide the grid view first
    _grid_view.hidden = YES;
    
    [_grid_view_place_holder removeFromSuperview];
    
    _questionManager = [[QuestionManager alloc] initWithGridView:_grid_view questionList:_questionList];
    _questionManager.questionManagerDelegate = self;
    _questionManager.isFlipCards = NO;//Flip cards is not a good idea for now
    
    [self reinitGame];
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
    
    [self startMusicAndShowCountDown];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return LANDSCAPE_ORIENTATION;
    }
}

- (void)reinitGame
{
    //Init the question list
    [_questionManager reinitGame];
}

#pragma mark - NonScrollableGridView DataSource
- (NSInteger)numberOfRowsForNonScrollableGridView:(NonScrollableGridView *)gridView
{
    return [_questionList count]>0? ROW_NUMBER : 0;
}

- (NSInteger)numberOfColumnsForNonScrollableGridView:(NonScrollableGridView *)gridView
{
    return [_questionList count]>0? COLUMN_NUMBER : 0;
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


#pragma mark - QuestionManager Delegate
- (void)_animateStarMovement:(UIView*)star
{
    [UIView animateWithDuration:0.6f delay:0.1f 
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         CGFloat scale = 0.2f;
                         star.frame = CGRectMake(20, 80, star.frame.size.width*scale, star.frame.size.height*scale);
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
                          
                         _progressBar.progress +=0.025f;
                         
                     }];
}

- (void)_animateFlameMovement:(UIView*)flame
{
    [UIView animateWithDuration:0.6f delay:0.1f 
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         CGFloat scale = 0.2f;
                         flame.frame = CGRectMake(920, 80, flame.frame.size.width*scale, flame.frame.size.height*scale);
                         //CGAffineTransform movement = CGAffineTransformMakeTranslation(/scale, (80 - star.frame.origin.y)/scale);
                         //CGAffineTransform shrinkDown = CGAffineTransformMakeScale(scale, scale);
                         //star.transform = CGAffineTransformConcat(movement, shrinkDown);
                     } 
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.2f animations:^{
                             //                             star.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
                         } completion:^(BOOL finished) {
                             [flame removeFromSuperview];
                         }];
                         
                         _progressBar.progress -=0.025f;
                         
                     }];
}

- (void)animateStarToLightHeroAndIncrementScore:(UIView*)star
{
    star.transform = CGAffineTransformMakeScale(0.01, 0.01);
    [UIView animateWithDuration:0.1f 
                     animations:^(){
                         star.transform = CGAffineTransformIdentity;
    }
                     completion:^(BOOL finished){
                         [self _animateStarMovement:star];
                     }
    ];
}

- (void)animateStarToDarkSideAndDecrementScore:(UIView*)flame
{
    flame.transform = CGAffineTransformMakeScale(0.01, 0.01);
    [UIView animateWithDuration:0.1f 
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
    
    AudioServicesPlaySystemSound(_correctSound);  // 播放SoundID声音
}

- (void)QuestionManager:(QuestionManager *)manager answerWronglyWithCard1:(QuestionCard *)card1 card2:(QuestionCard *)card2
{
    //Animate flame
    CGRect rect = [card1 convertRect:card1.bounds toView:self.view];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:rect];
    imageView.image = [UIImage imageNamed:@"flame"];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    [self.view addSubview:imageView];
    [self animateStarToDarkSideAndDecrementScore:imageView];
    
    
    CGRect rect2 = [card2 convertRect:card2.bounds toView:self.view];
    UIImageView *imageView2 = [[UIImageView alloc] initWithFrame:rect2];
    imageView2.image = [UIImage imageNamed:@"flame"];
    imageView2.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:imageView2];
    [self animateStarToDarkSideAndDecrementScore:imageView2];
    
    AudioServicesPlaySystemSound(_wrongAnswerSound);  // 播放SoundID声音
}

- (void)QuestionManager:(QuestionManager *)manager clickOnCard:(QuestionCard *)card
{
    AudioServicesPlaySystemSound(_clickSound);  // 播放SoundID声音
}
@end
