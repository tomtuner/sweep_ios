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
//    [self.view setNeedsDisplay];
}

- (void) validateDepartmentKey:(NSString *) departmentKey
{
    [self showActivtyIndicatorView];
    [Departments globalDepartmentVerificationWithValidationKey:departmentKey
                                                    withBlock:^(NSDictionary *departmentAndCustomer, NSError *error) {
        if (!error)
        {
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
