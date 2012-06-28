//
//  StartViewController.h
//  learnEverything
//
//  Created by Yuanfeng on 12-06-02.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RoundedButton.h"

@interface StartViewController : UIViewController
{
    __unsafe_unretained IBOutlet UIImageView *_mainTitle;
    __unsafe_unretained IBOutlet UIImageView *_main_bg;
    
    __unsafe_unretained IBOutlet UIButton *_singleButton;

    __unsafe_unretained IBOutlet UIButton *_dualButton;
    
    __unsafe_unretained IBOutlet UIButton *_editQuestionSetButton;
}

- (IBAction)onSinglePlayerGameClicked:(id)sender;
- (IBAction)onTwoPlayersGameClicked:(id)sender;
- (IBAction)onEditQuestionSetList:(id)sender;
- (IBAction)onInfoBtnClicked:(id)sender;

@end
