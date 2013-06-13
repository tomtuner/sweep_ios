//
//  Event.m
//  sweep
//
//  Created by Thomas DeMeo on 6/12/13.
//  Copyright (c) 2013 Sweep. All rights reserved.
//

#import "Event.h"

@implementation Event

@dynamic name;
@dynamic department_id;

- (void) awakeFromInsert
{
    [super awakeFromInsert];
}

@end
