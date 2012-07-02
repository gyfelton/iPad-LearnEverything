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
    
    __unsafe_unretained IBOutlet UIImageView *left_hero;
    __unsafe_unretained IBOutlet UIImageView *_right_flame;
    __unsafe_unretained IBOutlet UIImageView *_shield;
    
    CGFloat _score;
}

@property (nonatomic, setter = setScore: ) CGFloat score; //Range from 0 to 1

@end
