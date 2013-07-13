//
//  LogInViewController.h
//  sweep
//
//  Created by Thomas DeMeo on 6/13/13.
//  Copyright (c) 2013 Sweep. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KeychainWrapper.h"
#import "Departments.h"
#import "SWSyncEngine.h"
#import "Theme.h"

@interface LogInViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic, strong) KeychainWrapper *departmentKeyItem;
@property (nonatomic, strong) UIActivityIndicatorView *validKeyNetworkIndicator;

@property (nonatomic, strong) IBOutlet UINavigationBar *navBar;

//@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
//@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
