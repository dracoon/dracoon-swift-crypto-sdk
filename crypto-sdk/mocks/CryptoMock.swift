//
//  CryptoMock.swift
//  crypto-sdk
//
//  Copyright © 2019 Dracoon. All rights reserved.
//

public class CryptoMock {
    
    public static func getPlainFileKey() -> PlainFileKey {
        return PlainFileKey(key: "plainFileKey", version: "test")
    }
    
    public static func getEncryptionCipher() -> FileEncryptionCipher {
        return FileEncryptionCipher(crypto: CryptoMock.getCryptoFramework(), cipher: NSValue(), fileKey: CryptoMock.getPlainFileKey())
    }
    
    public static func getDecyptionCipher() -> FileDecryptionCipher {
        return FileDecryptionCipher(crypto: CryptoMock.getCryptoFramework(), cipher: NSValue(), fileKey: CryptoMock.getPlainFileKey())
    }
    
    private static func getCryptoFramework() -> CryptoFramework {
        return OpenSslMock()
    }
}

