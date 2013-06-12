//
//  Scan.h
//  sweep
//
//  Created by Thomas DeMeo on 6/12/13.
//  Copyright (c) 2013 Sweep. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface Scan : NSManagedObject

@property (nonatomic, strong) NSString *value;
@property (nonatomic, strong) NSDate *scanned_at, *created_at;
@property (nonatomic, strong) NSNumber *event_id;

@end
