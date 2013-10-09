//
//  Events.m
//  sweep
//
//  Created by Thomas DeMeo on 6/18/13.
//  Copyright (c) 2013 Kanzu LLC. All rights reserved.
//

#import "Events.h"
#import "Departments.h"
#import "Scans.h"


@implementation Events

@dynamic department_id;
@dynamic name;
@dynamic remote_id;
@dynamic updated_at;
@dynamic department;
@dynamic scans;
@dynamic sync_status;
@dynamic created_at;
@dynamic starts_at;
@dynamic ends_at;

- (NSMutableDictionary *)JSONToCreateObjectOnServer {
    
    NSDictionary *jsonDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                    self.name, @"name",
                                    self.department_id, @"department_id", nil];
    NSMutableDictionary *event = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                           jsonDictionary, @"event", nil];
    
                                
    return event;
}

@end
