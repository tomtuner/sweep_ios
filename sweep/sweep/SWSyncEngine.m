//
//  SweepSyncEngine.m
//  sweep
//
//  Created by Thomas DeMeo on 6/18/13.
//  Copyright (c) 2013 Kanzu LLC. All rights reserved.
//

#import "SWSyncEngine.h"

@interface SWSyncEngine ()

@property (nonatomic, strong) NSMutableArray *registeredClassesToSync;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@end

@implementation SWSyncEngine

NSString * const kSWSyncEngineInitialCompleteKey = @"SWSyncEngineInitialSyncCompleted";
NSString * const kSWSyncEngineSyncCompletedNotificationName = @"SWSyncEngineSyncCompleted";

@synthesize registeredClassesToSync = _registeredClassesToSync;

+(SWSyncEngine *) sharedEngine
{
    static SWSyncEngine *sharedEngine = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedEngine = [[SWSyncEngine alloc] init];
    });
    
    return sharedEngine;
}

- (void)startSync {
    if (!self.syncInProgress) {
        [self willChangeValueForKey:@"syncInProgress"];
        _syncInProgress = YES;
        [self didChangeValueForKey:@"syncInProgress"];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [self downloadDataForRegisteredObjects:YES];
        });
    }
}

- (void)registerNSManagedObjectClassToSync:(Class)aClass {
    if (!self.registeredClassesToSync) {
        self.registeredClassesToSync = [NSMutableArray array];
    }
    
    if ([aClass isSubclassOfClass:[NSManagedObject class]]) {
        if (![self.registeredClassesToSync containsObject:NSStringFromClass(aClass)]) {
            [self.registeredClassesToSync addObject:NSStringFromClass(aClass)];
        } else {
            NSLog(@"Unable to register %@ as it is already registered", NSStringFromClass(aClass));
        }
    } else {
        NSLog(@"Unable to register %@ as it is not a subclass of NSManagedObject", NSStringFromClass(aClass));
    }
}

-(NSDate *)mostRecentUpdatedAtDateForEntityWithName:(NSString *)entityName {
    __block NSDate *date = nil;
    //
    // Create a new fetch request for the specified entity
    //
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:entityName];
    //
    // Set the sort descriptors on the request to sort by updatedAt in descending order
    //
    [request setSortDescriptors:[NSArray arrayWithObject:
                                 [NSSortDescriptor sortDescriptorWithKey:@"updated_at" ascending:NO]]];
    //
    // You are only interested in 1 result so limit the request to 1
    //
    NSManagedObjectContext *con = [[SWCoreDataController sharedInstance] backgroundManagedObjectContext];
    [request setFetchLimit:1];
    [con performBlockAndWait:^{
        NSError *error = nil;
        NSArray *results = [con executeFetchRequest:request error:&error];
        if ([results lastObject])   {
            //
            // Set date to the fetched result
            //
            date = [[results lastObject] valueForKey:@"updated_at"];
        }
    }];
    
    return date;
}

- (void)newManagedObjectWithClassName:(NSString *)className forRecord:(NSDictionary *)record {
    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:className inManagedObjectContext:[[SWCoreDataController sharedInstance] backgroundManagedObjectContext]];
    [record enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([key isEqualToString:@"id"]) {
            key = @"remote_id";
        }
        [self setValue:obj forKey:key forManagedObject:newManagedObject];
    }];
    // Set SYNC status for new object? Can't change immutable NSDictionary
    [self setValue:[NSNumber numberWithInt:SWObjectSynced] forKey:@"sync_status" forManagedObject:newManagedObject];
}

- (void)newManagedObjectUsingMasterContextWithClassName:(NSString *)className forRecord:(NSDictionary *)record {
    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:className inManagedObjectContext:[[SWCoreDataController sharedInstance] masterManagedObjectContext]];
    [record enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([key isEqualToString:@"id"]) {
            key = @"remote_id";
        }
        [self setValue:obj forKey:key forManagedObject:newManagedObject];
    }];
    // Set SYNC status for new object? Can't change immutable NSDictionary
    [self setValue:[NSNumber numberWithInt:SWObjectSynced] forKey:@"sync_status" forManagedObject:newManagedObject];
}

