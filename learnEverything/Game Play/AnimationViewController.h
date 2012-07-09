//
//  AnimationViewController.h
//  learnEverything
//
//  Created by Yuanfeng on 12-06-28.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AnimationViewController : UIViewController
{
    
    IBOutlet UIImageView *left_hero;
    IBOutlet UIImageView *_right_flame;
    IBOutlet UIImageView *_left_bo;
    
    CGFloat _score;
    
    BOOL _isSinglePlayerMode;
}
- (id)initInSinglePlayerMode:(BOOL)singlePlayer;

@property (nonatomic, readonly) BOOL isSinglePlayerMode;
@property (nonatomic, setter = setScore: ) CGFloat score; //Range from 0 to 1

@end
