//
//  SBarcodeResult.m
//  Sweep
//
//  Created by Thomas DeMeo on 2/4/13.
//  Copyright (c) 2013 Thomas DeMeo. All rights reserved.
//

#import "SBarcodeResult.h"

@interface SBarcodeResult()

@end

@implementation SBarcodeResult

+ (void)globalBarcodeScanWithSBarcodeResult:(SBarcodeResult *) barcodeResult withBlock:(void (^)(NSArray *barcodes, NSError *error))block {
    
    NSDictionary *paramDict = [NSDictionary dictionaryWithObjects:@[barcodeResult.text]
                                                          forKeys:@[@"scan_code"]];
    
    AFSweepAPIClient *networkingClient = [AFSweepAPIClient sharedClient];
    [networkingClient postPath:[NSString stringWithFormat:@"%@/scan/", kAFSweepAPIBaseURLString]
                    parameters:paramDict
                       success:^(AFHTTPRequestOperation *operation, id responseObject) {
                           NSLog(@"Success");
                           NSLog(@"Response: %@", responseObject);
                           NSArray *lotsFromResponse = responseObject;
                           
                           if (block) {
                               block([NSArray arrayWithArray:lotsFromResponse], nil);
                           }
                       }
                       failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                           NSLog(@"Fail");
                           NSLog(@"%@", [error localizedDescription]);
                           if (block) {
                               block([NSArray array], error);
                           }
                       }];
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        // init here
//        NSUInteger decodedLength = 0;
        self.text = [coder decodeObjectForKey:kBarcodeText];
//        self.rawBytes = [coder decodeObjectForKey:kBarcodeRawBytes];
        self.length = [coder decodeIntForKey:kBarcodeLength];
//        self.resultPoints = [coder decodeObjectForKey:kBarcodeResultPoints];
        self.barcodeFormat = [coder decodeObjectForKey:kBarcodeFormat];
        self.resultMetadata = [coder decodeObjectForKey:kBarcodeMetaData];
        self.timestamp = [coder decodeIntForKey:kBarcodeTimestamp];

    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.text forKey:kBarcodeText];
//    [coder encodeObject:self.rawBytes forKey:kBarcodeRawBytes];
    [coder encodeInt:self.length forKey:kBarcodeLength];
//    [coder encodeObject:self.resultPoints forKey:kBarcodeResultPoints];
    [coder encodeObject:[NSNumber numberWithInt:self.barcodeFormat] forKey:kBarcodeFormat];
    [coder encodeObject:self.resultMetadata forKey:kBarcodeMetaData];
    [coder encodeInt:self.timestamp forKey:kBarcodeTimestamp];

}

@end
