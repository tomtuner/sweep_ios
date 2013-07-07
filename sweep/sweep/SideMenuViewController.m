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
//    self.firstTimeLoad = YES;
    self.indexToGoToAfterSync = 0;
    self.scansViewController = (ScansViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    self.managedObjectContext = [[SWCoreDataController sharedInstance] newManagedObjectContext];
    [self registerForKeyboardNotifications];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"SWSyncEngineSyncCompleted" object:nil queue:nil usingBlock:^(NSNotification *note) {
        [self loadRecordsFromCoreData];
//        if (self.firstTimeLoad)
//        {
            [self tableView:self.eventsTable didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:self.indexToGoToAfterSync inSection:0]];
//            self.firstTimeLoad = NO;
//        }
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
//        NSLog(@"Events Array: %@", self.events);
        [self.eventsTable reloadData];
    }];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        cell.nameLabel.text = @"Add an event...";
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
 
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }else {
        Events *selectedEvent = (Events *) [self.events objectAtIndex:indexPath.row];
        if (self.scansViewController)
        {
            self.indexToGoToAfterSync = indexPath.row;
            self.scansViewController.detailItem = selectedEvent;
        }else
        {
            NSArray *controllers = [NSArray arrayWithObject:self.scansViewController];
            [self.viewDeckController closeLeftViewBouncing:^(IIViewDeckController *controller) {
                ((UINavigationController *)controller.centerController).viewControllers = controllers;
                // ...
            }];
        }
        
    }
}


- (void)configureCell:(SideMenuTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Events *object = [self.events objectAtIndex:indexPath.row];
    cell.nameLabel.text = object.name;
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
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your application might not need or want this behavior.
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbFrame.size.height;
    if (!CGRectContainsPoint(aRect, self.activeField.frame.origin) ) {
        [self.eventsTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.events.count inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
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
  /*  if (self.addTextFieldWasEmpty)
    {
        [self.eventsTable reloadData];

    }else {
//        [self loadRecordsFromCoreData];
    }
    [self.eventsTable reloadData]; */
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
//            [self loadRecordsFromCoreData];
//            [self.eventsTable reloadData];
            
            [[SWSyncEngine sharedEngine] startSync];
        }];
    }
//    [self loadRecordsFromCoreData];

//    [self.eventsTable reloadData];
//    [textField setHidden:YES];
    [textField resignFirstResponder];
    return YES;
}
/*
- (void) textFieldDidBeginEditing:(UITextField *)textField {
    [self.eventsTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.events.count inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
}
*/
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.activeField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.activeField = nil;
}

@end
