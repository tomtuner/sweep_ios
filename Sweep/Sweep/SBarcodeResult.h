//
//  SBarcodeResult.h
//  Sweep
//
//  Created by Thomas DeMeo on 2/4/13.
//  Copyright (c) 2013 Thomas DeMeo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ZXingObjC/ZXingObjC.h>

#define kBarcodeText @"BarcodeText"
#define kBarcodeRawBytes @"BarcodeRawBytes"
#define kBarcodeLength @"BarcodeLength"
#define kBarcodeResultPoints @"BarcodeResultPoints"
#define kBarcodeFormat @"BarcodeFormat"
#define kBarcodeMetaData @"BarcodeMetaData"
#define kBarcodeTimestamp @"BarcodeTimestamp"

@interface SBarcodeResult : NSObject <NSCoding>

@property (nonatomic, copy)   NSString * text;
//@property (nonatomic, assign) NSString * rawBytes;
@property (nonatomic, assign) int length;
@property (nonatomic, retain) NSMutableArray * resultPoints;
@property (nonatomic, assign) ZXBarcodeFormat barcodeFormat;
@property (nonatomic, retain) NSMutableDictionary *resultMetadata;
@property (nonatomic, assign) long timestamp;

@end
