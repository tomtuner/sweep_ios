//
//  LogInViewController.m
//  sweep
//
//  Created by Thomas DeMeo on 6/13/13.
//  Copyright (c) 2013 Sweep. All rights reserved.
//

#import "LogInViewController.h"

@interface LogInViewController ()

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

}

-(void) viewDidAppear:(BOOL)animated
{
    NSString *departmentKey = (NSString *)[self.departmentKeyItem objectForKey:(__bridge id)(kSecValueData)];
    if (departmentKey.length)
    {
        NSLog(@"Department Key: %@", departmentKey);
        [self validateDepartmentKey:departmentKey];
    }else {
        NSLog(@"No department key set, do nothing.");
    }
}

- (void) validateDepartmentKey:(NSString *) departmentKey
{
    [self showActivtyIndicatorView];
    [Department globalDepartmentVerificationWithValidationKey:departmentKey
                                                    withBlock:^(NSDictionary *department, NSError *error) {
        if (!error)
        {
            NSLog(@"Department Returned: %@", department);
            [self.departmentKeyItem setObject:[department objectForKey:@"valid_key"] forKey:(__bridge id)(kSecValueData)];
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
