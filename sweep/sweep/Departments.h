//
//  Departments.h
//  sweep
//
//  Created by Thomas DeMeo on 6/18/13.
//  Copyright (c) 2013 Kanzu LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "AFSweepAPIClient.h"

@class Customers, Events;

@interface Departments : NSManagedObject

@property (nonatomic, retain) NSNumber * customer_id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * remote_id;
@property (nonatomic, retain) NSNumber * sync_status;
@property (nonatomic, retain) NSDate * updated_at;
@property (nonatomic, retain) NSString * valid_key;
@property (nonatomic, retain) Customers *customer;
@property (nonatomic, retain) NSSet *events;
@property (nonatomic, retain) NSDate * created_at;

@end

@interface Departments (CoreDataGeneratedAccessors)

- (void)addEventsObject:(Events *)value;
- (void)removeEventsObject:(Events *)value;
- (void)addEvents:(NSSet *)values;
- (void)removeEvents:(NSSet *)values;

+ (void)globalDepartmentVerificationWithValidationKey:(NSString *) validationKey withBlock:(void (^)(NSDictionary *department, NSError *error))block;

@end
