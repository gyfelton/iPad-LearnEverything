//
//  StartViewController.m
//  learnEverything
//
//  Created by Yuanfeng on 12-06-02.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "StartViewController.h"
#import "AppDelegate.h"
#import "SinglePlayerGameViewController.h"
#import "ParentControlViewController.h"
#import "QuestionSetViewController.h"
#import "FileIOSharedManager.h"

@interface StartViewController (Private)
- (void)_breathMainTitleFade;
@end

@implementation StartViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"开始游戏";
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

- (void)viewDidLoad
{
    [super viewDidLoad];
//    self.view.backgroundColor = [UIColor clearColor];
    // Do any additional setup after loading the view from its nib.
    _singleButton.hidden = YES;
    _dualButton.hidden = YES;
    
    _hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:_hud];
    
    _hud.yOffset = 50;
    _hud.labelText = @"检查题库更新中，请稍等";
    [_hud show:YES];
    
    _checkQSJFile = YES;
    [self performSelector:@selector(checkQSJFiles) withObject:nil afterDelay:1.3f];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _editQuestionSetButton.hidden = YES;
    _mainTitle.alpha = 1.0f;
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)aniamteViews
{
    [self performSelector:@selector(_animateCurl) withObject:nil afterDelay:0.1f];
    _breathTitle = YES;
    [self _breathMainTitleFade];
}

- (void)checkQSJFiles
{
    [[FileIOSharedManager sharedManager] checkCachedQuestionSetsWithCompletion:^(BOOL finished) {
        [_hud hide:YES];
        _checkQSJFile = NO;
        [self aniamteViews];
        [UIView animateWithDuration:0.6f 
                         animations:^{
            _singleButton.hidden = NO;
            _dualButton.hidden = NO;
        }];
    }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (!_checkQSJFile) {
        [self aniamteViews];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    _breathTitle = NO;
    [_main_bg.layer removeAllAnimations];
}

- (void)_animateCurl
{
    
    // Curl the image up or down
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.8f];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    animation.delegate = self;
    animation.type = @"pageCurl";
    animation.subtype = @"fromRight";
    animation.fillMode = kCAFillModeForwards;
    animation.endProgress = 0.185f;
    
    animation.removedOnCompletion = NO;
    
    [_main_bg.layer addAnimation:animation forKey:@"pageCurlAnimation"];
    
    _editQuestionSetButton.hidden = NO;
    [_main_bg addSubview:_editQuestionSetButton];
}

- (void)_breathMainTitleOut
{
    [UIView animateWithDuration:1.3f 
                          delay:0.0f 
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         _mainTitle.alpha = 1.0f;
                     } completion:^(BOOL finished) {
                         if (finished) {
                             [self _breathMainTitleFade];
                         }
                     }];
}

- (void)_breathMainTitleFade
{
    [UIView animateWithDuration:1.3f 
                          delay:0.0f 
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
        _mainTitle.alpha = 0.3f;
    } completion:^(BOOL finished) {
        if (finished) {
            if (_breathTitle)
            {
                [self _breathMainTitleOut];
        
            }
        }
    }];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return LANDSCAPE_ORIENTATION;
}

- (void)pushQuestionSetViewController:(BOOL)isSinglePlayer
{
    QuestionSetViewController *chooseQuestionSet = [[QuestionSetViewController alloc] initWithViewControllerType:kChooseGameSet];
    
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    chooseQuestionSet.managedObjectContext = appDelegate.managedObjectContext;
    
    chooseQuestionSet.isSinglePlayerMode = isSinglePlayer;
    
    [self.navigationController pushViewController:chooseQuestionSet animated:NO];
    [self.navigationController setNavigationBarHidden:YES];
}

- (IBAction)onSinglePlayerGameClicked:(id)sender {

    [self pushQuestionSetViewController:YES];
}

- (IBAction)onTwoPlayersGameClicked:(id)sender
{
    [self pushQuestionSetViewController:NO];
}

- (IBAction)onEditQuestionSetList:(id)sender {
    ParentControlViewController *parentControl = [[ParentControlViewController alloc] initWithNibName:nil bundle:nil];
    
    [self.navigationController pushViewController:parentControl animated:YES];
}

- (IBAction)onInfoBtnClicked:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"“勇者斗恶龙”\nv0.9" message:@"开发者：高元丰，罗泽响，陈团安\n本应用仅供参加网易“有道难题”比赛，禁止用于任何商业用途\n©2012 高元丰 保留所有权利" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
}

- (void)viewDidUnload {
    _singleButton = nil;
    _dualButton = nil;
    _editQuestionSetButton = nil;
    _mainTitle = nil;
    _main_bg = nil;
    [super viewDidUnload];
}
@end
