//
//  Department.m
//  sweep
//
//  Created by Thomas DeMeo on 6/13/13.
//  Copyright (c) 2013 Sweep. All rights reserved.
//

#import "Department.h"

@implementation Department

@dynamic name;
@dynamic customer_id;
@dynamic valid_key;

- (void) awakeFromInsert
{
    [super awakeFromInsert];
}

+ (void)globalDepartmentVerificationWithValidationKey:(NSString *) validationKey withBlock:(void (^)(NSDictionary *department, NSError *error))block
{

    NSDictionary *paramDict = [NSDictionary dictionaryWithObjects:@[validationKey]
                                                          forKeys:@[@"valid_key"]];

    AFSweepAPIClient *networkingClient = [AFSweepAPIClient sharedClient];
    [networkingClient postPath:[NSString stringWithFormat:@"%@/department_validation", networkingClient.baseURL]
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
