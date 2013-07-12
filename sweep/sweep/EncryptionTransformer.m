//
//  EncryptionTransformer.m
//  sweep
//
//  Created by Thomas DeMeo on 7/8/13.
//  Copyright (c) 2013 Kanzu LLC. All rights reserved.
//

#import "EncryptionTransformer.h"

@implementation EncryptionTransformer

+(Class) transformedValueClass
{
    return [NSData class];
}

+ (BOOL) allowsReverseTransformation
{
    return YES;
}

-(NSString *) key
{
    return @"SweepEvents9";
}

-(id) transformedValue:(NSData *) data
{
    if (nil == [self key])
    {
        return data;
    }
    
    if (nil == data)
    {
        return nil;
    }
    
    
    
    // Use another NSData category method (left as an exercise
    // to the reader) to randomly generate the IV data
    NSData *iv = [NSData randomDataOfLength:32];
    
    data = [data AES256EncryptWithKey:[self key] Iv:iv];
    
    NSMutableData* mutableData = [NSMutableData dataWithData:iv];
    [mutableData appendData:data];
    return mutableData;
}

- (id)reverseTransformedValue:(NSData*)data
{
    // If there's no key (e.g. during a data migration), don't try to transform the data
    if (nil == [self key])
    {
        return data;
    }
    
    if (nil == data)
    {
        return nil;
    }
    
    // The IV was stored in the first 32 bytes of the data
    NSData* iv = [data subdataWithRange:NSMakeRange(0, 32)];
    
    // Remove the IV from the encrypted data and decrypt it
    NSMutableData* mutableData = [NSMutableData dataWithData:data];
    [mutableData replaceBytesInRange:NSMakeRange(0, 32) withBytes:NULL length:0];
    
    return [mutableData AES256DecryptWithKey:[self key] Iv:iv];
}
@end
