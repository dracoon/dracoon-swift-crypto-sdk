//
//  CryptoMock.swift
//  crypto-sdk
//
//  Copyright © 2019 Dracoon. All rights reserved.
//

public class CryptoMock {
    
    public static func getPlainFileKey() -> PlainFileKey {
        return PlainFileKey(key: "plainFileKey", version: .AES256GCM)
    }
    
    public static func getEncryptionCipher() -> EncryptionCipher {
        return FileEncryptionMock()
    }
    
    public static func getDecyptionCipher() -> DecryptionCipher {
        return FileDecryptionMock()
    }
    
    public static func getCryptoFramework() -> CryptoFramework {
        return OpenSslMock()
    }
}

