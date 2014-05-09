//
//  MasterViewController.h
//  sweep
//
//  Created by Thomas DeMeo on 6/11/13.
//  Copyright (c) 2013 Sweep. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <QuartzCore/QuartzCore.h>
#import "SWSyncEngine.h"
#import "IIViewDeckController.h"
#import "LogInViewController.h"
#import "Scans.h"
#import "Events.h"
#import "SettingsManager.h"
#import "CameraCaptureViewController.h"
#import "KeypadViewController.h"
#import "uniMag.h"
#import "Theme.h"
#import "Users.h"

#define REFRESH_HEADER_HEIGHT 52.0f

@interface ScansViewController : UIViewController <NSFetchedResultsControllerDelegate, UISplitViewControllerDelegate, UIScrollViewDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) Events *detailItem;
@property (nonatomic, strong) IBOutlet UITableView *scansTable;
@property (nonatomic, strong) NSArray *scans;
@property (nonatomic, strong) NSArray *users;

@property (nonatomic, strong) KeychainWrapper *departmentKeyItem;

- (void) resetDepartment;
- (void) loadRecordsFromCoreData;
@end