//
//  EventDetailViewController.m
//  sweep
//
//  Created by Thomas DeMeo on 10/10/13.
//  Copyright (c) 2013 Kanzu LLC. All rights reserved.
//

#import "EventDetailViewController.h"

@interface EventDetailViewController ()

@property (nonatomic, strong) IBOutlet UIBarButtonItem *doneButton;
@property (nonatomic, strong) IBOutlet UITextField *nameTextField;
@property (nonatomic, strong) IBOutlet UIDatePicker *startsAtDatePicker;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end

@implementation EventDetailViewController

- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar
{
    return UIBarPositionTopAttached;
}

-(NSUInteger) supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        return UIInterfaceOrientationMaskAll;
    }else
    {
        return UIInterfaceOrientationMaskPortrait;
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self setDoneButtonStatus];
    
     self.managedObjectContext = [[SWCoreDataController sharedInstance] newManagedObjectContext];
}

-(IBAction) donePressed
{
    if (self.nameTextField.text.length != 0) {
        
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
            newEvent.name = _nameTextField.text;
            newEvent.department_id = sharedDepartment.remote_id;
            newEvent.starts_at = _startsAtDatePicker.date;
            newEvent.ends_at = _startsAtDatePicker.date;
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
//            self.indexToGoToAfterSync = 0;
            
//            [[SWSyncEngine sharedEngine] startSync];
        }];

        // Add check to see if anything should be entered
        [self dismissViewControllerAnimated:YES completion:^{
            [[SWSyncEngine sharedEngine] startSync];
        }];
    }
}

-(IBAction) cancelPressed
{
    // Add check to see if anything should be entered
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) setDoneButtonStatus
{
    if (self.nameTextField.text.length != 0) {
        _doneButton.enabled = YES;
    }else {
        _doneButton.enabled = NO;
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self setDoneButtonStatus];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
