//
//  Users.h
//  sweep
//
//  Created by Thomas DeMeo on 5/6/14.
//  Copyright (c) 2014 Kanzu LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Users : NSManagedObject

@property (nonatomic, retain) NSDate * created_at;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSDate * updated_at;
@property (nonatomic, retain) NSNumber * customer_id;
@property (nonatomic, retain) NSNumber * administrator;
@property (nonatomic, retain) NSString * first_name;
@property (nonatomic, retain) NSString * last_name;
@property (nonatomic, retain) NSString * barcode_url;
@property (nonatomic, retain) NSString * u_id;
@property (nonatomic, retain) NSNumber * sex;
@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSString * state;
@property (nonatomic, retain) NSNumber * zip;
@property (nonatomic, retain) NSString * plan;

@end
