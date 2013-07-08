//
//  EncryptionTransformer.h
//  sweep
//
//  Created by Thomas DeMeo on 7/8/13.
//  Copyright (c) 2013 Kanzu LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSData+Encryption.h"

@interface EncryptionTransformer : NSValueTransformer


-(NSString *) key;

@end
