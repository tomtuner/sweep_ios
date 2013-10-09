//
//  Departments.m
//  sweep
//
//  Created by Thomas DeMeo on 6/18/13.
//  Copyright (c) 2013 Kanzu LLC. All rights reserved.
//

#import "Departments.h"
#import "Customers.h"
#import "Events.h"


@implementation Departments

@dynamic customer_id;
@dynamic name;
@dynamic remote_id;
@dynamic updated_at;
@dynamic valid_key;
@dynamic customer;
@dynamic events;
@dynamic sync_status;
@dynamic created_at;

+ (void)globalDepartmentVerificationWithValidationKey:(NSString *) validationKey withBlock:(void (^)(NSDictionary *departmentAndCustomer, NSError *error))block
{
    
    NSDictionary *paramDict = [NSDictionary dictionaryWithObjects:@[validationKey]
                                                          forKeys:@[@"valid_key"]];
    
    AFSweepAPIClient *networkingClient = [AFSweepAPIClient sharedClient];
    [networkingClient getPath:[NSString stringWithFormat:@"%@department_validation", networkingClient.baseURL]
                    parameters:paramDict
                       success:^(AFHTTPRequestOperation *operation, id responseObject) {
                           NSLog(@"Success");
                           NSLog(@"Response: %@", responseObject);
                           NSDictionary *departmentFromResponse = responseObject;
                           
                           if (block) {
                               block([NSDictionary dictionaryWithDictionary:departmentFromResponse], nil);
                           }
                       }
                       failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                           NSLog(@"Fail");
                           NSLog(@"%@", [error localizedDescription]);
                           if (block) {
                               block([NSDictionary dictionary], error);
                           }
                       }];
}

@end
