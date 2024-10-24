//
//  FileDecryptionMock.swift
//  crypto-sdk
//
//  Created by Mathias Schreiner on 31.07.19.
//  Copyright © 2019 Dracoon. All rights reserved.
//

import Foundation

public class FileDecryptionMock: DecryptionCipher, @unchecked Sendable {
    
    public var error: Error?
    public var data = Data()
    
    public func processBlock(fileData: Data) throws -> Data {
        if let error = error {
            throw error
        }
        return data
    }
    
    public func doFinal() throws {
        if let error = error {
            throw error
        }
    }
    
}