- (void)updateManagedObject:(NSManagedObject *)managedObject withRecord:(NSDictionary *)record {
    [record enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([key isEqualToString:@"id"]) {
            key = @"remote_id";
        }
        [self setValue:obj forKey:key forManagedObject:managedObject];
    }];
}

-(void) postLocalObjectsToServer
{
    NSMutableArray *operations = [NSMutableArray array];
    for (NSString *className in self.registeredClassesToSync) {
        NSArray *objectsToCreate = [self managedObjectsUsingMasterContextForClass:className withSyncStatus:SWObjectCreated];
        for (NSManagedObject *objectToCreate in objectsToCreate) {
            NSMutableDictionary *jsonString = [objectToCreate JSONToCreateObjectOnServer];
            
            NSString *departmentKey = [KeychainWrapper returnDepartmentKey];
            //        NSMutableDictionary *tempDict = [NSMutableDictionary dictionaryWithDictionary:<#(NSDictionary *)#>]
//            NSDictionary *paramDict = [NSDictionary dictionaryWithObjects:@[departmentKey]
//                                                                  forKeys:@[@"valid_key"]];
            [jsonString setObject:departmentKey forKey:@"valid_key"];
            
            NSMutableURLRequest *request = [[AFSweepAPIClient sharedClient] POSTRequestForClass:className parameters:jsonString];
            
            AFHTTPRequestOperation *operation = [[AFSweepAPIClient sharedClient] HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSLog(@"Success creation: %@", responseObject);
                NSDictionary *responseDictionary = responseObject;
                NSDate *createdDate = [self dateUsingStringFromAPI:[responseDictionary valueForKey:@"created_at"]];
//                NSDate *createdDate = [self dateUsingStringFromAPI:[responseDictionary valueForKey:@"created_at"]];
                [objectToCreate setValue:createdDate forKey:@"created_at"];
                [objectToCreate setValue:createdDate forKey:@"updated_at"];
                [objectToCreate setValue:[responseDictionary valueForKey:@"id"] forKey:@"remote_id"];
                [objectToCreate setValue:[NSNumber numberWithInt:SWObjectSynced] forKey:@"sync_status"];
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Failed creation: %@", error);
            }];
            [operations addObject:operation];
        }
    }
    
    [[AFSweepAPIClient sharedClient] enqueueBatchOfHTTPRequestOperations:operations progressBlock:^(NSUInteger numberOfCompletedOperations, NSUInteger totalNumberOfOperations) {
        NSLog(@"Completed %d of %d create operations", numberOfCompletedOperations, totalNumberOfOperations);
    } completionBlock:^(NSArray *operations) {
        if ([operations count] > 0) {
            NSLog(@"Creation of objects on server compelete, updated objects in context: %@", [[[SWCoreDataController sharedInstance] masterManagedObjectContext] updatedObjects]);
            [[SWCoreDataController sharedInstance] saveMasterContext];
            NSLog(@"SBC After call creation");
        }
        
        [self executeSyncCompletedOperations];
    }];
}

- (Customers *) sharedCustomer
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Customers"];
    [request setSortDescriptors:[NSArray arrayWithObject:
                                 [NSSortDescriptor sortDescriptorWithKey:@"remote_id" ascending:YES]]];
    NSManagedObjectContext * bgContext = [[SWCoreDataController sharedInstance] backgroundManagedObjectContext];
    __block Customers *sharedCustomer = nil;
    [bgContext performBlockAndWait:^{
        [bgContext reset];
        
        // Get the Department for use
        NSArray *sharedCustomerArray = nil;
        NSError *error = nil;
        
        sharedCustomerArray = [bgContext executeFetchRequest:request error:&error];
        sharedCustomer = [sharedCustomerArray lastObject];
//        return sharedCustomer;
    }];
    return sharedCustomer;
}

