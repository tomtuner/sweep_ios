//
//  CameraCaptureViewController.h
//  sweep
//
//  Created by Thomas DeMeo on 6/30/13.
//  Copyright (c) 2013 Kanzu LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ZXingObjC/ZXingObjC.h>
#import "Scans.h"
#import "Events.h"
#import "SWCoreDataController.h"

@class CameraCaptureViewController;

@protocol SWScanDelegate
@required
-(void)cameraCaptureController:(CameraCaptureViewController *) controller;
@end

@interface CameraCaptureViewController : UIViewController <ZXCaptureDelegate>

@property(nonatomic,assign)id delegate;
@property(nonatomic,strong) Events *event;
@property (nonatomic, strong) IBOutlet UIView *scannerView;


@end
