//
//  Scans.m
//  sweep
//
//  Created by Thomas DeMeo on 6/18/13.
//  Copyright (c) 2013 Kanzu LLC. All rights reserved.
//

#import "Scans.h"
#import "Events.h"


@implementation Scans

@dynamic event_id;
@dynamic created_at;
@dynamic remote_id;
@dynamic scanned_at;
@dynamic updated_at;
@dynamic value;
@dynamic event;
@dynamic sync_status;

-(void) awakeFromInsert
{
    [super awakeFromNib];
    self.scanned_at = [NSDate date];

}

- (NSMutableDictionary *)JSONToCreateObjectOnServer {
    
    NSDictionary *jsonDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                    self.value, @"value",
                                    self.event_id, @"event_id",
                                    self.scanned_at, @"scanned_at", nil];
    NSLog(@"Scanned_at: %@", self.scanned_at);
    NSMutableDictionary *event = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  jsonDictionary, @"scan", nil];
    
    
    return event;
}
@end