- (Departments *) sharedDepartment
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Departments"];
    [request setSortDescriptors:[NSArray arrayWithObject:
                                 [NSSortDescriptor sortDescriptorWithKey:@"remote_id" ascending:YES]]];
    NSManagedObjectContext * bgContext = [[SWCoreDataController sharedInstance] backgroundManagedObjectContext];
    __block Departments *sharedDepartment = nil;
    [bgContext performBlockAndWait:^{
        [bgContext reset];
        
        // Get the Department for use
        NSArray *sharedDepartmentArray = nil;
        NSError *error = nil;
        
        sharedDepartmentArray = [bgContext executeFetchRequest:request error:&error];
        sharedDepartment = [sharedDepartmentArray lastObject];
        //        return sharedCustomer;
    }];
    return sharedDepartment;
}

- (BOOL) removeDepartmentObjects
{
    __block BOOL end = NO;
    NSManagedObjectContext *managedObjectContext = [[SWCoreDataController sharedInstance] backgroundManagedObjectContext];

    // Delete all Departments (Should only be 1)
    [managedObjectContext performBlockAndWait:^{
        NSArray *coreDataObjectArray = nil;
        NSError *error = nil;
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Departments"];
        [request setSortDescriptors:[NSArray arrayWithObject:
                                     [NSSortDescriptor sortDescriptorWithKey:@"remote_id" ascending:YES]]];
        coreDataObjectArray = [managedObjectContext executeFetchRequest:request error:&error];
        //        NSLog(@"Shared Department: %@", coreDataObjectArray);
        for (NSManagedObject *managedObject in coreDataObjectArray)
        {
            [managedObjectContext deleteObject:managedObject];
        }
        BOOL saved = [managedObjectContext save:&error];
        if (!saved) {
            NSLog(@"Unable to save context after deleting records for class Departments because %@", error);
//            return NO;
        }
        end = YES;
    }];
    return end;
}

- (BOOL) removeCustomerObjects
{
    __block BOOL end = NO;
    NSManagedObjectContext *managedObjectContext = [[SWCoreDataController sharedInstance] backgroundManagedObjectContext];
    
    // Delete all Departments (Should only be 1)
    [managedObjectContext performBlockAndWait:^{
        NSArray *coreDataObjectArray = nil;
        NSError *error = nil;
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Customers"];
        [request setSortDescriptors:[NSArray arrayWithObject:
                                     [NSSortDescriptor sortDescriptorWithKey:@"remote_id" ascending:YES]]];
        coreDataObjectArray = [managedObjectContext executeFetchRequest:request error:&error];
        //        NSLog(@"Shared Department: %@", coreDataObjectArray);
        for (NSManagedObject *managedObject in coreDataObjectArray)
        {
            [managedObjectContext deleteObject:managedObject];
        }
        BOOL saved = [managedObjectContext save:&error];
        if (!saved) {
            NSLog(@"Unable to save context after deleting records for class Customers because %@", error);
            //            return NO;
        }
        end = YES;
    }];
    return end;
}


