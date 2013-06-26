//
//  SideMenuViewController.m
//  sweep
//
//  Created by Thomas DeMeo on 6/11/13.
//  Copyright (c) 2013 Sweep. All rights reserved.
//

#import "SideMenuViewController.h"

@interface SideMenuViewController ()


@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end

@implementation SideMenuViewController


 - (void)awakeFromNib
 {
     if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
         //        self.scansTable.clearsSelectionOnViewWillAppear = NO;
         self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
     }
     [super awakeFromNib];
 }
 

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
//    if ([SWSyncEngine sharedEngine] syncInProgress) {
//    }

    self.scansViewController = (ScansViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
//    self.scansViewController.managedObjectContext = self.managedObjectContext;
    self.managedObjectContext = [[SWCoreDataController sharedInstance] newManagedObjectContext];
    [[NSNotificationCenter defaultCenter] addObserverForName:@"SWSyncEngineSyncCompleted" object:nil queue:nil usingBlock:^(NSNotification *note) {
        [self loadRecordsFromCoreData];
        [self.eventsTable reloadData];
    }];
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"SWSyncEngineSyncCompleted" object:nil];
}

- (void)loadRecordsFromCoreData {
    [self.managedObjectContext performBlockAndWait:^{
        [self.managedObjectContext reset];
        NSError *error = nil;
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Events"];
        [request setSortDescriptors:[NSArray arrayWithObject:
                                     [NSSortDescriptor sortDescriptorWithKey:@"remote_id" ascending:YES]]];
        self.events = [self.managedObjectContext executeFetchRequest:request error:&error];
        NSLog(@"Events Array: %@", self.events);
    }];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


// - (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
// {
//     if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
//         Event *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
//         self.detailViewController.detailItem = object;
//     }
// }

 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
     if ([[segue identifier] isEqualToString:@"showSideMenu"]) {
         NSIndexPath *indexPath = [self.eventsTable indexPathForSelectedRow];
         Events *object = [self.events objectAtIndex:indexPath.row];
         [[segue destinationViewController] setDetailItem:object];
     }
 }

/*
- (void)insertNewObject
{
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
    Events *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
    
    // If appropriate, configure the new managed object.
    // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
//    [newManagedObject setValue:[NSDate date] forKey:@"name"];

    
    // Save the context.
    NSError *error = nil;
    if (![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}
*/
#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.eventsTable.editing ? [self.events count] : [self.events count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    NSString *CellIdentifier = @"SideMenuTableViewCell";
    BOOL addCell = (indexPath.row == self.events.count);
    
	SideMenuTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
	{
        cell = [[SideMenuTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                            reuseIdentifier:CellIdentifier];
    }
    
    if (addCell) {
        cell.nameLabel.text = @"Add an event...";
    }else {
        [self configureCell:cell atIndexPath:indexPath];
//        Events *object = [self.events objectAtIndex:indexPath.row];
//        cell.nameLabel.text = object.name;
    }
    
    return cell;
}
/*
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */
/*
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
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
}
*/
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

#pragma mark - UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    // This will create a "invisible" footer
    return 0.01f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    // This will create a "invisible" footer
    return [UIView new];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // FIXME: This should only happen in else statement, should stay selected during new event
    if (indexPath.row == self.events.count) {
        
        SideMenuTableViewCell *cell = (SideMenuTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
        [cell.nameLabel setHidden:YES];
        [cell.nameTextField setHidden:NO];
        [cell.nameTextField setSelected:YES];
        
        cell.nameTextField.delegate = self;
        [cell.nameTextField becomeFirstResponder];
        /*
        // Animate tableview frame change
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationCurveEaseOut animations:^{
            self.eventsTable.frame = CGRectMake(self.eventsTable.frame.origin.x, self.eventsTable.frame.origin.y, self.eventsTable.frame.size.width, self.eventsTable.frame.size.height - 250.0f);
        }
         completion:^(BOOL finished){
             [self.eventsTable scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
             [tableView deselectRowAtIndexPath:indexPath animated:NO];
         }];
        */
        
        
        
        /*
         SScanEvent *newEvent = [[SScanEvent alloc] init];
         NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
         [dateFormat setDateFormat:@"MMMM d ss"];
         NSString *dateString = [dateFormat stringFromDate:newEvent.date];
         newEvent.name = dateString;
         [self.scanLists addObject:newEvent];
         // Save our new scans out to the archive file
         NSString *documentsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
         NSUserDomainMask, YES) objectAtIndex:0];
         NSString *archivePath = [documentsDir stringByAppendingPathComponent:kScanListArchiveName];
         [NSKeyedArchiver archiveRootObject:self.scanLists toFile:archivePath];
         [self.scanEventListTable reloadData];
         
    }else {
       
        SScanEvent *eve = (SScanEvent *)[self.scanLists objectAtIndex:indexPath.row];
        NSLog(@"Event Name: %@", eve.name);
        NSLog(@"Event UUID: %@", eve.uuid);
        EventValuesViewController *viewController = [[EventValuesViewController alloc] initWithNibName:@"EventValuesViewController" bundle:nil scanDataArchiveString:eve.uuid];
        viewController.title = eve.name;
        
        NSArray *controllers = [NSArray arrayWithObject:viewController];
        [self.viewDeckController closeLeftViewBouncing:^(IIViewDeckController *controller) {
            ((UINavigationController *)controller.centerController).viewControllers = controllers;
            // ...
        }];
        
    }
         */
    }
}


