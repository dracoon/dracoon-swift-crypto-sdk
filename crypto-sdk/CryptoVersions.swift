//
//  CryptoConstants.swift
//  crypto-sdk
//
//  Copyright © 2018 Dracoon. All rights reserved.
//

public enum UserKeyPairVersion: String {
    case A
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

public enum FileKeyVersion: String {
    case A
    case RSA4096_AES256GCM = "RSA-4096/AES-256-GCM"
}
