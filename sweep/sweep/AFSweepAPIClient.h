//
//  AFSweepAPIClient.h
//  Sweep
//
//  Created by Thomas DeMeo on 4/21/13.
//  Copyright (c) 2013 Thomas DeMeo. All rights reserved.
//

#import "AFHTTPClient.h"
#import "AFJSONRequestOperation.h"

#ifdef DEBUG
    #define kAFSweepAPIBaseURLString @"https://developer.sweepevents.com/api/"
#else
    #define kAFSweepAPIBaseURLString @"https://api.sweepevents.com/api/"
#endif

@interface AFSweepAPIClient : AFHTTPClient

+ (AFSweepAPIClient *)sharedClient;
- (NSMutableURLRequest *)GETRequestForClass:(NSString *)className parameters:(NSDictionary *)parameters;
- (NSMutableURLRequest *)GETRequestForAllRecordsOfClass:(NSString *)className withParameters:(NSDictionary *) passedParameters updatedAfterDate:(NSDate *)updatedDate;


- (NSMutableURLRequest *)POSTRequestForClass:(NSString *)className parameters:(NSDictionary *)parameters;

@end
