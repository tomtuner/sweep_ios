//
//  AppDelegate.m
//  Sweep
//
//  Created by Thomas DeMeo on 1/30/13.
//  Copyright (c) 2013 Thomas DeMeo. All rights reserved.
//

#import "AppDelegate.h"
//#import "MFSideMenu.h"
#import "EventValuesViewController.h"
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
    EventValuesViewController *vc;
    if (firstEvent != nil)
    {
        vc = [[EventValuesViewController alloc] initWithNibName:@"EventValuesViewController" bundle:nil scanDataArchiveString:firstEvent.uuid];
        vc.title = firstEvent.name;
    }else {
        vc = [[EventValuesViewController alloc] initWithNibName:@"EventValuesViewController" bundle:nil scanDataArchiveString:nil];
    }
//    controller.managedObjectContext = self.managedObjectContext;
    UINavigationController *centerNav = [[UINavigationController alloc] initWithRootViewController:vc];
    
    IIViewDeckController *deckController = [[IIViewDeckController alloc] initWithCenterViewController:centerNav leftViewController:leftSideMenuController];
    
    deckController.openSlideAnimationDuration = 0.2f;
    deckController.closeSlideAnimationDuration = 0.2f;
        
    self.window.rootViewController = deckController;
    [self.window makeKeyAndVisible];
}


- (NSManagedObjectContext *)managedObjectContext
{
    if (self.managedObjectContext != nil)
    {
        return self.managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        self.managedObjectContext = [[NSManagedObjectContext alloc] init];
        [self.managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return self.managedObjectContext;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (self.persistentStoreCoordinator != nil)
    {
        return self.persistentStoreCoordinator;
    }
    
    //TODO might need to change this for each app target
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Sweep.sqlite"];
    
    NSError *error = nil;
    self.persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![self.persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        //Don't use abort() in a production environment. It is better to use an UIAlertView
        //and ask users to quick app using the home button.
        abort();
    }
    
    return self.persistentStoreCoordinator;
}

- (NSManagedObjectModel *)managedObjectModel
{
    if (self.managedObjectModel != nil)
    {
        return self.managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"SweepObjectModel" withExtension:@"momd"];
    self.managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return self.managedObjectModel;
}

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (void)saveContext{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
    
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    NSString *productName = [NSString stringWithFormat:@"defaults_%@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"]];
    NSLog(@"Product Name: %@", productName);
    
    NSDictionary *defaults = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:productName ofType:@"plist"]];
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
    
    [ThemeManager customizeAppAppearance];
//    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];

    [self setupNavigationControllerApp];
    
    return YES;
}

@end
