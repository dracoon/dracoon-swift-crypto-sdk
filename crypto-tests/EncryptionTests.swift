//
//  EncryptionTests.swift
//  crypto-tests
//
//  Created by Mathias Schreiner on 08.07.20.
//  Copyright © 2020 Dracoon. All rights reserved.
//

import XCTest
@testable import crypto_sdk

class EncryptionTests: XCTestCase {
    
    var crypto: Crypto?
    var testFileReader: TestFileReader?
    
    override func setUp() {
        super.setUp()
        crypto = Crypto()
        testFileReader = TestFileReader()
    }
    
    func testCSharp_encryptFileKey_withRSA2048() {
        let plainFileKey = testFileReader?.readPlainFileKey(fileName: "sdks/c#/plain_file_key.json")
        let userPublicKey = testFileReader?.readPublicKey(fileName: "sdks/c#/public_key.json")
        
        let encryptedFileKey = try? crypto!.encryptFileKey(fileKey: plainFileKey!, publicKey: userPublicKey!)
        
        XCTAssertNotNil(encryptedFileKey)
        XCTAssert(encryptedFileKey?.version == EncryptedFileKeyVersion.RSA2048_AES256GCM)
    }
    
    func testCSharp_encryptFileKey_withRSA4096() {
        let plainFileKey = testFileReader?.readPlainFileKey(fileName: "sdks/c#/plain_file_key.json")
        let userPublicKey = testFileReader?.readPublicKey(fileName: "sdks/c#/public_key_4096.json")
        
        let encryptedFileKey = try? crypto!.encryptFileKey(fileKey: plainFileKey!, publicKey: userPublicKey!)
        
        XCTAssertNotNil(encryptedFileKey)
        XCTAssert(encryptedFileKey?.version == EncryptedFileKeyVersion.RSA4096_AES256GCM)
    }
    
    func testJava_encryptFileKey_withRSA2048() {
        let plainFileKey = testFileReader?.readPlainFileKey(fileName: "sdks/java/plain_file_key.json")
        let userPublicKey = testFileReader?.readPublicKey(fileName: "sdks/java/public_key.json")
        
        let encryptedFileKey = try? crypto!.encryptFileKey(fileKey: plainFileKey!, publicKey: userPublicKey!)
        
        XCTAssertNotNil(encryptedFileKey)
        XCTAssert(encryptedFileKey?.version == EncryptedFileKeyVersion.RSA2048_AES256GCM)
    }
    
    func testJava_encryptFileKey_withRSA4096() {
        let plainFileKey = testFileReader?.readPlainFileKey(fileName: "sdks/java/plain_file_key.json")
        let userPublicKey = testFileReader?.readPublicKey(fileName: "sdks/java/public_key_4096.json")
        
        let encryptedFileKey = try? crypto!.encryptFileKey(fileKey: plainFileKey!, publicKey: userPublicKey!)
        
        XCTAssertNotNil(encryptedFileKey)
        XCTAssert(encryptedFileKey?.version == EncryptedFileKeyVersion.RSA4096_AES256GCM)
    }
    
    func testOther_encryptFileKey_withRSA2048() {
        let plainFileKey = testFileReader?.readPlainFileKey(fileName: "sdks/other/plain_file_key.json")
        let userPublicKey = testFileReader?.readPublicKey(fileName: "sdks/other/public_key.json")
        
        let encryptedFileKey = try? crypto!.encryptFileKey(fileKey: plainFileKey!, publicKey: userPublicKey!)
        
        XCTAssertNotNil(encryptedFileKey)
        XCTAssert(encryptedFileKey?.version == EncryptedFileKeyVersion.RSA2048_AES256GCM)
    }
    
    func testOther_encryptFileKey_withRSA4096() {
        let plainFileKey = testFileReader?.readPlainFileKey(fileName: "sdks/other/plain_file_key.json")
        let userPublicKey = testFileReader?.readPublicKey(fileName: "sdks/other/public_key_4096.json")
        
        let encryptedFileKey = try? crypto!.encryptFileKey(fileKey: plainFileKey!, publicKey: userPublicKey!)
        
        XCTAssertNotNil(encryptedFileKey)
        XCTAssert(encryptedFileKey?.version == EncryptedFileKeyVersion.RSA4096_AES256GCM)
    }
    
    func testSwift_encryptFileKey_withRSA2048() {
        let plainFileKey = testFileReader?.readPlainFileKey(fileName: "sdks/swift/plain_file_key.json")
        let userPublicKey = testFileReader?.readPublicKey(fileName: "sdks/swift/public_key_2048.json")
        
        let encryptedFileKey = try? crypto!.encryptFileKey(fileKey: plainFileKey!, publicKey: userPublicKey!)
        
        XCTAssertNotNil(encryptedFileKey)
        XCTAssert(encryptedFileKey?.version == EncryptedFileKeyVersion.RSA2048_AES256GCM)
    }
    
    func testSwift_encryptFileKey_withRSA4096() {
        let plainFileKey = testFileReader?.readPlainFileKey(fileName: "sdks/swift/plain_file_key.json")
        let userPublicKey = testFileReader?.readPublicKey(fileName: "sdks/swift/public_key.json")
        
        let encryptedFileKey = try? crypto!.encryptFileKey(fileKey: plainFileKey!, publicKey: userPublicKey!)
        
        XCTAssertNotNil(encryptedFileKey)
        XCTAssert(encryptedFileKey?.version == EncryptedFileKeyVersion.RSA4096_AES256GCM)
    }
    
    func testWeb_encryptFileKey_withRSA2048() {
        let plainFileKey = testFileReader?.readPlainFileKey(fileName: "sdks/javascript/plain_file_key.json")
        let userPublicKey = testFileReader?.readPublicKey(fileName: "sdks/javascript/public_key_2048.json")
        
        let encryptedFileKey = try? crypto!.encryptFileKey(fileKey: plainFileKey!, publicKey: userPublicKey!)
        
        XCTAssertNotNil(encryptedFileKey)
        XCTAssert(encryptedFileKey?.version == EncryptedFileKeyVersion.RSA2048_AES256GCM)
    }
    
    func testWeb_encryptFileKey_withRSA4096() {
        let plainFileKey = testFileReader?.readPlainFileKey(fileName: "sdks/javascript/plain_file_key.json")
        let userPublicKey = testFileReader?.readPublicKey(fileName: "sdks/javascript/public_key_4096.json")
        
        let encryptedFileKey = try? crypto!.encryptFileKey(fileKey: plainFileKey!, publicKey: userPublicKey!)
        
        XCTAssertNotNil(encryptedFileKey)
        XCTAssert(encryptedFileKey?.version == EncryptedFileKeyVersion.RSA4096_AES256GCM)
    }
}