- (void)configureCell:(SideMenuTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Events *object = [self.events objectAtIndex:indexPath.row];
    cell.nameLabel.text = object.name;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    if (![textField.text isEqualToString:@""]) {
//        SScanEvent *newEvent = [[SScanEvent alloc] init];
        //    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        //    [dateFormat setDateFormat:@"MMMM d ss"];
        //    NSString *dateString = [dateFormat stringFromDate:newEvent.date];
//        newEvent.name = textField.text;
//        [self.events addObject:newEvent];
        // Save our new scans out to the archive file
//        NSString *documentsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
//                                                                      NSUserDomainMask, YES) objectAtIndex:0];
//        NSString *archivePath = [documentsDir stringByAppendingPathComponent:kScanListArchiveName];
//        [NSKeyedArchiver archiveRootObject:self.scanLists toFile:archivePath];
//        Events *newObject = [NSEntityDescription insertNewObjectForEntityForName:@"Events" inManagedObjectContext:self.managedObjectContext];
//        NSString *departmentKey = [KeychainWrapper returnDepartmentKey];
//        newObject.
        [self.managedObjectContext performBlockAndWait:^{
            [self.managedObjectContext reset];
            NSArray *sharedDepartmentArray = nil;
            NSError *error = nil;
            NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Departments"];
            [request setSortDescriptors:[NSArray arrayWithObject:
                                         [NSSortDescriptor sortDescriptorWithKey:@"remote_id" ascending:YES]]];
            sharedDepartmentArray = [self.managedObjectContext executeFetchRequest:request error:&error];
            Departments *sharedDepartment = [sharedDepartmentArray lastObject];
            NSLog(@"Shared Department: %@", sharedDepartmentArray);
            Events *newEvent = [NSEntityDescription insertNewObjectForEntityForName:@"Events" inManagedObjectContext:self.managedObjectContext];
            newEvent.name = textField.text;
            newEvent.department_id = sharedDepartment.remote_id;
            newEvent.sync_status = [NSNumber numberWithInt:SWObjectCreated];
            
//            newEvent.
            
//            [[SWSyncEngine sharedEngine] newManagedObjectUsingMasterContextWithClassName:@"Events" forRecord:department];
            //            Departments *t = [NSEntityDescription insertNewObjectForEntityForName:@"Departments" inManagedObjectContext:self.managedObjectContext];
            //            t.valid_key = [department objectForKey:@"valid_key"];
//                Departments *sharedDepartmentArray = nil;
//                NSError *error = nil;
//                NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Departments"];
//                [request setSortDescriptors:[NSArray arrayWithObject:
//                                             [NSSortDescriptor sortDescriptorWithKey:@"remote_id" ascending:YES]]];
//                sharedDepartmentArray = [[self.managedObjectContext executeFetchRequest:request error:&error] lastObject];
                //                NSLog(@"Shared Department: %@", sharedDepartmentArray);
                //            }];
                
                //            [self.managedObjectContext performBlockAndWait:^{
                
                //                [[SWSyncEngine sharedEngine] updateManagedObject:sharedDepartmentArray withRecord:department];
                
                //                NSError *error = nil;
                BOOL saved = [self.managedObjectContext save:&error];
                if (!saved) {
                    // do some real error handling
                    NSLog(@"Could not save Department due to %@", error);
                }
                [[SWCoreDataController sharedInstance] saveMasterContext];

//            [self.eventsTable reloadData];
        }];
        [self loadRecordsFromCoreData];
        [self.eventsTable reloadData];
        [[SWSyncEngine sharedEngine] startSync];
//        NSLog(@"Events List: %@", self.events);
//        [self.eventsTable reloadData];
        
    }
    // Release the keyboard
    // FIXME: Change 250 Value
    //self.eventsTable.frame = CGRectMake(self.eventsTable.frame.origin.x, self.eventsTable.frame.origin.y, self.eventsTable.frame.size.width, self.eventsTable.frame.size.height + 250.0f);
//    [self.eventsTable reloadData];
    [textField resignFirstResponder];
    
    return YES;
}

- (void) textFieldDidBeginEditing:(UITextField *)textField {
    [self.eventsTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.events.count inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
}

@end
