//
//  Event.h
//  sweep
//
//  Created by Thomas DeMeo on 6/12/13.
//  Copyright (c) 2013 Sweep. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface Event : NSManagedObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *department_id;

@end