- (BOOL) removeCoreDataObjects
{
    NSManagedObjectContext *managedObjectContext = [[SWCoreDataController sharedInstance] backgroundManagedObjectContext];
    
    // Remove all classes tracked through SWSyncEngine
    for (NSString *className in self.registeredClassesToSync) {
        NSArray *storedRecords = [self
                                  managedObjectsForClass:className
                                  sortedByKey:@"remote_id"
                                  usingArrayOfIds:[NSArray array]
                                  inArrayOfIds:NO];
        [managedObjectContext performBlockAndWait:^{
            for (NSManagedObject *managedObject in storedRecords) {
                [managedObjectContext deleteObject:managedObject];
            }
            NSError *error = nil;
            BOOL saved = [managedObjectContext save:&error];
            if (!saved) {
                NSLog(@"Unable to save context after deleting records for class %@ because %@", className, error);
            }
        }];
    }
    
    // Delete all Departments (Should only be 1)
    
    [self removeDepartmentObjects];
    
    // Delete all Customers (Should only be 1)
    [self removeCustomerObjects];
    
    
//    [managedObjectContext performBlockAndWait:^{
//        NSArray *coreDataObjectArray = nil;
//        NSError *error = nil;
//        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Departments"];
//        [request setSortDescriptors:[NSArray arrayWithObject:
//                                     [NSSortDescriptor sortDescriptorWithKey:@"remote_id" ascending:YES]]];
//        coreDataObjectArray = [managedObjectContext executeFetchRequest:request error:&error];
////        NSLog(@"Shared Department: %@", coreDataObjectArray);
//        for (NSManagedObject *managedObject in coreDataObjectArray)
//        {
//            [managedObjectContext deleteObject:managedObject];
//        }
//        BOOL saved = [managedObjectContext save:&error];
//        if (!saved) {
//            NSLog(@"Unable to save context after deleting records for class Departments because %@", error);
//        }
//    }];
    /*
    // Delete all Scans
    [managedObjectContext performBlockAndWait:^{
        //        [managedObjectContext reset];
        NSArray *coreDataObjectArray = nil;
        NSError *error = nil;
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Scans"];
        [request setSortDescriptors:[NSArray arrayWithObject:
                                     [NSSortDescriptor sortDescriptorWithKey:@"remote_id" ascending:YES]]];
        coreDataObjectArray = [managedObjectContext executeFetchRequest:request error:&error];
//        NSLog(@"Shared Department: %@", coreDataObjectArray);
        for (NSManagedObject *managedObject in coreDataObjectArray)
        {
            [managedObjectContext deleteObject:managedObject];
        }
        BOOL saved = [managedObjectContext save:&error];
        if (!saved) {
            NSLog(@"Unable to save context after deleting records for class Departments because %@", error);
        }
    }];
     */
    [[SWCoreDataController sharedInstance] saveBackgroundContext];
    [[SWCoreDataController sharedInstance] saveMasterContext];

    return true;
}

- (void)setValue:(id)value forKey:(NSString *)key forManagedObject:(NSManagedObject *)managedObject {
    if ([key isEqualToString:@"created_at"] || [key isEqualToString:@"updated_at"] || [key isEqualToString:@"scanned_at"] || [key isEqualToString:@"starts_at"] || [key isEqualToString:@"ends_at"]) {
        NSDate *date = [self dateUsingStringFromAPI:value];
        [managedObject setValue:date forKey:key];
    } else if ([value isKindOfClass:[NSDictionary class]]) {
        if ([value objectForKey:@"__type"]) {
            NSString *dataType = [value objectForKey:@"__type"];
            if ([dataType isEqualToString:@"Date"]) {
                NSString *dateString = [value objectForKey:@"iso"];
                NSDate *date = [self dateUsingStringFromAPI:dateString];
                [managedObject setValue:date forKey:key];
            } else {
                NSLog(@"Unknown Data Type Received");
                [managedObject setValue:nil forKey:key];
            }
        }
    } else if ([key isEqualToString:@"encrypted_key"] || [key isEqualToString:@"encrypted_iv"]) {
        // Don't store these two
    }
    else {
        [managedObject setValue:value forKey:key];
    }
}

- (NSArray *)managedObjectsForClass:(NSString *)className withSyncStatus:(SWObjectSyncStatus)syncStatus {
    __block NSArray *results = nil;
    NSManagedObjectContext *managedObjectContext = [[SWCoreDataController sharedInstance] backgroundManagedObjectContext];
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:className];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"sync_status = %d", syncStatus];
    [fetchRequest setPredicate:predicate];
    [managedObjectContext performBlockAndWait:^{
        NSError *error = nil;
        results = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    }];
    
    return results;
}

- (NSArray *)managedObjectsUsingMasterContextForClass:(NSString *)className withSyncStatus:(SWObjectSyncStatus)syncStatus {
    __block NSArray *results = nil;
    NSManagedObjectContext *managedObjectContext = [[SWCoreDataController sharedInstance] masterManagedObjectContext];
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:className];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"sync_status = %d", syncStatus];
    [fetchRequest setPredicate:predicate];
    [managedObjectContext performBlockAndWait:^{
        NSError *error = nil;
        results = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    }];
    
    return results;
}

