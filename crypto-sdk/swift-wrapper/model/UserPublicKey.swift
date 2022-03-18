//
//  UserPublicKey.swift
//  crypto-sdk
//
//  Copyright © 2018 Dracoon. All rights reserved.
//

public class UserPublicKey: Codable {
    public internal(set) var publicKey: String
    public internal(set) var version: UserKeyPairVersion
    
    public init(publicKey: String, version: UserKeyPairVersion){
        self.publicKey = publicKey
        self.version = version
    }
}
