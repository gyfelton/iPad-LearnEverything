//
//  BaseGameViewController.h
//  learnEverything
//
//  Created by Yuanfeng on 12-06-05.
//  Copyright (c) 2012 ____Yuanfeng Gao___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "Question.h"
#import "QuestionSet.h"
#import "AnimationViewController.h"
#import "SimulatePressButton.h"

@interface BaseGameViewController : UIViewController <AVAudioPlayerDelegate>
{
    UIView *_pauseMenuContainer;
    UIView *_pauseMenuBackground;
    SimulatePressButton *_mainMenuButton;
    SimulatePressButton *_resumeGameButton;
    SimulatePressButton *_resrartGameButton;
    
@protected
    BOOL _gameDidTerminate;
    
    UIView *_leftDialog;
    UILabel *_leftDialogLbl;
    UIView *_rightDialog;
    UILabel *_rightDialogLbl;
    
    
    SystemSoundID _correctSound;
    SystemSoundID _clickSound;
    SystemSoundID _wrongAnswerSound;
    SystemSoundID _errorSound;
    
    QuestionSet *_questionSet;
    
    IBOutlet UIButton *_speakerBtn;
    IBOutlet UIButton *_speakerBtn2;
    
    AnimationViewController *_animationVC;
    
    //把传进的question list扩展成卡片数倍数长度的数组，并且在这上面做shuffle
    //保证对于manager是只读的
    NSMutableArray *_expandedQuestionList;
    
    BOOL _hasShowResultScreen;
}

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, readonly) NSMutableArray *expandedQuestionList;
@property BOOL isGameOnPause;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer; //You have to retain the player to let it play!

- (NSMutableArray*)activeQuestionsFromQuestionSet;
- (NSMutableArray*)activeAndCompleteQuestionsFromQuestionSet;

- (void)onMainMenuClicked:(id)sender;
- (IBAction)onPauseClicked:(id)sender;
- (IBAction)onSpeakerClicked:(id)sender;

- (void)playBackgroundMusic;

- (void)playBattleWinMusic;
- (void)playBattleLoseMusic;

//For subclasses
- (void)onWillResignAvtiveNotificationReceived:(NSNotification*)notification;

- (void)onDidBecomeAvtiveNotificationReceived:(NSNotification*)notification;

- (void)gameDidTerminate;

- (void)showLeftDialogAtPosition:(CGPoint)originPosition withText:(NSString*)text;
- (void)showRightDialogAtPosition:(CGPoint)originPosition withText:(NSString*)text;

//- (void)showLeftDialogAtPosition:(CGPoint)originPosition withText:(NSString*)text afterDelay:(NSTimeInterval)delay dismissAfterDelay:(NSTimeInterval)delay;
//- (void)showRightDialogAtPosition:(CGPoint)originPosition withText:(NSString*)text afterDelay:(NSTimeInterval)delay dismissAfterDelay:(NSTimeInterval)delay;

- (void)showLeftDialogAtPosition:(CGPoint)originPosition withText:(NSString*)text dismissAfterDelay:(NSTimeInterval)delay;
- (void)showRightDialogAtPosition:(CGPoint)originPosition withText:(NSString*)text dismissAfterDelay:(NSTimeInterval)delay;
- (void)dismissLeftDialog;
- (void)dismissRightDialog;

- (BOOL)allowSound;
@end