- (NSArray *)managedObjectsForClass:(NSString *)className sortedByKey:(NSString *)key usingArrayOfIds:(NSArray *)idArray inArrayOfIds:(BOOL)inIds {
    __block NSArray *results = nil;
    NSManagedObjectContext *managedObjectContext = [[SWCoreDataController sharedInstance] backgroundManagedObjectContext];
//    [NSManagedObjectContext mergeChan]
    [managedObjectContext performBlockAndWait:^{
        [managedObjectContext reset];
        
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:className];
        NSPredicate *predicate;
        if (inIds) {
            predicate = [NSPredicate predicateWithFormat:@"remote_id IN %@", idArray];
        } else {
            predicate = [NSPredicate predicateWithFormat:@"NOT (remote_id IN %@)", idArray];
        }
        
        [fetchRequest setPredicate:predicate];
        [fetchRequest setSortDescriptors:[NSArray arrayWithObject:
                                          [NSSortDescriptor sortDescriptorWithKey:@"remote_id" ascending:YES]]];
        NSError *error = nil;
        results = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
        NSLog(@"Error: %@", error);
        NSLog(@"Results: %@", results);
    }];
    
    return results;
}

- (BOOL)initialSyncComplete {
    return [[[NSUserDefaults standardUserDefaults] valueForKey:kSWSyncEngineInitialCompleteKey] boolValue];
}

- (void)setInitialSyncCompleted {
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:YES] forKey:kSWSyncEngineInitialCompleteKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)executeSyncCompletedOperations {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setInitialSyncCompleted];
        [[NSNotificationCenter defaultCenter]
         postNotificationName:kSWSyncEngineSyncCompletedNotificationName
         object:nil];
        [self willChangeValueForKey:@"syncInProgress"];
        _syncInProgress = NO;
        [self didChangeValueForKey:@"syncInProgress"];
    });
}

- (void)downloadDataForRegisteredObjects:(BOOL)useUpdatedAtDate {
    NSMutableArray *operations = [NSMutableArray array];
    
    for (NSString *className in self.registeredClassesToSync) {
        NSDate *mostRecentUpdatedDate = nil;
        if (useUpdatedAtDate) {
            mostRecentUpdatedDate = [self mostRecentUpdatedAtDateForEntityWithName:className];
        }
        
        // Add Customer ID to request
//        KeychainWrapper *wrapper = [[KeychainWrapper alloc] initWithIdentifier:@"DepartmentKey" accessGroup:nil];
//        NSString *departmentKey = (NSString *)[wrapper objectForKey:(__bridge id)(kSecValueData)];
        NSString *departmentKey = [KeychainWrapper returnDepartmentKey];

        NSDictionary *paramDict = [NSDictionary dictionaryWithObjects:@[departmentKey]
                                                              forKeys:@[@"valid_key"]];
        
        NSMutableURLRequest *request = [[AFSweepAPIClient sharedClient]
                                        GETRequestForAllRecordsOfClass:className withParameters:paramDict
                                        updatedAfterDate:mostRecentUpdatedDate];
        AFHTTPRequestOperation *operation = [[AFSweepAPIClient sharedClient] HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                NSLog(@"Response for %@: %@", className, responseObject);
                // 1
                // Need to write response object to disk
                [self processIntoCoreDataForClassName: className WithArray:[NSArray arrayWithObject:responseObject]];
                
            }else if ([responseObject isKindOfClass:[NSArray class]]) {
                NSLog(@"Response for %@: %@", className, responseObject);
                // 1
                // Need to write responmse object to disk
                [self processIntoCoreDataForClassName: className WithArray:responseObject];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Request for class %@ failed with error: %@", className, error);
        }];
        
        [operations addObject:operation];
    }
    
    [[AFSweepAPIClient sharedClient] enqueueBatchOfHTTPRequestOperations:operations progressBlock:^(NSUInteger numberOfCompletedOperations, NSUInteger totalNumberOfOperations) {
        
    } completionBlock:^(NSArray *operations) {
        NSLog(@"All operations completed");
        
        [self postLocalObjectsToServer];
    }];
}

