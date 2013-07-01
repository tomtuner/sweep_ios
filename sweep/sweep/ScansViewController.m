//
//  MasterViewController.m
//  sweep
//
//  Created by Thomas DeMeo on 6/11/13.
//  Copyright (c) 2013 Sweep. All rights reserved.
//

#import "ScansViewController.h"


@interface ScansViewController ()

@property (nonatomic, strong) UIPopoverController *masterPopoverController;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

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

    self.managedObjectContext = [[SWCoreDataController sharedInstance] newManagedObjectContext];

    [self setupMenuBarButtonItems];
    [self configureView];
    
    [self displayLoginControllerIfNeeded];
    [[NSNotificationCenter defaultCenter] addObserverForName:@"SWSyncEngineSyncCompleted" object:nil queue:nil usingBlock:^(NSNotification *note) {
        [self loadRecordsFromCoreData];
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
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Scans"];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"event_id = %@", self.detailItem.remote_id];
        NSLog(@"Event_ID: %@", self.detailItem.remote_id);
        [request setPredicate:predicate];
        [request setSortDescriptors:[NSArray arrayWithObject:
                                     [NSSortDescriptor sortDescriptorWithKey:@"created_at" ascending:YES]]];
        self.scans = [self.managedObjectContext executeFetchRequest:request error:&error];
        [self.scansTable reloadData];
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

- (IBAction)scanPressed:(id)sender {
	UIStoryboard *st = [UIStoryboard storyboardWithName:[[NSBundle mainBundle].infoDictionary objectForKey:@"UIMainStoryboardFile"] bundle:[NSBundle mainBundle]];
    CameraCaptureViewController *cameraCapture = [st instantiateViewControllerWithIdentifier:@"cameraCaptureViewController"];
    cameraCapture.delegate = self;
    cameraCapture.event = self.detailItem;
    cameraCapture.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:cameraCapture animated:YES completion:nil];
    /*BarcodeCaptureViewController *vc = [[BarcodeCaptureViewController alloc] initWithNibName:@"BarcodeCaptureViewController" bundle:nil];
    vc.delegate = self;
    [self presentViewController:vc animated:NO completion:nil];*/
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
        self.title = self.detailItem.name;
        [self loadRecordsFromCoreData];
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

#pragma mark - SScanDelegate

- (void) cameraCaptureController:(CameraCaptureViewController *)controller
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];

    [self dismissViewControllerAnimated:NO completion:^(void) {
        /*if (barcodeResult && [barcodeResult count])
        {
            NSMutableDictionary *scanSession = [[NSMutableDictionary alloc] init];
            [scanSession setObject:[NSDate date] forKey:@"Session End Time"];
            [scanSession setObject:barcodeResult forKey:@"Scanned Items"];
            NSLog(@"Keys: %@ Values: %@", [scanSession allKeys], [scanSession allValues]);
            
            for( NSObject *bar in barcodeResult ) {
                [scanHistory insertObject:bar atIndex:0];
            }
            
            //            [scanHistory insertObject:scanSession atIndex:0];
            
            // Save our new scans out to the archive file
            NSString *documentsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                          NSUserDomainMask, YES) objectAtIndex:0];
            NSString *archivePath = [documentsDir stringByAppendingPathComponent:self.scanDataArchiveString];
            [NSKeyedArchiver archiveRootObject:scanHistory toFile:archivePath];
            
            [self.scanHistoryTable reloadData];
         
        }*/
        [[SWSyncEngine sharedEngine] startSync];
    }];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [self.scans count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ScanValuesTableViewCell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

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

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.scansTable endUpdates];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    // FIXME: Do this whole block more efficiently
    Scans *scan = [self.scans objectAtIndex:indexPath.row];
    NSString *valueString;
    NSInteger num = (scan.value.length * [[[SettingsManager sharedSettingsManager] percent_visible] integerValue]) / 100;
    valueString = [scan.value substringFromIndex:(scan.value.length - num) ];
    NSMutableString *padString = [NSMutableString string];
    for (int i = 0; i < (scan.value.length - num); i++)
    {
        [padString appendString:@"*"];
    }
    valueString = [NSString stringWithFormat:@"%@%@", padString, valueString];
    cell.textLabel.text = valueString;
}

@end
