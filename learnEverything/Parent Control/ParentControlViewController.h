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
    __unsafe_unretained IBOutlet UILabel *_topTitle;
    __unsafe_unretained IBOutlet UILabel *_tipLbl;
    __unsafe_unretained IBOutlet UIView *scanArea_placeholder;

    BOOL _scanImageStarted;
    __unsafe_unretained IBOutlet UIImageView *_scanImage;
    
    BOOL _allowAccess;
}

- (IBAction)onByPassClicked:(id)sender;
@end
