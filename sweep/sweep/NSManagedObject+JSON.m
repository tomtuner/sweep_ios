//
//  NSManagedObject+JSON.m
//  sweep
//
//  Created by Thomas DeMeo on 6/25/13.
//  Copyright (c) 2013 Kanzu LLC. All rights reserved.
//

#import "NSManagedObject+JSON.h"

@implementation NSManagedObject (JSON)

- (NSMutableDictionary *)JSONToCreateObjectOnServer {
    @throw [NSException exceptionWithName:@"JSONStringToCreateObjectOnServer Not Overridden" reason:@"Must override JSONStringToCreateObjectOnServer on NSManagedObject class" userInfo:nil];
    return nil;
}

- (NSMutableDictionary *)JSONToUpdateObjectOnServer {
    @throw [NSException exceptionWithName:@"JSONStringToUpdateObjectOnServer Not Overridden" reason:@"Must override JSONStringToUpdateObjectOnServer on NSManagedObject class" userInfo:nil];
    return nil;
}

@end
