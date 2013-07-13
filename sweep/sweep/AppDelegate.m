//
//  AppDelegate.m
//  sweep
//
//  Created by Thomas DeMeo on 6/11/13.
//  Copyright (c) 2013 Sweep. All rights reserved.
//

#import "AppDelegate.h"

#import "ScansViewController.h"

@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSString *defaultsFileName = [NSString stringWithFormat:@"defaults%@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"DEFAULTS_EXT"]];
    NSLog(@"Product Name: %@", defaultsFileName);
    
    NSDictionary *defaults = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:defaultsFileName ofType:@"plist"]];
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
    
    [self setupHockeyApp];
    [self initKeychainForDepartmentKey];
    [[SWSyncEngine sharedEngine] registerNSManagedObjectClassToSync:[Events class]];
    [[SWSyncEngine sharedEngine] registerNSManagedObjectClassToSync:[Scans class]];
    
    [ThemeManager customizeAppAppearance];

    UIStoryboard *st = [UIStoryboard storyboardWithName:[[NSBundle mainBundle].infoDictionary objectForKey:@"UIMainStoryboardFile"] bundle:[NSBundle mainBundle]];
    
    // Override point for customization after application launch.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
        UINavigationController *navigationController = [splitViewController.viewControllers lastObject];
        splitViewController.delegate = (id)navigationController.topViewController;
        ScansViewController *scanController = (ScansViewController *)navigationController.topViewController;
//        scanController.managedObjectContext = self.managedObjectContext;
        scanController.departmentKeyItem = self.departmentKeyItem;

//        UINavigationController *masterNavigationController = splitViewController.viewControllers[0];
//        SideMenuViewController *sideController = (SideMenuViewController *)masterNavigationController.topViewController;
//        sideController.departmentKeyItem = self.departmentKeyItem;
//        controller.managedObjectContext = self.managedObjectContext;
        
    } else {

        UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
        ScansViewController *controller = (ScansViewController *)navigationController.topViewController;
//        controller.managedObjectContext = self.managedObjectContext;
        controller.departmentKeyItem = self.departmentKeyItem;
        
        UINavigationController *sideMenuNav = [st instantiateViewControllerWithIdentifier:@"sideMenuController"];
        SideMenuViewController *sideController = (SideMenuViewController *)sideMenuNav.topViewController;

        sideController.scansViewController = controller;
//        sideController.departmentKeyItem = self.departmentKeyItem;

//        sideController.managedObjectContext = self.managedObjectContext;
        IIViewDeckController *deckController = [[IIViewDeckController alloc] initWithCenterViewController:navigationController leftViewController:sideMenuNav];
        
        deckController.openSlideAnimationDuration = 0.2f;
        deckController.closeSlideAnimationDuration = 0.2f;
        
        self.window.rootViewController = deckController;
    }
    return YES;
}

- (void) initKeychainForDepartmentKey
{
    // Create the keychain for the department key
    KeychainWrapper *wrapper = [[KeychainWrapper alloc] initWithIdentifier:@"DepartmentKey" accessGroup:nil];
    self.departmentKeyItem = wrapper;
}

- (void) setupHockeyApp
{
    NSString *hockeyBetaID = [[SettingsManager sharedSettingsManager] hockeyAppBetaID];
    NSString *hockeyID = [[SettingsManager sharedSettingsManager] hockeyAppID];

    [[BITHockeyManager sharedHockeyManager] configureWithBetaIdentifier:hockeyBetaID
                                                         liveIdentifier:hockeyID
                                                               delegate:self];
    [[BITHockeyManager sharedHockeyManager] startManager];
}

#pragma mark - BITUpdateManagerDelegate
- (NSString *)customDeviceIdentifierForUpdateManager:(BITUpdateManager *)updateManager {
#ifndef CONFIGURATION_AppStore
    if ([[UIDevice currentDevice] respondsToSelector:@selector(uniqueIdentifier)])
        return [[UIDevice currentDevice] performSelector:@selector(uniqueIdentifier)];
#endif
    return nil;
}
				
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
//    [[SWSyncEngine sharedEngine] startSync];
}

- (void)applicationWillTerminate:(UIApplication *)application
{

}

@end
