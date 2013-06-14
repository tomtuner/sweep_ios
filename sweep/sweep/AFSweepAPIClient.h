//
//  AFSweepAPIClient.h
//  Sweep
//
//  Created by Thomas DeMeo on 4/21/13.
//  Copyright (c) 2013 Thomas DeMeo. All rights reserved.
//

#import "AFHTTPClient.h"
#import "AFJSONRequestOperation.h"

#define kAFSweepAPIBaseURLString @"http://developer.sweepevents.com/api/"

@interface AFSweepAPIClient : AFHTTPClient

+ (AFSweepAPIClient *)sharedClient;

@end
