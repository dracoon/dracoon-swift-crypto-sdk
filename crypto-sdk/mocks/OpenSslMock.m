//
//  OpenSslMock.m
//  crypto-sdk
//
//  Created by Mathias Schreiner on 26.07.19.
//  Copyright © 2019 Dracoon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OpenSslMock.h"

@implementation OpenSslMock

- (NSDictionary *)createUserKeyPair:(NSString *)password {
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    [result setObject:@"publicKey" forKey:@"public"];
    [result setObject:@"privateKey" forKey:@"private"];
    
    return result;
}

- (BOOL)canDecryptPrivateKey:(NSString *)privateKey withPassword:(NSString *)password {
    return YES;
}

- (nullable NSString*)createFileKey {
    return @"plainFileKey";
}

- (nullable NSString*)createInitializationVector {
    return @"iv";
}

- (nullable NSValue*)initializeEncryptionCipher:(nonnull NSString*)fileKey
                                         vector:(nonnull NSString*)vector {
    return NULL;
}

- (nullable NSData*)encryptBlock:(nonnull NSData*)fileData
                          cipher:(nonnull NSValue*)ctx
                         fileKey:(nonnull NSString*)fileKey {
    return NULL;
}

- (nullable NSString*)finalizeEncryption:(nonnull NSValue*)ctx {
    return @"tag";
}

- (nullable NSValue*)initializeDecryptionCipher:(nonnull NSString*)fileKey
                                            tag:(nonnull NSString*)tagString
                                         vector:(nonnull NSString*)vector {
    return NULL;
}

- (nullable NSData*)decryptBlock:(nonnull NSData*)fileData
                          cipher:(nonnull NSValue*)ctx {
    return NULL;
}

- (BOOL)finalizeDecryption:(nonnull NSValue*)ctx {
    return YES;
}

- (nullable NSString*)encryptFileKey:(nonnull NSString*)fileKey
                           publicKey:(nonnull NSString*)publicKey {
    return @"encryptedFileKey";
}

- (nullable NSString*)decryptFileKey:(nonnull NSString*)fileKey
                          privateKey:(nonnull NSString*)privateKey
                            password:(nonnull NSString*)password {
    return @"plainFileKey";
}



@end
