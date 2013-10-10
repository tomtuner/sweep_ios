//
//  SideMenuViewController.m
//  sweep
//
//  Created by Thomas DeMeo on 6/11/13.
//  Copyright (c) 2013 Sweep. All rights reserved.
//

#import "SideMenuViewController.h"

@interface SideMenuViewController ()

@property (nonatomic, strong) UITextField *activeField;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic) NSInteger indexToGoToAfterSync;
@property (nonatomic) BOOL firstTimeLoad;

@property (nonatomic, strong) IBOutlet UILabel *departmentNameLabel;


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
    self.firstTimeLoad = YES;
    
    [self customizeView];
    [ThemeManager customizeNavigationControllerTitleView:self barMetrics:UIBarMetricsDefault];
    self.indexToGoToAfterSync = 0;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        self.scansViewController = (ScansViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    }
    self.managedObjectContext = [[SWCoreDataController sharedInstance] newManagedObjectContext];
//    self.eventsTable.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"gray_texture"]];
    [self registerForKeyboardNotifications];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"SWSyncEngineSyncCompleted" object:nil queue:nil usingBlock:^(NSNotification *note) {
        [self loadRecordsFromCoreData];
////        if (self.firstTimeLoad)
////        {
        if (self.events.count != 0)
        {
            if (self.firstTimeLoad)
            {
                [self tableView:self.eventsTable didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:[SettingsManager sharedSettingsManager].indexOfLastViewedEvent inSection:0]];
                self.firstTimeLoad = NO;
            }
            else{
                [self tableView:self.eventsTable didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:self.indexToGoToAfterSync inSection:0]];
            }
    ////            self.firstTimeLoad = NO;
    ////        }
    //        [self stopActivityIndicatorView];
        }
        [self customizeView];
    }];

    // TODO: Put this somewhere else
    self.footerView.layer.masksToBounds = NO;
    self.footerView.layer.cornerRadius = 3.0f;
    self.footerView.layer.shadowOpacity = 0.8f;
    self.footerView.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    self.footerView.layer.shadowOffset = CGSizeMake(0.0f, -1.0f);
    self.footerView.layer.shadowRadius = 4.0f;

}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    /*[[NSNotificationCenter defaultCenter] addObserverForName:@"SWSyncEngineSyncCompleted" object:nil queue:nil usingBlock:^(NSNotification *note) {
        [self loadRecordsFromCoreData];
        //        if (self.firstTimeLoad)
        //        {
        [self tableView:self.eventsTable didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:self.indexToGoToAfterSync inSection:0]];
        //            self.firstTimeLoad = NO;
        //        }
    }];
     */
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"SWSyncEngineSyncCompleted" object:nil];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];

}

- (void) customizeView
{
    if (self.events.count == 0){
        self.scansViewController.detailItem = nil;
    }
    Departments *dept = [[SWSyncEngine sharedEngine] sharedDepartment];
    self.departmentNameLabel.text = dept.name;    
}

- (void)loadRecordsFromCoreData {
    [self.managedObjectContext performBlockAndWait:^{
        [self.managedObjectContext reset];
        NSError *error = nil;
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Events"];

        [request setSortDescriptors:[NSArray arrayWithObject:
                                     [NSSortDescriptor sortDescriptorWithKey:@"created_at" ascending:NO]]];
        self.events = [self.managedObjectContext executeFetchRequest:request error:&error];
//        NSLog(@"Events Array: %@", self.events);
        [self.eventsTable reloadData];
    }];
}

-(void)logOutPressed
{
    [SettingsManager sharedSettingsManager].indexOfLastViewedEvent = 0;
    [self.scansViewController resetDepartment];
    [self.scansViewController loadRecordsFromCoreData];
    [self loadRecordsFromCoreData];
    self.departmentNameLabel.text = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIActionSheet

-(IBAction)settingsGearPressed:(id)sender
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Please select from the following:"
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:@"Log Out", nil];
    
    // Show the sheet
    [sheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSLog(@"Button %d", buttonIndex);
    if (buttonIndex == 0)
    {
        [self logOutPressed];
    }
}

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
        cell.nameLabel.textColor = [UIColor lightGrayColor];

        cell.nameLabel.text = @"Add an event...";
//        cell.nameLabel.alpha = 0.8;
    }else {
        
        [self configureCell:cell atIndexPath:indexPath];
//        Events *object = [self.events objectAtIndex:indexPath.row];
//        cell.nameLabel.text = object.name;
    }
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return NO;
}

- (void) stopActivityIndicatorView
{
    [_eventRefreshNetworkIndicator stopAnimating];
    [self.overlayView setBackgroundColor:[UIColor whiteColor]];
}

- (void) showActivtyIndicatorView
{
    _eventRefreshNetworkIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [_eventRefreshNetworkIndicator setCenter:CGPointMake(self.overlayView.frame.size.width / 2.0, self.overlayView.frame.size.height / 2.0)]; // I do this because I'm in landscape mode
    [self.overlayView setBackgroundColor:[UIColor colorWithWhite:0.2 alpha:0.3]];
    [self.overlayView addSubview:_eventRefreshNetworkIndicator]; // spinner is not visible until started
    
    [_eventRefreshNetworkIndicator startAnimating];
}

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
//        SideMenuTableViewCell *cell = (SideMenuTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
//        [cell.nameLabel setHidden:YES];
//        [cell.nameTextField setHidden:NO];
//        [cell.nameTextField setSelected:YES];
        
