//
//  UserPrivateKey.swift
//  crypto-sdk
//
//  Copyright © 2018 Dracoon. All rights reserved.
//

public class UserPrivateKey: Codable {
    public internal(set) var privateKey: String
    public internal(set) var version: UserKeyPairVersion
    
    public init(privateKey: String, version: UserKeyPairVersion) {
        self.privateKey = privateKey
        self.version = version
    }
}
