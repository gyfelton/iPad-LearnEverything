//
//  StartViewController.h
//  learnEverything
//
//  Created by Yuanfeng on 12-06-02.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QuestionListViewController.h"

@interface StartViewController : UIViewController

- (IBAction)onSinglePlayerGameClicked:(id)sender;
- (IBAction)onTwoPlayersGameClicked:(id)sender;
- (IBAction)onEditQuestionList:(id)sender;

@end
