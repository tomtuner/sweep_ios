//
//  AppDelegate.m
//  Sweep
//
//  Created by Thomas DeMeo on 1/30/13.
//  Copyright (c) 2013 Thomas DeMeo. All rights reserved.
//

#import "AppDelegate.h"
//#import "MFSideMenu.h"
#import "ViewController.h"
#import "SideMenuViewController.h"

@implementation AppDelegate

- (UINavigationController *)navigationController {
    return [[UINavigationController alloc]
            initWithRootViewController:[self viewController]];
}

- (void) setupNavigationControllerApp {
    
    
    
//    UIViewController *leftController = [[UIViewController alloc] init];
    SideMenuViewController *leftSideMenuController = [[SideMenuViewController alloc] initWithNibName:@"SideMenuViewController" bundle:nil];
    SScanEvent *firstEvent = [leftSideMenuController getInitialScanEvent];
    ViewController *vc = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil scanDataArchiveString:firstEvent.uuid];
    vc.title = firstEvent.name;
    UINavigationController *centerNav = [[UINavigationController alloc] initWithRootViewController:vc];
    
    IIViewDeckController *deckController = [[IIViewDeckController alloc] initWithCenterViewController:centerNav leftViewController:leftSideMenuController];
    
    deckController.openSlideAnimationDuration = 0.2f;
    deckController.closeSlideAnimationDuration = 0.2f;
        
    self.window.rootViewController = deckController;
    [self.window makeKeyAndVisible];
}
/*
- (MFSideMenu *)sideMenu {
    
//    SideMenuViewController *leftSideMenuController = [[SideMenuViewController alloc] initWithNibName:@"SideMenuViewController" bundle:nil];
    UINavigationController *navigationController = [self navigationController];
    /*
    MFSideMenu *sideMenu = [MFSideMenu menuWithNavigationController:navigationController
                                             leftSideMenuController:leftSideMenuController
                                            rightSideMenuController:nil];
    
//    leftSideMenuController.sideMenu = sideMenu;
 
    return sideMenu;
}
*/

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    [ThemeManager customizeAppAppearance];
//    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];

    [self setupNavigationControllerApp];
    
    return YES;
}

@end
