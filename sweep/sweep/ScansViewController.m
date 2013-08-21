//
//  MasterViewController.m
//  sweep
//
//  Created by Thomas DeMeo on 6/11/13.
//  Copyright (c) 2013 Sweep. All rights reserved.
//

#import "ScansViewController.h"

static NSUInteger kNumberOfPages = 2;


@interface ScansViewController ()

@property (nonatomic, strong) UIPopoverController *masterPopoverController;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) IBOutlet UILabel *totalScansLabel;
@property (nonatomic, strong) IBOutlet UILabel *uniqueScansLabel;

@property (nonatomic, strong) IBOutlet UIView *headerView;

@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UIPageControl *pageControl;

@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *totalScansIndicator;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *uniqueScansIndicator;

@property (nonatomic, strong) UIActivityIndicatorView *scrollView1ActivityIndicator;
@property (nonatomic, strong) UIActivityIndicatorView *scrollView2ActivityIndicator;

@property (nonatomic, strong) UIImageView *arrow1;
@property (nonatomic, strong) UIImageView *arrow2;
@property (nonatomic, strong) UIImageView *arrow3;
@property (nonatomic, strong) UIImageView *arrow4;

@property (nonatomic) BOOL shouldAnimateActivity;

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
    CGRect frame = self.scansTable.bounds;
    frame.origin.y = -frame.size.height;
    UIView* grayView = [[UIView alloc] initWithFrame:frame];
    grayView.backgroundColor = [UIColor grayColor];
    UIView *topview = [[UIView alloc] initWithFrame:CGRectMake(0,-480,self.view.frame.size.width,480)];
    topview.backgroundColor = [UIColor blackColor];
    
    [self.scansTable addSubview:topview];
    
    self.managedObjectContext = [[SWCoreDataController sharedInstance] newManagedObjectContext];

    [self setupMenuBarButtonItems];
    [self configureView];
    
    [self displayLoginControllerIfNeeded];
    [[NSNotificationCenter defaultCenter] addObserverForName:@"SWSyncEngineSyncCompleted" object:nil queue:nil usingBlock:^(NSNotification *note) {
        [self loadRecordsFromCoreData];
    }];
    
    [self showActivtyIndicatorView];
    
    self.headerView.layer.masksToBounds = NO;
    self.headerView.layer.cornerRadius = 3.0f;
    self.headerView.layer.shadowOpacity = 0.8f;
    self.headerView.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    self.headerView.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
    self.headerView.layer.shadowRadius = 4.0f;
    
    NSTimer *timer1 = [NSTimer timerWithTimeInterval:6.0
                                              target:self
                                            selector:@selector(animateOddArrows)
                                            userInfo:nil
                                             repeats:YES];
    
    [[NSRunLoop currentRunLoop] addTimer:timer1 forMode:NSDefaultRunLoopMode];
    [timer1 fire];
    NSTimer *timer2 = [NSTimer timerWithTimeInterval:6.0
                                              target:self
                                            selector:@selector(animateEvenArrows)
                                            userInfo:nil
                                             repeats:YES];
    
    [[NSRunLoop currentRunLoop] addTimer:timer2 forMode:NSDefaultRunLoopMode];
    [timer2 fire];
    _shouldAnimateActivity = YES;
}

- (void) viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    if (_shouldAnimateActivity)
    {
        [self sizeImagesAndContentSize];

        self.scrollView1ActivityIndicator.hidden = NO;
        self.scrollView2ActivityIndicator.hidden = NO;

        [self.scrollView1ActivityIndicator startAnimating];
        [self.scrollView2ActivityIndicator startAnimating];
        _shouldAnimateActivity = NO;
    }
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if ( UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad )
    {
        [self sizeImagesAndContentSize];
//        self.scrollView1ActivityIndicator.hidden = YES;
//        self.scrollView2ActivityIndicator.hidden = YES;
        self.totalScansLabel.text = [NSString stringWithFormat:@"%i", self.scans.count];
        NSSet *uniqueStates = [NSSet setWithArray:[self.scans valueForKey:@"value"]];
        //        NSLog(@"Unique Entries: %i", uniqueStates.count);
        self.uniqueScansLabel.text = [NSString stringWithFormat:@"%i", uniqueStates.count];

    }
}

