#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "CryptoFramework.h"
#import "crypto_sdk.h"
#import "OpenSslCrypto.h"

FOUNDATION_EXPORT double crypto_sdkVersionNumber;
FOUNDATION_EXPORT const unsigned char crypto_sdkVersionString[];

