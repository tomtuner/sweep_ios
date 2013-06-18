//
//  Events.h
//  sweep
//
//  Created by Thomas DeMeo on 6/18/13.
//  Copyright (c) 2013 Kanzu LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Departments, Scans;

@interface Events : NSManagedObject

@property (nonatomic, retain) NSNumber * department_id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * remote_id;
@property (nonatomic, retain) NSDate * updated_at;
@property (nonatomic, retain) Departments *department;
@property (nonatomic, retain) NSSet *scans;
@end

@interface Events (CoreDataGeneratedAccessors)

- (void)addScansObject:(Scans *)value;
- (void)removeScansObject:(Scans *)value;
- (void)addScans:(NSSet *)values;
- (void)removeScans:(NSSet *)values;

@end
