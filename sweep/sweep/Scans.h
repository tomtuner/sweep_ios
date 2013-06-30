//
//  Scans.h
//  sweep
//
//  Created by Thomas DeMeo on 6/18/13.
//  Copyright (c) 2013 Kanzu LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "NSManagedObject+JSON.h"

@class Events;

@interface Scans : NSManagedObject

@property (nonatomic, retain) NSNumber * event_id;
@property (nonatomic, retain) NSDate * created_at;
@property (nonatomic, retain) NSNumber * remote_id;
@property (nonatomic, retain) NSNumber * sync_status;
@property (nonatomic, retain) NSDate * scanned_at;
@property (nonatomic, retain) NSDate * updated_at;
@property (nonatomic, retain) NSString * value;
@property (nonatomic, retain) Events *event;

@end
