//
//  BaseGameViewController.h
//  learnEverything
//
//  Created by Yuanfeng on 12-06-05.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "Question.h"
#import "QuestionSet.h"
#import "AnimationViewController.h"

@interface BaseGameViewController : UIViewController <AVAudioPlayerDelegate>
{
    UIView *_pauseMenuContainer;
    UIView *_pauseMenuBackground;
    UIButton *_mainMenuButton;
    UIButton *_resumeGameButton;
    
    UIView *_leftDialog;
    UILabel *_leftDialogLbl;
    UIView *_rightDialog;
    UILabel *_rightDialogLbl;
    
@protected
    BOOL _gameDidTerminate;
    
    SystemSoundID _correctSound;
    SystemSoundID _clickSound;
    SystemSoundID _wrongAnswerSound;
    SystemSoundID _errorSound;
    
    QuestionSet *_questionSet;
    
    IBOutlet UIButton *_speakerBtn;
    IBOutlet UIButton *_speakerBtn2;
    
    AnimationViewController *_animationVC;
}

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property BOOL isGameOnPause;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer; //You have to retain the player to let it play!

- (NSMutableArray*)allQuestions;
- (NSMutableArray*)activeQuestionsFromQuestionSet;
- (NSMutableArray*)activeAndCompleteQuestionsFromQuestionSet;

- (IBAction)onPauseClicked:(id)sender;
- (IBAction)onSpeakerClicked:(id)sender;

- (void)playBackgroundMusic;

//For subclasses
- (void)onWillResignAvtiveNotificationReceived:(NSNotification*)notification;

- (void)onDidBecomeAvtiveNotificationReceived:(NSNotification*)notification;

- (void)gameDidTerminate;

- (void)showLeftDialogAtPosition:(CGPoint)originPosition withText:(NSString*)text;
- (void)showRightDialogAtPosition:(CGPoint)originPosition withText:(NSString*)text;
- (void)dismissLeftDialog;
- (void)dismissRightDialog;

- (BOOL)allowSound;
@end
