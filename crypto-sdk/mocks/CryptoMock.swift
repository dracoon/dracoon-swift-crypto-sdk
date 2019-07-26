//
//  CryptoMock.swift
//  crypto-sdk
//
//  Copyright © 2019 Dracoon. All rights reserved.
//

import Foundation

public class CryptoMock {
    
    static func getPlainFileKey() -> PlainFileKey {
        return PlainFileKey(key: "plainFileKey", version: "test")
    }
    
    static func getEncryptionCipher() -> FileEncryptionCipher {
        return FileEncryptionCipher(crypto: CryptoMock.getCryptoFramework(), cipher: NSValue(), fileKey: CryptoMock.getPlainFileKey())
    }
    
    static func getDecyptionCipher() -> FileDecryptionCipher {
        return FileDecryptionCipher(crypto: CryptoMock.getCryptoFramework(), cipher: NSValue(), fileKey: CryptoMock.getPlainFileKey())
    }
    
    private static func getCryptoFramework() -> CryptoFramework {
        return OpenSslMock()
    }
}

