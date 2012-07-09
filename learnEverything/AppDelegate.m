//
//  AppDelegate.m
//  learnEverything
//
//  Created by Yuanfeng on 12-06-01.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"

#import "SinglePlayerGameViewController.h"
#import "TwoPlayersGameViewController.h"
#import "ParentControlViewController.h"
#import "FileIOSharedManager.h"
#import "ForceLandscapeEmptyViewController.h"

@implementation AppDelegate
@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;
@synthesize window = _window;
@synthesize baseNavigationController;
@synthesize singlePlayerGameViewController;
@synthesize twoPlayersGameViewController;

- (void)showStartScreenAnimated
{
    [self.window.rootViewController presentModalViewController:_startVCNav animated:NO];
}

- (void)prepareForSinglePlayerGameWithQuestionSet:(QuestionSet*)questionset
{
    //Not designed for iPhone yet
    self.singlePlayerGameViewController = [[SinglePlayerGameViewController alloc] initWithManagedContext:self.managedObjectContext questionSet:questionset];
    
    [self.baseNavigationController popToRootViewControllerAnimated:NO];
    [self.baseNavigationController pushViewController:self.singlePlayerGameViewController animated:NO];
    [self.singlePlayerGameViewController.navigationController setNavigationBarHidden:YES];
}

- (void)prepareForTwoPlayersGameQuestionSet:(QuestionSet*)questionset
{
    self.twoPlayersGameViewController = [[TwoPlayersGameViewController alloc] initWithManagedContext:self.managedObjectContext questionSet:questionset];
    
    [self.baseNavigationController popToRootViewControllerAnimated:NO];
    [self.baseNavigationController pushViewController:self.twoPlayersGameViewController animated:NO];
    [self.twoPlayersGameViewController.navigationController setNavigationBarHidden:YES];
}

- (void)beginParseQSJFileWithURL:(NSURL*)url
{
    BOOL success = [[FileIOSharedManager sharedManager] parseQSJFileWithURL:url];
    NSString *path = [url absoluteString];
    path = [path lastPathComponent];
    path = [path stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    if ([path length] > 7) {
        path = [[path substringToIndex:7] stringByAppendingString:@"...qsj"];
    }
    UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 37, 37)];
    _hud.customView = img;
    _hud.mode = MBProgressHUDModeCustomView;
    if (success)
    {
        img.image = [UIImage imageNamed:@"tick_s"];
        _hud.labelText = [NSString stringWithFormat:@"载入 %@ 题库成功", path];
        [[NSNotificationCenter defaultCenter] postNotificationName:QSJ_FILE_RECEIVED_AND_PARSE_SUCCESSFULL_NOTIFICATION object:url];
    } else
    {
        img.image = [UIImage imageNamed:@"cross_s"];
        _hud.labelText = @"载入题库失败，请重试";
    }
    [_hud hide:YES afterDelay:1.6f];
}

- (void)showMailHUD:(BOOL)sent
{
    UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 37, 37)];
    if (sent) {
        img.image = [UIImage imageNamed:@"tick_s"];
        _hud.labelText = [NSString stringWithFormat:@"题库发送成功！"];
    } else
    {
        img.image = [UIImage imageNamed:@"cross_s"];
        _hud.labelText = [NSString stringWithFormat:@"题库发送失败！请重试"];

    }
    _hud.customView = img;
    _hud.mode = MBProgressHUDModeCustomView;
    [_hud show:YES];
    [_hud hide:YES afterDelay:1.0f];
}
    
- (void)showLoadingGameHUD
{
    _hud.mode = MBProgressHUDModeIndeterminate;
    _hud.labelText = @"载入游戏中...";
    [_hud show:NO];
}

- (void)showCheckQSJFilesHUD
{
    _hud.mode = MBProgressHUDModeIndeterminate;
    _hud.labelText = @"初始化题库数据中，请稍等";
    [_hud show:YES];
}

- (void)dismissHUDAfterDelay:(CGFloat)delay
{
    [_hud hide:YES afterDelay:delay];
}

- (BOOL)processURLIfIsFileURL:(NSURL*)url
{
    if ([url isFileURL]) {
        //Handle qsj file here
        NSString *path = [url absoluteString];
        path = [path lastPathComponent];
        path = [path stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        if ([path length] > 7) {
            path = [[path substringToIndex:7] stringByAppendingString:@"...qsj"];
        }
        _hud.mode = MBProgressHUDModeIndeterminate;
        _hud.labelText = [NSString stringWithFormat:@"载入 %@ 题库中...", path];
        [_hud show:YES];
        [self performSelector:@selector(beginParseQSJFileWithURL:) withObject:url afterDelay:0.3f];
    }
    return YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{   
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.baseNavigationController = [[UINavigationController alloc] initWithRootViewController:[[ForceLandscapeEmptyViewController alloc] initWithNibName:nil bundle:nil]];
    
    self.window.rootViewController = self.baseNavigationController;
    
    [self.window makeKeyAndVisible];
    

//    UIImageView *baseBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"main_bg_full_screen"]];
//    baseBackground.frame = self.window.frame;
//    [self.window addSubview:baseBackground];
//    [self.window sendSubviewToBack:baseBackground];
    
    //Should not call here
//    NSURL *url = (NSURL *)[launchOptions valueForKey:UIApplicationLaunchOptionsURLKey];
//    [self processURLIfIsFileURL:url];
    StartViewController *startVC = [[StartViewController alloc] initWithNibName:nil bundle:nil];
    _startVCNav = [[UINavigationController alloc] initWithRootViewController:startVC];
    [self showStartScreenAnimated];
    
    if (!_hud) {
        _hud = [[MBProgressHUD alloc] initWithWindow:self.window];
        _hud.dimBackground = YES;
        [self.window addSubview:_hud];
        _hud.yOffset = 50;
    }
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    [self processURLIfIsFileURL:url];
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    [self processURLIfIsFileURL:url];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
    [self saveContext];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
    [self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext
{
    if (__managedObjectContext != nil)
    {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
        
        //Undo Support
        NSUndoManager *anUndoManager = [[NSUndoManager alloc] init];
        [__managedObjectContext setUndoManager:anUndoManager];
    }
    return __managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil)
    {
        return __managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"QuestionModel" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return __managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil)
    {
        return __persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"CoreDataMain.sqlite"];
    
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    // handle db upgrade  
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:  
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,  
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil]; 
    
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error])
    {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return __persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
