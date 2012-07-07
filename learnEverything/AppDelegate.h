//
//  AppDelegate.h
//  learnEverything
//
//  Created by Yuanfeng on 12-06-01.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StartViewController.h"

@class QuestionSet;
@class TwoPlayersGameViewController;
@class SinglePlayerGameViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    UINavigationController *_startVCNav;
}
@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UINavigationController *baseNavigationController;
@property (strong, nonatomic) SinglePlayerGameViewController *singlePlayerGameViewController;
@property (strong, nonatomic) TwoPlayersGameViewController *twoPlayersGameViewController;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)showStartScreenAnimated;

- (void)prepareForSinglePlayerGameWithQuestionSet:(QuestionSet*)questionset;
- (void)prepareForTwoPlayersGameQuestionSet:(QuestionSet*)questionset;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
