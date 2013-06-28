//
//  MasterViewController.m
//  sweep
//
//  Created by Thomas DeMeo on 6/11/13.
//  Copyright (c) 2013 Sweep. All rights reserved.
//

#import "ScansViewController.h"


@interface ScansViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)configureView;

@end

@implementation ScansViewController
/*
- (void)awakeFromNib
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
//        self.scansTable.clearsSelectionOnViewWillAppear = NO;
        self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
    }
    [super awakeFromNib];
}
*/
- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setupMenuBarButtonItems];
    [self configureView];
    
    [self displayLoginControllerIfNeeded];

}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [[NSNotificationCenter defaultCenter] addObserverForName:@"SWSyncEngineSyncCompleted" object:nil queue:nil usingBlock:^(NSNotification *note) {
        [self loadRecordsFromCoreData];
        [self.scansTable reloadData];
    }];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"SWSyncEngineSyncCompleted" object:nil];
}

- (void)loadRecordsFromCoreData {
    [self.managedObjectContext performBlockAndWait:^{
        [self.managedObjectContext reset];
        NSError *error = nil;
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Scans"];
        [request setSortDescriptors:[NSArray arrayWithObject:
                                     [NSSortDescriptor sortDescriptorWithKey:@"created_at" ascending:YES]]];
        self.scans = [self.managedObjectContext executeFetchRequest:request error:&error];
    }];
}

- (void)setupMenuBarButtonItems {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {

        self.navigationItem.leftBarButtonItem = [self leftMenuBarButtonItem];
    }
    
    self.navigationItem.rightBarButtonItem = [self rightMenuBarButtonItem];
}

- (UIBarButtonItem *)leftMenuBarButtonItem {
    return [[UIBarButtonItem alloc]
            initWithImage:[UIImage imageNamed:@"menu_icon.png"] style:UIBarButtonItemStyleBordered
            target:self.viewDeckController
            action:@selector(toggleLeftView)];
}


- (UIBarButtonItem *)rightMenuBarButtonItem {
    return [[UIBarButtonItem alloc]
            initWithTitle:@"Scan" style:UIBarButtonItemStyleBordered
            target:self
            action:@selector(scanPressed:)];
}


- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }
    
    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }
}

- (void)configureView
{
    // Update the user interface for the detail item.
    
    if (self.detailItem) {
//        self.detailDescriptionLabel.text = [[self.detailItem valueForKey:@"scanned_at"] description];
        self.title = self.detailItem.name;
        NSLog(@"Event ID: %@", self.detailItem.remote_id);
        NSLog(@"Department ID: %@", self.detailItem.department.remote_id);
        
    }
}

#pragma mark - Login Check

-(void) displayLoginControllerIfNeeded
{
    NSString *departmentKey = (NSString *)[self.departmentKeyItem objectForKey:(__bridge id)(kSecValueData)];
    if (departmentKey.length)
    {
        // Department Key was once valid but validate again on startup
        [self validateDepartmentKey:departmentKey];
    }else {
        // No department key found
        // Perform Selector seems to be more stable when loading the view
        [self performSelector:@selector(showLoginController) withObject:nil afterDelay:0.0];
        //        [self showLoginController];
    }
}

- (void) showLoginController
{
    UIStoryboard *st = [UIStoryboard storyboardWithName:[[NSBundle mainBundle].infoDictionary objectForKey:@"UIMainStoryboardFile"] bundle:[NSBundle mainBundle]];
    LogInViewController *logInController = [st instantiateViewControllerWithIdentifier:@"logInViewController"];
    logInController.departmentKeyItem = self.departmentKeyItem;
    logInController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:logInController animated:YES completion:nil];
}

- (void) validateDepartmentKey:(NSString *) departmentKey
{
    [Departments globalDepartmentVerificationWithValidationKey:departmentKey
                                                     withBlock:^(NSDictionary *department, NSError *error) {
         if (!error)
         {
             [[SWSyncEngine sharedEngine] removeDepartmentObjects];
             // Authentication was successful store the key returned
             NSLog(@"Department Returned: %@", department);
             [self.departmentKeyItem setObject:[department objectForKey:@"valid_key"] forKey:(__bridge id)(kSecValueData)];
             
             [[SWSyncEngine sharedEngine] newManagedObjectUsingMasterContextWithClassName:@"Departments" forRecord:department];

             [self.managedObjectContext performBlockAndWait:^{
                 [self.managedObjectContext reset];
                 
                 NSError *error = nil;
                 BOOL saved = [self.managedObjectContext save:&error];
                 if (!saved) {
                     // do some real error handling
                     NSLog(@"Could not save Department due to %@", error);
                 }
                 [[SWCoreDataController sharedInstance] saveMasterContext];
             }];

             [[SWSyncEngine sharedEngine] startSync];
             
         }else {
             NSLog(@"Error Code: %i", [[[error userInfo] objectForKey:AFNetworkingOperationFailingURLResponseErrorKey] statusCode] );
             
             NSLog(@"Error: %@", [error localizedDescription]);
             // Look for an unauthorized response code
             if ([[[error userInfo] objectForKey:AFNetworkingOperationFailingURLResponseErrorKey] statusCode] == 401)
             {
                 // Key is no longer valid reset the keychain and reenter
                 [self.departmentKeyItem resetKeychainItem];
                 // Remove ALL core data objects when department key is deemed invalid
                 [[SWSyncEngine sharedEngine] removeCoreDataObjects];
                 
                 [self showLoginController];
             }
         }  
     }];
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.image = [UIImage imageNamed:@"menu_icon"];
//    [self.navigationItem setLeftBarButtonItem:[self leftMenuBarButtonItem] animated:YES];
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.scans count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}
/*
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        
        NSError *error = nil;
        if (![context save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }   
     */
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return NO;
}
/*
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        NSManagedObject *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        self.detailViewController.detailItem = object;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSManagedObject *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        [[segue destinationViewController] setDetailItem:object];
    }
}
*/
#pragma mark - Fetched results controller
/*
- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Scans" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"scanned_at" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Master"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
	     // Replace this implementation with code to handle the error appropriately.
	     // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return _fetchedResultsController;
}    
*/
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.scansTable beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.scansTable insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.scansTable deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.scansTable;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.scansTable endUpdates];
}

/*
// Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed. 
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // In the simplest, most efficient, case, reload the table view.
    [self.tableView reloadData];
}
 */

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Scans *object = [self.scans objectAtIndex:indexPath];
    cell.textLabel.text = object.value;
}

@end
