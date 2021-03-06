//
//  AppDelegate.h
//  sweep
//
//  Created by Thomas DeMeo on 6/11/13.
//  Copyright (c) 2013 Sweep. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <HockeySDK/HockeySDK.h>
#import "Theme.h"
#import "KeychainWrapper.h"
#import "IIViewDeckController.h"
#import "SettingsManager.h"
#import "SideMenuViewController.h"
#import "LogInViewController.h"
#import "SWSyncEngine.h"
#import "Departments.h"
#import "Events.h"
#import "Scans.h"

//@class EventValuesViewController;
@interface AppDelegate : UIResponder <UIApplicationDelegate, BITHockeyManagerDelegate, BITUpdateManagerDelegate, BITCrashManagerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) KeychainWrapper *departmentKeyItem;

//@property (strong, nonatomic) EventValuesViewController *viewController;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end
