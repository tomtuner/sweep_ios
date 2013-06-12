//
//  MasterViewController.h
//  sweep
//
//  Created by Thomas DeMeo on 6/11/13.
//  Copyright (c) 2013 Sweep. All rights reserved.
//

#import <UIKit/UIKit.h>

//@class DetailViewController;

#import <CoreData/CoreData.h>
#import "IIViewDeckController.h"

@interface ScansViewController : UIViewController <NSFetchedResultsControllerDelegate, UISplitViewControllerDelegate>

@property (strong, nonatomic) id detailItem;
@property(strong, nonatomic) IBOutlet UITableView *scansTable;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end