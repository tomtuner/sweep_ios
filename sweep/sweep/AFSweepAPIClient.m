//
//  AFSweepAPIClient.m
//  Sweep
//
//  Created by Thomas DeMeo on 4/21/13.
//  Copyright (c) 2013 Thomas DeMeo. All rights reserved.
//

#import "AFSweepAPIClient.h"

@implementation AFSweepAPIClient

+ (AFSweepAPIClient *)sharedClient {
    static AFSweepAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[AFSweepAPIClient alloc] initWithBaseURL:[NSURL URLWithString:kAFSweepAPIBaseURLString]];
    });
    
    return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    
    // Accept HTTP Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.1
	[self setDefaultHeader:@"Accept" value:@"application/json"];
    [self setDefaultHeader:@"Authorization" value:@"Token token=af1b377b288d17e47170fa6887cf8c3a"];
    [self setDefaultHeader:@"format" value:@"json"];
    
    return self;
}

@end
