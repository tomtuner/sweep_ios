//
//  Scan.m
//  sweep
//
//  Created by Thomas DeMeo on 6/12/13.
//  Copyright (c) 2013 Sweep. All rights reserved.
//

#import "Scan.h"

@implementation Scan

@dynamic scanned_at;
@dynamic value;
@dynamic event_id;
@dynamic created_at;

- (void) awakeFromInsert
{
    [super awakeFromInsert];
    [self setCreated_at:[NSDate date]];
}

@end
