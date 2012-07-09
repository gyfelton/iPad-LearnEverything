//
//  AnimationViewController.h
//  learnEverything
//
//  Created by Yuanfeng on 12-06-28.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#define GameProgressNotificationWithInfoDictionry_KEY @"GameProgressNotificationWithInfoDictionry_KEY"

@interface AnimationViewController : UIViewController
{
    
    IBOutlet UIImageView *left_hero;
    IBOutlet UIImageView *_right_flame;
    IBOutlet UIImageView *_right_dinasour;
    IBOutlet UIImageView *_left_bo;
    __unsafe_unretained IBOutlet UIImageView *_left_hero_down;
    IBOutlet UIImageView *_right_dinasour_down;
    
    CGFloat _score;
    
    BOOL _isSinglePlayerMode;
}

- (id)initInSinglePlayerMode:(BOOL)singlePlayer;
- (void)showLeftHeroDown;
- (void)showRightDinasourDown;

@property (nonatomic, readonly) BOOL isSinglePlayerMode;
@property (nonatomic, setter = setScore: ) CGFloat score; //Range from 0 to 1

@end
