//
//  AppDelegate.m
//  Sweep
//
//  Created by Thomas DeMeo on 1/30/13.
//  Copyright (c) 2013 Thomas DeMeo. All rights reserved.
//

#import "AppDelegate.h"

#import "ViewController.h"
#import "SideMenuViewController.h"
#import "MFSideMenu.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    [self setupNavigationControllerApp];
    
    return YES;
}

- (void) setupNavigationControllerApp {
    self.window.rootViewController = [self sideMenu].navigationController;
    [self.window makeKeyAndVisible];
}

- (MFSideMenu *)sideMenu {
    SideMenuViewController *sideMenuController = [[SideMenuViewController alloc] init];
    UINavigationController *navigationController = [self navigationController];
    
    MFSideMenuOptions options = MFSideMenuOptionMenuButtonEnabled|MFSideMenuOptionBackButtonEnabled
    |MFSideMenuOptionShadowEnabled;
    MFSideMenuPanMode panMode = MFSideMenuPanModeNavigationBar|MFSideMenuPanModeNavigationController;
    
    MFSideMenu *sideMenu = [MFSideMenu menuWithNavigationController:navigationController
                                                 sideMenuController:sideMenuController
                                                           location:MFSideMenuLocationLeft
                                                            options:options
                                                            panMode:panMode];
    
    sideMenuController.sideMenu = sideMenu;
    
    return sideMenu;
}

- (ViewController *)viewController {
    return [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];
}

- (UINavigationController *)navigationController {
    return [[UINavigationController alloc]
            initWithRootViewController:[self viewController]];
}

@end
