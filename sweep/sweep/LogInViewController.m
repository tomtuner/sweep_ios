//
//  LogInViewController.m
//  sweep
//
//  Created by Thomas DeMeo on 6/13/13.
//  Copyright (c) 2013 Sweep. All rights reserved.
//

#import "LogInViewController.h"

@interface LogInViewController ()

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end

@implementation LogInViewController

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
    self.managedObjectContext = [[SWCoreDataController sharedInstance] newManagedObjectContext];

}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    /*
    NSString *departmentKey = (NSString *)[self.departmentKeyItem objectForKey:(__bridge id)(kSecValueData)];
    if (departmentKey.length)
    {
        NSLog(@"Department Key: %@", departmentKey);
        [self validateDepartmentKey:departmentKey];
    }else {
        NSLog(@"No department key set, do nothing.");
    }
     */
}

- (void) validateDepartmentKey:(NSString *) departmentKey
{
    [self showActivtyIndicatorView];
    [Departments globalDepartmentVerificationWithValidationKey:departmentKey
                                                    withBlock:^(NSDictionary *department, NSError *error) {
        if (!error)
        {
            NSLog(@"Department Returned From Login View: %@", department);
            /*Departments *departmentObject = [NSEntityDescription insertNewObjectForEntityForName:@"Departments" inManagedObjectContext:self.managedObjectContext];
            departmentObject.valid_key = [department objectForKey:@"valid_key"];
            departmentObject.name = [department objectForKey:@"name"];
            departmentObject.customer_id = [department objectForKey:@"customer_id"];
            departmentObject.remote_id = [department objectForKey:@"id"];
            */
            [self.departmentKeyItem setObject:[department objectForKey:@"valid_key"] forKey:(__bridge id)(kSecValueData)];
            /*
            if (![self.managedObjectContext save:&error]) {
                NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
            }
            */
            [[SWSyncEngine sharedEngine] newManagedObjectUsingMasterContextWithClassName:@"Departments" forRecord:department];
//            Departments *t = [NSEntityDescription insertNewObjectForEntityForName:@"Departments" inManagedObjectContext:self.managedObjectContext];
//            t.valid_key = [department objectForKey:@"valid_key"];
            [self.managedObjectContext performBlockAndWait:^{
                [self.managedObjectContext reset];
                Departments *sharedDepartmentArray = nil;
                NSError *error = nil;
                NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Departments"];
                [request setSortDescriptors:[NSArray arrayWithObject:
                                             [NSSortDescriptor sortDescriptorWithKey:@"remote_id" ascending:YES]]];
                sharedDepartmentArray = [[self.managedObjectContext executeFetchRequest:request error:&error] lastObject];
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
            }];
            
            [[SWSyncEngine sharedEngine] startSync];

            [self dismissViewControllerAnimated:YES completion:nil];

        }else {
            NSLog(@"Error: %@", [error localizedDescription]);
        }
        [self stopActivityIndicatorView];
  
    }];
}

- (void) stopActivityIndicatorView
{
    [_validKeyNetworkIndicator stopAnimating];
}

- (void) showActivtyIndicatorView
{
    _validKeyNetworkIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [_validKeyNetworkIndicator setCenter:CGPointMake(self.view.frame.size.width / 2.0, self.view.frame.size.height / 2.0)]; // I do this because I'm in landscape mode
    [self.view addSubview:_validKeyNetworkIndicator]; // spinner is not visible until started
    
    [_validKeyNetworkIndicator startAnimating];
}


- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    [self validateDepartmentKey:[textField text]];
    
    return YES;
}

- (BOOL)disablesAutomaticKeyboardDismissal {
    
    return NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