// ADD ANOTHER METHOD FOR ARRAYS - Remove this one
/*
-(void) processIntoCoreDataWithDictionary:(NSDictionary *) data
{
     NSManagedObjectContext *managedObjectContext = [[SWCoreDataController sharedInstance] backgroundManagedObjectContext];
    //
    // Iterate over all registered classes to sync
    //
    for (NSString *className in self.registeredClassesToSync) {
        if (![self initialSyncComplete]) { // import all downloaded data to Core Data for initial sync
            //
            // If this is the initial sync then the logic is pretty simple, you will fetch the JSON data from disk
            // for the class of the current iteration and create new NSManagedObjects for each record
            //

            [self newManagedObjectWithClassName:className forRecord:data];
       
        }else {
            //
            // Otherwise you need to do some more logic to determine if the record is new or has been updated.
            // First get the downloaded records from the JSON response, verify there is at least one object in
            // the data, and then fetch all records stored in Core Data whose objectId matches those from the JSON response.
            //
            NSArray *storedRecords = [self managedObjectsForClass:className sortedByKey:@"remote_id" usingArrayOfIds:[[NSArray arrayWithObject:[data objectForKey:@"id"]] valueForKey:@"id"] inArrayOfIds:YES];

            NSManagedObject *storedManagedObject = nil;
            if ([storedRecords count] > 0) {
                storedManagedObject = [storedRecords objectAtIndex:0];
            }
            if ([[storedManagedObject valueForKey:@"remote_id"] isEqualToString:[data valueForKey:@"id"]]) {
                //
                // Do a quick spot check to validate the objectIds in fact do match, if they do update the stored
                // object with the values received from the remote service
                //
                [self updateManagedObject:[storedRecords objectAtIndex:0] withRecord:data];
            }else {
                [self newManagedObjectWithClassName:className forRecord:data];
            }

            // Persist Store
            [managedObjectContext performBlockAndWait:^{
                NSError *error = nil;
                if (![managedObjectContext save:&error]) {
                    NSLog(@"Unable to save context for class %@", className);
                }
            }];

            [[SWCoreDataController sharedInstance] saveMasterContext];
        }
    }
}
*/
- (void)processIntoCoreDataForClassName:(NSString *) className WithArray: (NSArray *) data {
    
    NSManagedObjectContext *managedObjectContext = [[SWCoreDataController sharedInstance] backgroundManagedObjectContext];
    //
    // Iterate over all registered classes to sync
    //
//    for (NSString *className in self.registeredClassesToSync) {
        if (![self initialSyncComplete]) { // import all downloaded data to Core Data for initial sync
            //
            // If this is the initial sync then the logic is pretty simple, you will fetch the JSON data from disk
            // for the class of the current iteration and create new NSManagedObjects for each record
            //

            for (NSDictionary *record in data) {
                [self newManagedObjectUsingMasterContextWithClassName:className forRecord:record];
            }
        } else {
            //
            // Otherwise you need to do some more logic to determine if the record is new or has been updated.
            // First get the downloaded records from the JSON response, verify there is at least one object in
            // the data, and then fetch all records stored in Core Data whose objectId matches those from the JSON response.
            //
            if ([data lastObject]) {
                //
                // Now you have a set of objects from the remote service and all of the matching objects
                // (based on objectId) from your Core Data store. Iterate over all of the downloaded records
                // from the remote service.
                //
                NSArray *storedRecords = [self managedObjectsForClass:className sortedByKey:@"remote_id" usingArrayOfIds:[data valueForKey:@"id"] inArrayOfIds:YES];
                int currentIndex = 0;
                //
                // If the number of records in your Core Data store is less than the currentIndex, you know that
                // you have a potential match between the downloaded records and stored records because you sorted
                // both lists by objectId, this means that an update has come in from the remote service
                //
                for (NSDictionary *record in data) {
                    NSManagedObject *storedManagedObject = nil;
                    
                    // Make sure we don't access an index that is out of bounds as we are iterating over both collections together
                    if ([storedRecords count] > currentIndex) {
                        storedManagedObject = [storedRecords objectAtIndex:currentIndex];
                    }

                    if ([[storedManagedObject valueForKey:@"remote_id"] intValue] == [[record valueForKey:@"id"] intValue]) {
                        //
                        // Do a quick spot check to validate the objectIds in fact do match, if they do update the stored
                        // object with the values received from the remote service
                        //
                        [self updateManagedObject:[storedRecords objectAtIndex:currentIndex] withRecord:record];
                    } else if (!storedManagedObject) {
                        //
                        // Otherwise you have a new object coming in from your remote service so create a new
                        // NSManagedObject to represent this remote object locally
                        //
                        [self newManagedObjectWithClassName:className forRecord:record];
                    }
                    currentIndex++;
                }
            }
//        }
        
        
        
        // Persist Store
        [managedObjectContext performBlockAndWait:^{
            NSError *error = nil;
            if (![managedObjectContext save:&error]) {
                NSLog(@"Unable to save context for class %@", className);
            }
        }];
        
        [[SWCoreDataController sharedInstance] saveMasterContext];
    }
}

