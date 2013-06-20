//
//  SweepSyncEngine.h
//  sweep
//
//  Created by Thomas DeMeo on 6/18/13.
//  Copyright (c) 2013 Kanzu LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SWCoreDataController.h"
#import "AFSweepAPIClient.h"
#import "KeychainWrapper.h"

typedef enum {
    SWObjectSynced = 0,
    SWObjectCreated,
    SWObjectDeleted,
} SWObjectSyncStatus;

@interface SWSyncEngine : NSObject

@property (atomic, readonly) BOOL syncInProgress;

+ (SWSyncEngine *) sharedEngine;
- (void)registerNSManagedObjectClassToSync:(Class)aClass;
- (void)startSync;

@end
