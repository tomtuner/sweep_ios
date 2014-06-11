//
//  KeypadViewController.h
//  sweep
//
//  Created by Thomas DeMeo on 9/25/13.
//  Copyright (c) 2013 Kanzu LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioServices.h>
#import "Theme.h"
#import "SWCoreDataController.h"
#import "Scans.h"
#import "Events.h"
#import "Flurry.h"

@interface KeypadViewController : UIViewController

@property(nonatomic, strong) IBOutlet UINavigationBar *navBar;
@property(nonatomic, strong) IBOutlet UILabel *idLabel;

@property(nonatomic,strong) Events *event;
@property(nonatomic,strong) NSArray *users;
@property(nonatomic,strong) NSArray *scans;

@end
