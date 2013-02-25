//
//  AppDelegate.m
//  Sweep
//
//  Created by Thomas DeMeo on 1/30/13.
//  Copyright (c) 2013 Thomas DeMeo. All rights reserved.
//

#import "AppDelegate.h"
#import "MFSideMenu.h"
#import "ViewController.h"
#import "SideMenuViewController.h"

@implementation AppDelegate

- (ViewController *)viewController {
    return [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];
}

- (UINavigationController *)navigationController {
    return [[UINavigationController alloc]
            initWithRootViewController:[self viewController]];
}

- (void) setupNavigationControllerApp {
    self.window.rootViewController = [self sideMenu].navigationController;
    [self.window makeKeyAndVisible];
}

- (MFSideMenu *)sideMenu {
    
    SideMenuViewController *leftSideMenuController = [[SideMenuViewController alloc] initWithNibName:@"SideMenuViewController" bundle:nil];
    UINavigationController *navigationController = [self navigationController];
    
    MFSideMenu *sideMenu = [MFSideMenu menuWithNavigationController:navigationController
                                             leftSideMenuController:leftSideMenuController
                                            rightSideMenuController:nil];
    
    leftSideMenuController.sideMenu = sideMenu;
    
    return sideMenu;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
//    [ThemeManager customizeAppAppearance];
    
    [self setupNavigationControllerApp];
    
    return YES;
}

@end
