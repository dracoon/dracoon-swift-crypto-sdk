//
//  DecryptionCipher.swift
//  crypto-sdk
//
//  Copyright © 2019 Dracoon. All rights reserved.
//

public protocol DecryptionCipher {
    func processBlock(fileData: Data) throws -> Data
    func doFinal() throws
}
