//
//  CryptoVersions.swift
//  crypto-sdk
//
//  Copyright © 2018 Dracoon. All rights reserved.
//

public enum UserKeyPairVersion: String {
    case RSA2048 = "A"
    case RSA4096 = "RSA-4096"
    
    public func getKeyLength() -> NSNumber {
        switch self {
        case .RSA2048:
            return 2048
        case .RSA4096:
            return 4096
        }
    }
}

public enum PlainFileKeyVersion: String {
    case AES256GCM = "A"
}

public enum EncryptedFileKeyVersion: String {
    case RSA2048_AES256GCM = "A"
    case RSA4096_AES256GCM = "RSA-4096/AES-256-GCM"
}
