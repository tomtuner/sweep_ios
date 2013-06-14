//
//  MasterViewController.h
//  sweep
//
//  Created by Thomas DeMeo on 6/11/13.
//  Copyright (c) 2013 Sweep. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "IIViewDeckController.h"
#import "LogInViewController.h"
#import "Scan.h"

@interface ScansViewController : UIViewController <NSFetchedResultsControllerDelegate, UISplitViewControllerDelegate>

@property (strong, nonatomic) id detailItem;
@property(strong, nonatomic) IBOutlet UITableView *scansTable;
@property (nonatomic, strong) KeychainWrapper *departmentKeyItem;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end