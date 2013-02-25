//
//  SScanEvent.h
//  Sweep
//
//  Created by Thomas DeMeo on 2/9/13.
//  Copyright (c) 2013 Thomas DeMeo. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kScanEventName @"SScanEventName"
#define kScanEventDate @"SScanEventDate"
#define kScanEventId @"SScanEventId"

@interface SScanEvent : NSObject <NSCoding>

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSString *uuid;

@end
