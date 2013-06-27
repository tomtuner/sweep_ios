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
#import "Scans.h"
#import "Events.h"

@interface ScansViewController : UIViewController <NSFetchedResultsControllerDelegate, UISplitViewControllerDelegate>

@property (strong, nonatomic) Events *detailItem;
@property(strong, nonatomic) IBOutlet UITableView *scansTable;
@property (nonatomic, strong) NSArray *scans;

@property (nonatomic, strong) KeychainWrapper *departmentKeyItem;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end