- (void)initializeDateFormatter {
    if (!self.dateFormatter) {
        self.dateFormatter = [[NSDateFormatter alloc] init];
        [self.dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssz"];
        [self.dateFormatter setLocale:[[NSLocale alloc]initWithLocaleIdentifier:@"en_US_POSIX"]];
    }
}

- (NSDate *)dateUsingStringFromAPI:(NSString *)dateString {
    [self initializeDateFormatter];
    // NSDateFormatter does not like ISO 8601 so strip the milliseconds and timezone
//    dateString = [dateString substringWithRange:NSMakeRange(0, [dateString length])];
    
    return [self.dateFormatter dateFromString:dateString];
}

- (NSString *)dateStringForAPIUsingDate:(NSDate *)date {
    [self initializeDateFormatter];
    NSString *dateString = [self.dateFormatter stringFromDate:date];
    // remove Z
//    dateString = [dateString substringWithRange:NSMakeRange(0, [dateString length]-1)];
    // add milliseconds and put Z back on
//    dateString = [dateString stringByAppendingFormat:@".000Z"];
    
    return dateString;
}

#pragma mark - File Management

- (NSURL *)applicationCacheDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject];
}
/*
- (NSURL *)JSONDataRecordsDirectory{
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *url = [NSURL URLWithString:@"JSONRecords/" relativeToURL:[self applicationCacheDirectory]];
    NSError *error = nil;
    if (![fileManager fileExistsAtPath:[url path]]) {
        [fileManager createDirectoryAtPath:[url path] withIntermediateDirectories:YES attributes:nil error:&error];
    }
    
    return url;
}

- (void)writeJSONResponse:(id)response toDiskForClassWithName:(NSString *)className {
    NSURL *fileURL = [NSURL URLWithString:className relativeToURL:[self JSONDataRecordsDirectory]];
    if (![(NSDictionary *)response writeToFile:[fileURL path] atomically:YES]) {
        NSLog(@"Error saving response to disk, will attempt to remove NSNull values and try again.");
        // remove NSNulls and try again...
        NSArray *records = [response objectForKey:@"results"];
        NSMutableArray *nullFreeRecords = [NSMutableArray array];
        for (NSDictionary *record in records) {
            NSMutableDictionary *nullFreeRecord = [NSMutableDictionary dictionaryWithDictionary:record];
            [record enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                if ([obj isKindOfClass:[NSNull class]]) {
                    [nullFreeRecord setValue:nil forKey:key];
                }
            }];
            [nullFreeRecords addObject:nullFreeRecord];
        }
        
        NSDictionary *nullFreeDictionary = [NSDictionary dictionaryWithObject:nullFreeRecords forKey:@"results"];
        
        if (![nullFreeDictionary writeToFile:[fileURL path] atomically:YES]) {
            NSLog(@"Failed all attempts to save response to disk: %@", response);
        }
    }
}
 */

@end
