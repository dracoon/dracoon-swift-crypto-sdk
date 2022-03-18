//
//  PlainFileKey.swift
//  crypto-sdk
//
//  Copyright © 2018 Dracoon. All rights reserved.
//

public class PlainFileKey {
    public let key: String
    public let version: PlainFileKeyVersion
    
    public internal(set) var iv: String?
    public internal(set) var tag: String?
    
    init(key: String, version: PlainFileKeyVersion) {
        self.key = key
        self.version = version
    }
}
