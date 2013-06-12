//
//  AFSweepAPIClient.h
//  Sweep
//
//  Created by Thomas DeMeo on 4/21/13.
//  Copyright (c) 2013 Thomas DeMeo. All rights reserved.
//

#import "AFHTTPClient.h"
#import "AFJSONRequestOperation.h"

#define kAFSweepAPIBaseURLString @"http://api.sweepevents.com/index.php/sweep"

@interface AFSweepAPIClient : AFHTTPClient

+ (AFSweepAPIClient *)sharedClient;

@end
