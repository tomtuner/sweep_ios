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

-(void) awakeFromNib
{
    [super awakeFromNib];
    [self setCreated_at:[NSDate date]];

}
@end
