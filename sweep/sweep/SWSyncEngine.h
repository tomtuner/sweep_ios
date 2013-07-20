//
//  SweepSyncEngine.h
//  sweep
//
//  Created by Thomas DeMeo on 6/18/13.
//  Copyright (c) 2013 Kanzu LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "SWCoreDataController.h"
#import "AFSweepAPIClient.h"
#import "KeychainWrapper.h"
#import "NSManagedObject+JSON.h"
#import "Customers.h"

typedef enum {
    SWObjectSynced = 0,
    SWObjectCreated,
} SWObjectSyncStatus;

@interface SWSyncEngine : NSObject

@property (atomic, readonly) BOOL syncInProgress;

+ (SWSyncEngine *) sharedEngine;
- (void)registerNSManagedObjectClassToSync:(Class)aClass;
- (void)startSync;
- (void)newManagedObjectUsingMasterContextWithClassName:(NSString *)className forRecord:(NSDictionary *)record;
- (BOOL)removeCoreDataObjects;
- (BOOL)removeDepartmentObjects;
- (BOOL)removeCustomerObjects;


- (Customers *) sharedCustomer;
- (Departments *) sharedDepartment;

@end
