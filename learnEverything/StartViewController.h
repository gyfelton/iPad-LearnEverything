//
//  StartViewController.h
//  learnEverything
//
//  Created by Yuanfeng on 12-06-02.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface StartViewController : UIViewController
{
    __unsafe_unretained IBOutlet UIImageView *_mainTitle;
    __unsafe_unretained IBOutlet UIImageView *_main_bg;
    
    __unsafe_unretained IBOutlet SimulatePressButton *_singleButton;

    __unsafe_unretained IBOutlet SimulatePressButton *_dualButton;
    
    __unsafe_unretained IBOutlet SimulatePressButton *_editQuestionSetButton;
    
    BOOL _breathTitle;
}

- (IBAction)onSinglePlayerGameClicked:(id)sender;
- (IBAction)onTwoPlayersGameClicked:(id)sender;
- (IBAction)onEditQuestionSetList:(id)sender;
- (IBAction)onInfoBtnClicked:(id)sender;

@end
