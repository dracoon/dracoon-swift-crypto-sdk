//
//  CryptoMock.swift
//  crypto-sdk
//
//  Copyright © 2019 Dracoon. All rights reserved.
//

import Foundation

class CryptoMock {
    
    static func getPlainFileKey() -> PlainFileKey {
        return PlainFileKey(key: "plainFileKey", version: "Test")
    }
    
    static func getEncryptionCipher() -> FileEncryptionCipher {
        return FileEncryptionCipher(crypto: CryptoMock.getCryptoFramework(), cipher: NSValue(), fileKey: CryptoMock.getPlainFileKey())
    }
    
    static func getDecyptionCipher() -> FileDecryptionCipher {
        return FileDecryptionCipher(crypto: CryptoMock.getCryptoFramework(), cipher: NSValue(), fileKey: CryptoMock.getPlainFileKey())
    }
    
    static func getCryptoFramework() -> CryptoFramework {
        return OpenSslMock()
    }
}

