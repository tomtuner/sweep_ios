//
//  BarcodeCaptureViewController.h
//  Sweep
//
//  Created by Thomas DeMeo on 2/4/13.
//  Copyright (c) 2013 Thomas DeMeo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ZXingObjC/ZXingObjC.h>
#import "SBarcodeResult.h"

@class BarcodeCaptureViewController;

@protocol SScanDelegate
@required
-(void)barcodeCaptureController:(BarcodeCaptureViewController *) controller scanResults:(NSArray *) barcodeResult;

@end

@interface BarcodeCaptureViewController : UIViewController <ZXCaptureDelegate>

@property(nonatomic,assign)id delegate;
@property (nonatomic, retain) ZXCapture *capture;
@property(nonatomic, strong) NSMutableArray *barcodeResultArray;

@end
