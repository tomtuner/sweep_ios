//
//  SideMenuViewController.h
//  sweep
//
//  Created by Thomas DeMeo on 6/11/13.
//  Copyright (c) 2013 Sweep. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "Event.h"
#import "ScansViewController.h"
#import "IIViewDeckController.h"
#import "SideMenuTableViewCell.h"

@interface SideMenuViewController : UIViewController <NSFetchedResultsControllerDelegate, UITextFieldDelegate>

@property (strong, nonatomic) ScansViewController *scansViewController;

@property(nonatomic, strong) IBOutlet UITableView *eventsTable;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
