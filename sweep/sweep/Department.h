//
//  Department.h
//  sweep
//
//  Created by Thomas DeMeo on 6/13/13.
//  Copyright (c) 2013 Sweep. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "AFSweepAPIClient.h"

@interface Department : NSManagedObject

@property (nonatomic, strong) NSString *customer_id;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *valid_key;

+ (void)globalDepartmentVerificationWithValidationKey:(NSString *) validationKey withBlock:(void (^)(NSDictionary *department, NSError *error))block;

@end
