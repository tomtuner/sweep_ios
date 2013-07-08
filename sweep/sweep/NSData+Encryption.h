//
//  NSData+Encryption.h
//  sweep
//
//  Created by Thomas DeMeo on 7/8/13.
//  Copyright (c) 2013 Kanzu LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCrypto.h>

@interface NSData (Encryption)

- (NSData *)AES256EncryptWithKey:(NSString *)key Iv:(NSData * )iv;
- (NSData *)AES256DecryptWithKey:(NSString *)key Iv:(NSData *) iv;
+ (NSData *)randomDataOfLength:(size_t)length;

@end
