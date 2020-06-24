//
//  CryptoConstants.swift
//  crypto-sdk
//
//  Copyright © 2018 Dracoon. All rights reserved.
//

public enum UserKeyPairVersion: String {
    case A // Version A is RSA-2048
    case RSA4096 = "RSA-4096"
    
    public func getKeyLength() -> NSNumber {
        switch self {
        case .A:
            return 2048
        case .RSA4096:
            return 4096
        }
    }
}

public enum PlainFileKeyVersion: String {
    case A // Version A is AES-256-GCM
}

public enum EncryptedFileKeyVersion: String {
    case A // Version A is RSA-2048/AES-256-GCM
    case RSA4096_AES256GCM = "RSA-4096/AES-256-GCM"
}
