//
//  ParentControlViewController.h
//  learnEverything
//
//  Created by Yuanfeng on 12-06-25.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FakeScannerView.h"

@interface ParentControlViewController : UIViewController <FakeScannerDelegate>
{
    FakeScannerView *_fakeScannerView;
    IBOutlet UILabel *_topTitle;
    
    BOOL _allowAccess;
}

- (IBAction)onByPassClicked:(id)sender;
@end
