//
//  Customers.h
//  sweep
//
//  Created by Thomas DeMeo on 6/18/13.
//  Copyright (c) 2013 Kanzu LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Departments;

@interface Customers : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * remote_id;
@property (nonatomic, retain) NSDate * updated_at;
@property (nonatomic, retain) NSSet *departments;
@property (nonatomic, retain) NSNumber * sync_status;
@property (nonatomic, retain) NSDate *created_at;

@end

@interface Customers (CoreDataGeneratedAccessors)

- (void)addDepartmentsObject:(Departments *)value;
- (void)removeDepartmentsObject:(Departments *)value;
- (void)addDepartments:(NSSet *)values;
- (void)removeDepartments:(NSSet *)values;

@end
