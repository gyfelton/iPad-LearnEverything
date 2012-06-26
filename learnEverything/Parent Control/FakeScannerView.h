//
//  FakeScannerView.h
//  fakeFingerPrintScanner
//
//  Created by Yuanfeng on 12-03-23.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FakeScannerDelegate <NSObject>

@optional
- (void)didBeginDetectFinger:(BOOL)isAdult;
- (void)didDetectFingerMoving:(BOOL)isAdult;
- (void)didEndDetectFinger;

@end

@interface FakeScannerView : UIView
@property (unsafe_unretained) id<FakeScannerDelegate> delegate;
@end
