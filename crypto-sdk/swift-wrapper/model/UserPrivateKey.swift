//
//  UserPrivateKey.swift
//  crypto-sdk
//
//  Copyright © 2018 Dracoon. All rights reserved.
//

public final class UserPrivateKey: Codable, @unchecked Sendable {
    public internal(set) var privateKey: String
    public internal(set) var version: UserKeyPairVersion
    
    public init(privateKey: String, version: UserKeyPairVersion) {
        self.privateKey = privateKey
        self.version = version
    }
}
