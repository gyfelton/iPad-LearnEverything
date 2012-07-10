//
//  AppDelegate.h
//  learnEverything
//
//  Created by Yuanfeng on 12-06-01.
//  Copyright (c) 2012 ____Yuanfeng Gao___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import "StartViewController.h"
#import "MBProgressHUD.h"

#define CURRENT_CORE_DATA_DB_NAME @"learnEverythingCoreDataMain_9July2012"

@class QuestionSet;
@class TwoPlayersGameViewController;
@class SinglePlayerGameViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    UINavigationController *_startVCNav;
    MBProgressHUD *_hud;
    
    NSMutableArray *_battleMusicPathArray;
    
    SystemSoundID _clickSound;
}
//View Controllers
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController *baseNavigationController;
@property (strong, nonatomic) SinglePlayerGameViewController *singlePlayerGameViewController;
@property (strong, nonatomic) TwoPlayersGameViewController *twoPlayersGameViewController;

//Core Data Related
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

//Sounds
@property (readonly) SystemSoundID clickSound;

- (void)playClickSound;
- (NSString*)getBattleMusicPath;

- (void)showStartScreenAnimated;
- (void)prepareForSinglePlayerGameWithQuestionSet:(QuestionSet*)questionset;
- (void)prepareForTwoPlayersGameQuestionSet:(QuestionSet*)questionset;


- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

//Show HUDs
- (void)showMailHUD:(BOOL)sent;
- (void)showCheckQSJFilesHUD;
- (void)showLoadingGameHUD;
- (void)dismissHUDAfterDelay:(CGFloat)delay;
@end