//        cell.nameTextField.delegate = self;
//        [cell.nameTextField becomeFirstResponder];
        self.indexToGoToAfterSync = 0;

        UIStoryboard *st = [UIStoryboard storyboardWithName:[[NSBundle mainBundle].infoDictionary objectForKey:@"UIMainStoryboardFile"] bundle:[NSBundle mainBundle]];
        EventDetailViewController *edvc = [st instantiateViewControllerWithIdentifier:@"eventDetailViewController"];
        [self presentViewController:edvc animated:YES completion:nil];
 
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }else {
        Events *selectedEvent = (Events *) [self.events objectAtIndex:indexPath.row];
        if (self.scansViewController)
        {
            self.indexToGoToAfterSync = indexPath.row;
            [[SettingsManager sharedSettingsManager] setIndexOfLastViewedEvent:self.indexToGoToAfterSync];
            self.scansViewController.detailItem = selectedEvent;
            
            [self.viewDeckController closeLeftViewBouncing:^(IIViewDeckController *controller) {
                //                ((UINavigationController *)controller.centerController).viewControllers = controllers;
                // ...
            }];
        }else
        {
            NSArray *controllers = [NSArray arrayWithObject:self.scansViewController];
            [self.viewDeckController closeLeftViewBouncing:^(IIViewDeckController *controller) {
//                ((UINavigationController *)controller.centerController).viewControllers = controllers;
                // ...
            }];
        }
        
    }
}


- (void)configureCell:(SideMenuTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    [cell.nameLabel setHidden:NO];
    [cell.nameTextField setHidden:YES];
    [cell.nameTextField setSelected:NO];
    [cell.nameLabel setTextColor:[UIColor blackColor]];
    Events *object = [self.events objectAtIndex:indexPath.row];
    cell.nameLabel.text = object.name;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd"];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    NSLog(@"%@", [dateFormatter stringFromDate:object.starts_at]);
    cell.dateLabel.text = [dateFormatter stringFromDate:object.starts_at];
}

#pragma mark - UIKeyboardNotifications

// Call this method somewhere in your view controller setup code.
- (void)registerForKeyboardNotifications
{
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    /*[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];*/
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification object:nil];
 
    
}


// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGRect kbFrame = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGRect convertedFrame = [self.view convertRect:kbFrame fromView:self.view.window];

    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, convertedFrame.size.height, 0.0);
    self.eventsTable.contentInset = contentInsets;
    self.eventsTable.scrollIndicatorInsets = contentInsets;
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                CGRect rectOfCellInTableView = [self.eventsTable rectForRowAtIndexPath:[NSIndexPath indexPathForRow:self.events.count inSection:0]];
    CGRect rectOfCellInSuperview = [self.eventsTable convertRect:rectOfCellInTableView toView:[self.eventsTable superview]];

    if (!CGRectContainsPoint(rectOfCellInSuperview, [self.activeField superview].frame.origin) ) {
        [self.eventsTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.events.count inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

- (BOOL)disablesAutomaticKeyboardDismissal {
    return NO;
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.eventsTable.contentInset = contentInsets;
    self.eventsTable.scrollIndicatorInsets = contentInsets;
    
}

- (void) keyboardDidHide:(NSNotification*)aNotification
{
    [self.eventsTable reloadData];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    if (![textField.text isEqualToString:@""]) {

        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Departments"];
        [request setSortDescriptors:[NSArray arrayWithObject:
                                     [NSSortDescriptor sortDescriptorWithKey:@"remote_id" ascending:YES]]];
        
        [self.managedObjectContext performBlockAndWait:^{
            [self.managedObjectContext reset];
            
            // Get the Department for use
            NSArray *sharedDepartmentArray = nil;
            NSError *error = nil;
            
            sharedDepartmentArray = [self.managedObjectContext executeFetchRequest:request error:&error];
            Departments *sharedDepartment = [sharedDepartmentArray lastObject];
//            NSLog(@"Shared Department: %@", sharedDepartmentArray);
            
            // Create new event and add to core data
            Events *newEvent = [NSEntityDescription insertNewObjectForEntityForName:@"Events" inManagedObjectContext:self.managedObjectContext];
            newEvent.name = textField.text;
            newEvent.department_id = sharedDepartment.remote_id;
            newEvent.sync_status = [NSNumber numberWithInt:SWObjectCreated];

            BOOL saved = [self.managedObjectContext save:&error];
            if (!saved) {
                // do some real error handling
                NSLog(@"Could not save Department due to %@", error);
            }
            [[SWCoreDataController sharedInstance] saveMasterContext];

//            [self.events addObject:newEvent];
//            [self.eventsTable reloadData];
//             [self loadRecordsFromCoreData];
            self.indexToGoToAfterSync = 0;

            [[SWSyncEngine sharedEngine] startSync];
        }];
    }
//    [self loadRecordsFromCoreData];

//    [self.eventsTable reloadData];
//    [textField setHidden:YES];
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.activeField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.activeField = nil;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)orientation  duration:(NSTimeInterval)duration {
    [super willAnimateRotationToInterfaceOrientation:orientation duration:duration];
    CGRect frame = self.navigationController.navigationBar.frame;
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        frame.size.height = 44;
        [ThemeManager customizeNavigationControllerTitleView:self barMetrics:UIBarMetricsDefault];
    } else {
        if ( UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad )
        {
            frame.size.height = 32;
            [ThemeManager customizeNavigationControllerTitleView:self barMetrics:UIBarMetricsLandscapePhone];
        }
    }
    self.navigationController.navigationBar.frame = frame;
}

@end