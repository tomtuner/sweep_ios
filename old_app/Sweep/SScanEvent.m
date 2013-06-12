//
//  SScanEvent.m
//  Sweep
//
//  Created by Thomas DeMeo on 2/9/13.
//  Copyright (c) 2013 Thomas DeMeo. All rights reserved.
//

#import "SScanEvent.h"

@implementation SScanEvent

- (id)init {
    self = [super init];
    if (self) {
        CFUUIDRef uuidObject = CFUUIDCreate(kCFAllocatorDefault);
        self.uuid = (__bridge_transfer NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuidObject);
        CFRelease(uuidObject);
        
        self.date = [NSDate date];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {

        self.name = [coder decodeObjectForKey:kScanEventName];
        self.date = [coder decodeObjectForKey:kScanEventDate];
        self.uuid = [coder decodeObjectForKey:kScanEventId];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.name forKey:kScanEventName];
    [coder encodeObject:self.date forKey:kScanEventDate];
    [coder encodeObject:self.uuid forKey:kScanEventId];
    
}


@end
