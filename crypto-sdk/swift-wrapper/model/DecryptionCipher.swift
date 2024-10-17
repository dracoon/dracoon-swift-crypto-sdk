//
//  DecryptionCipher.swift
//  crypto-sdk
//
//  Copyright © 2019 Dracoon. All rights reserved.
//

import Foundation

public protocol DecryptionCipher: Sendable {
    func processBlock(fileData: Data) throws -> Data
    func doFinal() throws
}