- (void) sizeImagesAndContentSize
{
    if ( UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad )
    {
        [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        
        NSString *aggregateText = @"99999";
        UIFont *font = [UIFont boldSystemFontOfSize:20.0f];
        CGSize aggregatelabelSize = [aggregateText sizeWithFont:font];

        for (int i = 0; i < kNumberOfPages; i++) {
            //We'll create an imageView object in every 'page' of our scrollView.
            CGRect frame;
            frame.origin.x = self.scrollView.frame.size.width * i;
            frame.origin.y = 0;
            frame.size = self.scrollView.frame.size;
            
            UIView *view = [[UIView alloc] initWithFrame:frame];
            
            NSString *text;
            
            if (i == 0)
            {
                text = [NSString stringWithFormat:@"Total Attendees:"];
                self.scrollView1ActivityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2 - self.scrollView1ActivityIndicator.frame.size.width + 75, self.scrollView.frame.size.height / 2, self.scrollView1ActivityIndicator.frame.size.width, self.scrollView1ActivityIndicator.frame.size.height)];
                self.scrollView1ActivityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
                [self.scrollView1ActivityIndicator setHidesWhenStopped:YES];
                [view addSubview:self.scrollView1ActivityIndicator];
                _arrow1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow_right"]];
                _arrow1.frame = CGRectMake(self.scrollView.frame.size.width - (_arrow1.frame.size.width * 2) - 10, (self.scrollView.frame.size.height / 2) - (_arrow1.frame.size.height / 2), _arrow1.frame.size.width, _arrow1.frame.size.height);
                _arrow2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow_right"]];
                _arrow2.frame = CGRectMake(_arrow1.frame.origin.x + 10, (self.scrollView.frame.size.height / 2) - (_arrow2.frame.size.height / 2), _arrow2.frame.size.width, _arrow2.frame.size.height);
                
                _totalScansLabel = [[UILabel alloc] initWithFrame:CGRectMake(_scrollView1ActivityIndicator.frame.origin.x - 10, _scrollView1ActivityIndicator.frame.origin.y - aggregatelabelSize.height / 2, aggregatelabelSize.width, aggregatelabelSize.height)];
                _totalScansLabel.backgroundColor = [UIColor clearColor];

//                _totalScansLabel.hidden = YES;
                [view addSubview:_totalScansLabel];
                [view addSubview:_arrow1];
                [view addSubview:_arrow2];
                
            } else if (i == 1) {
                text = [NSString stringWithFormat:@"Unique Attendees:"];
                self.scrollView2ActivityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2 - self.scrollView2ActivityIndicator.frame.size.width + 75, self.scrollView.frame.size.height / 2, self.scrollView2ActivityIndicator.frame.size.width, self.scrollView2ActivityIndicator.frame.size.height)];
                self.scrollView2ActivityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
                [self.scrollView2ActivityIndicator setHidesWhenStopped:YES];
                [view addSubview:self.scrollView2ActivityIndicator];
                _arrow3 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow_left"]];
                _arrow3.frame = CGRectMake(self.scrollView.frame.origin.x + 10, (self.scrollView.frame.size.height / 2) - (_arrow3.frame.size.height / 2), _arrow1.frame.size.width, _arrow3.frame.size.height);
                _arrow4 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow_left"]];
                _arrow4.frame = CGRectMake(_arrow3.frame.origin.x + 10, (self.scrollView.frame.size.height / 2) - (_arrow4.frame.size.height / 2), _arrow4.frame.size.width, _arrow4.frame.size.height);
                _uniqueScansLabel = [[UILabel alloc] initWithFrame:CGRectMake(_scrollView2ActivityIndicator.frame.origin.x - 10, _scrollView2ActivityIndicator.frame.origin.y - aggregatelabelSize.height / 2, aggregatelabelSize.width, aggregatelabelSize.height)];
                _uniqueScansLabel.backgroundColor = [UIColor clearColor];
                
//                _uniqueScansLabel.hidden = YES;
                [view addSubview:_uniqueScansLabel];
                [view addSubview:_arrow3];
                [view addSubview:_arrow4];
            }
            
            CGSize labelSize = [text sizeWithFont:font];
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2 - labelSize.width + 60, 10, labelSize.width, labelSize.height)];
            label.font = font;
            label.text = text;
            
            [view addSubview:label];
            [self.scrollView addSubview:view];
        }
        self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * kNumberOfPages, self.scrollView.frame.size.height);
    }else {
        self.scrollView.hidden = YES;
    }
}

-(void) animateOddArrows{
    [UIView animateWithDuration:2.0 animations:^{
        _arrow1.alpha = 0.0;
//        _arrow2.alpha = 0.0;
        _arrow3.alpha = 0.0;
//        _arrow4.alpha = 0.0;
    }];
    [UIView animateWithDuration:2.0 animations:^{
        _arrow1.alpha = 1.0;
//        _arrow2.alpha = 1.0;
        _arrow3.alpha = 1.0;
//        _arrow4.alpha = 1.0;
    }];
}

- (void) animateEvenArrows
{
    [UIView animateWithDuration:3.0 animations:^{
//        _arrow1.alpha = 0.0;
        _arrow2.alpha = 0.0;
//        _arrow3.alpha = 0.0;
        _arrow4.alpha = 0.0;
    }];
    [UIView animateWithDuration:3.0 animations:^{
//        _arrow1.alpha = 1.0;
        _arrow2.alpha = 1.0;
//        _arrow3.alpha = 1.0;
        _arrow4.alpha = 1.0;
    }];
}

- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    // Update the page when more than 50% of the previous/next page is visible
    CGFloat pageWidth = self.scrollView.frame.size.width;
    int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pageControl.currentPage = page;
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
//    [self.view setNeedsDisplay];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"SWSyncEngineSyncCompleted" object:nil];
}

- (void) dealloc
{
    //    [super dealloc];
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
        self.totalScansLabel.text = [NSString stringWithFormat:@"%i", self.scans.count];
        NSSet *uniqueStates = [NSSet setWithArray:[self.scans valueForKey:@"value"]];
//        NSLog(@"Unique Entries: %i", uniqueStates.count);
        self.uniqueScansLabel.text = [NSString stringWithFormat:@"%i", uniqueStates.count];

        [self.scansTable reloadData];
        [self stopActivityIndicatorView];
    }];
}

- (void) stopActivityIndicatorView
{
    [_totalScansIndicator stopAnimating];
    [_uniqueScansIndicator stopAnimating];
    [_scrollView1ActivityIndicator stopAnimating];
    [_scrollView2ActivityIndicator stopAnimating];
}

- (void) showActivtyIndicatorView
{
    [_totalScansIndicator setHidesWhenStopped:YES];
    [_uniqueScansIndicator setHidesWhenStopped:YES];
    
    [_uniqueScansIndicator startAnimating];
    [_totalScansIndicator startAnimating];
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
//    cameraCapture.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:cameraCapture animated:NO completion:nil];
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
    [self stopActivityIndicatorView];
    UIStoryboard *st = [UIStoryboard storyboardWithName:[[NSBundle mainBundle].infoDictionary objectForKey:@"UIMainStoryboardFile"] bundle:[NSBundle mainBundle]];
    LogInViewController *logInController = [st instantiateViewControllerWithIdentifier:@"logInViewController"];
    logInController.departmentKeyItem = self.departmentKeyItem;
    logInController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:logInController animated:YES completion:nil];
}

- (void) validateDepartmentKey:(NSString *) departmentKey
{
    [Departments globalDepartmentVerificationWithValidationKey:departmentKey
                                                     withBlock:^(NSDictionary *departmentAndCustomer, NSError *error) {
         if (!error)
         {
             [[SWSyncEngine sharedEngine] removeDepartmentObjects];
             [[SWSyncEngine sharedEngine] removeCustomerObjects];
            
             NSLog(@"Department Returned: %@", [departmentAndCustomer valueForKey:@"department"]);
             NSLog(@"Customer Returned: %@", [departmentAndCustomer valueForKey:@"customer"]);
             
             [self.departmentKeyItem setObject:[[departmentAndCustomer valueForKey:@"department"] objectForKey:@"valid_key"] forKey:(__bridge id)(kSecValueData)];
             
             [[SWSyncEngine sharedEngine] newManagedObjectUsingMasterContextWithClassName:@"Departments" forRecord: [departmentAndCustomer valueForKey: @"department"]];
             [[SWSyncEngine sharedEngine] newManagedObjectUsingMasterContextWithClassName:@"Customers" forRecord:[departmentAndCustomer valueForKey:@"customer"]];
             
             [self.managedObjectContext performBlockAndWait:^{
                 [self.managedObjectContext reset];
                 
                 NSError *error = nil;
                 BOOL saved = [self.managedObjectContext save:&error];
                 if (!saved) {
                     // do some real error handling
                     NSLog(@"Could not save Department due to %@", error);
                 }
                 [[SWCoreDataController sharedInstance] saveMasterContext];
                 [ThemeManager customizeAppAppearance];
                 [self.view setNeedsDisplay];
             }];
             
             [[SWSyncEngine sharedEngine] startSync];
             
         }else {
             NSLog(@"Error Code: %i", [[[error userInfo] objectForKey:AFNetworkingOperationFailingURLResponseErrorKey] statusCode] );
             
             NSLog(@"Error: %@", [error localizedDescription]);
             // Look for an unauthorized response code
             if ([[[error userInfo] objectForKey:AFNetworkingOperationFailingURLResponseErrorKey] statusCode] == 401)
             {
                 [self resetDepartment];
             }else {
                 [[SWSyncEngine sharedEngine] startSync];
             }
         }
     }];
}

- (void) resetDepartment
{
    // Key is no longer valid reset the keychain and reenter
    [self.departmentKeyItem resetKeychainItem];
    
    // Remove ALL core data objects when department key is deemed invalid
    [[SWSyncEngine sharedEngine] removeCoreDataObjects];
    [ThemeManager customizeAppAppearance];
    
    [self showLoginController];
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
    NSInteger num = (scan.value.length * [[[ThemeManager sharedTheme] percentageIDAvailable] integerValue]) / 100;
    
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
