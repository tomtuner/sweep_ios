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
    [self setDefaultHeader:@"Authorization" value:@"Token token=d2f3dc51d72c3b303a9ed640a98550ae"];
    [self setDefaultHeader:@"format" value:@"json"];
    
    return self;
}

- (NSMutableURLRequest *)GETRequestForClass:(NSString *)className parameters:(NSDictionary *)parameters {
    NSMutableURLRequest *request = nil;
    request = [self requestWithMethod:@"GET" path:[NSString stringWithFormat:@"%@", [className lowercaseString]] parameters:parameters];
    return request;
}

- (NSMutableURLRequest *)GETRequestForAllRecordsOfClass:(NSString *)className withParameters:(NSDictionary *)passedParameters updatedAfterDate:(NSDate *)updatedDate {
    NSMutableURLRequest *request = nil;
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:passedParameters];
    if (updatedDate) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
        
       /* NSString *jsonString = [NSString
                                stringWithFormat:@"{\"updatedAt\":{\"$gte\":{\"__type\":\"Date\",\"iso\":\"%@\"}}}",
                                [dateFormatter stringFromDate:updatedDate]];
        */
        [parameters setObject:[dateFormatter stringFromDate:updatedDate] forKey:@"updated_at"];
    }    
    parameters = [NSDictionary dictionaryWithDictionary:parameters];
    request = [self GETRequestForClass:className parameters:parameters];
    return request;
}

- (NSMutableURLRequest *)POSTRequestForClass:(NSString *)className parameters:(NSDictionary *)parameters {
    NSMutableURLRequest *request = nil;
    request = [self requestWithMethod:@"POST" path:[NSString stringWithFormat:@"%@", [className lowercaseString]] parameters:parameters];
    return request;
}

@end
