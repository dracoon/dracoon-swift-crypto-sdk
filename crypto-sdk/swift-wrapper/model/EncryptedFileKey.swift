//
//  EncryptedFileKey.swift
//  crypto-sdk
//
//  Copyright © 2018 Dracoon. All rights reserved.
//

public class EncryptedFileKey: Codable {
    public let key: String
    public let version: EncryptedFileKeyVersion
    public let iv: String
    public let tag: String
    
    public init(key: String, version: EncryptedFileKeyVersion, iv: String, tag: String) {
        self.key = key
        self.version = version
        self.iv = iv
        self.tag = tag
    }
    
    public func getUserKeyPairVersion() -> UserKeyPairVersion {
        switch self.version {
        case .RSA2048_AES256GCM:
            return .RSA2048
        case .RSA4096_AES256GCM:
            return .RSA4096
        }
    }
    
    public func getFileKeyVersion() -> PlainFileKeyVersion {
        switch self.version {
        case .RSA2048_AES256GCM:
            return .AES256GCM
        case .RSA4096_AES256GCM:
            return .AES256GCM
        }
    }
}
