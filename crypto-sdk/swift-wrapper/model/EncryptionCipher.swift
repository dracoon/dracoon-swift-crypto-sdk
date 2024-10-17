//
//  EncryptionCipher.swift
//  crypto-sdk
//
//  Copyright © 2019 Dracoon. All rights reserved.
//

import Foundation

public protocol EncryptionCipher: Sendable {
    var fileKey: PlainFileKey { get }
    func processBlock(fileData: Data) throws -> Data
    func doFinal() throws
}
