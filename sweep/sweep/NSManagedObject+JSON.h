//
//  NSManagedObject+JSON.h
//  sweep
//
//  Created by Thomas DeMeo on 6/25/13.
//  Copyright (c) 2013 Kanzu LLC. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (JSON)

- (NSMutableDictionary *)JSONToCreateObjectOnServer;
- (NSString *)dateStringForAPIUsingDate:(NSDate *)date;

@end
