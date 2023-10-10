//
//  DecryptionTests.swift
//  crypto-tests
//
//  Created by Mathias Schreiner on 08.07.20.
//  Copyright © 2020 Dracoon. All rights reserved.
//

import XCTest
@testable import crypto_sdk

class DecryptionTests: XCTestCase {
    
    var crypto: Crypto?
    var testFileReader: TestFileReader?
    
    override func setUp() {
        super.setUp()
        crypto = Crypto()
        testFileReader = TestFileReader()
    }
    
    func testCSharp_decryptFileKey_withRSA2048() {
        let password = "Pass1234!"
        let encryptedFileKey = testFileReader?.readEncryptedFileKey(fileName: "sdks/c#/enc_file_key.json")
        let userPrivateKey = testFileReader?.readPrivateKey(fileName: "sdks/c#/private_key.json")
        
        let plainFileKey = try? crypto!.decryptFileKey(fileKey: encryptedFileKey!, privateKey: userPrivateKey!, password: password)
        
        XCTAssertNotNil(plainFileKey)
    }
    
    func testCSharp_decryptFileKey_withRSA4096() {
        let password = "acw9q857n("
        let encryptedFileKey = testFileReader?.readEncryptedFileKey(fileName: "sdks/c#/enc_file_key_4096.json")
        let userPrivateKey = testFileReader?.readPrivateKey(fileName: "sdks/c#/private_key_4096.json")
        
        let plainFileKey = try? crypto!.decryptFileKey(fileKey: encryptedFileKey!, privateKey: userPrivateKey!, password: password)
        
        XCTAssertNotNil(plainFileKey)
    }
    
    func testCSharp_decryptFile() {
        let plainFileKey = testFileReader!.readPlainFileKey(fileName: "sdks/c#/plain_file_key.json")!
        let encryptedString = testFileReader!.readFileContent(fileName: "sdks/c#/files/aes256gcm/enc_file.b64")!
        let encryptedData = Data(base64Encoded: encryptedString)!
        let expectedString = testFileReader!.readFileContent(fileName: "sdks/c#/files/plain_file.b64")!
        
        let cipher = try! crypto!.createDecryptionCipher(fileKey: plainFileKey)
        let plainData = try! cipher.processBlock(fileData: encryptedData)
        try! cipher.doFinal()
        let resultedString = plainData.base64EncodedString()

        XCTAssertEqual(expectedString, resultedString)
    }
    
    func testJava_decryptFileKey_withRSA2048() {
        let password = "Qwer1234!"
        let encryptedFileKey = testFileReader?.readEncryptedFileKey(fileName: "sdks/java/enc_file_key.json")
        let userPrivateKey = testFileReader?.readPrivateKey(fileName: "sdks/java/private_key.json")
        
        let plainFileKey = try? crypto!.decryptFileKey(fileKey: encryptedFileKey!, privateKey: userPrivateKey!, password: password)
        
        XCTAssertNotNil(plainFileKey)
    }
    
    func testJava_decryptFileKey_withRSA4096() {
        let password = "Qwer1234!"
        let encryptedFileKey = testFileReader?.readEncryptedFileKey(fileName: "sdks/java/enc_file_key_4096.json")
        let userPrivateKey = testFileReader?.readPrivateKey(fileName: "sdks/java/private_key_4096.json")
        
        let plainFileKey = try? crypto!.decryptFileKey(fileKey: encryptedFileKey!, privateKey: userPrivateKey!, password: password)
        
        XCTAssertNotNil(plainFileKey)
    }
    
    func testJava_decryptFile() {
        let plainFileKey = testFileReader!.readPlainFileKey(fileName: "sdks/java/plain_file_key.json")!
        let encryptedString = testFileReader!.readFileContent(fileName: "sdks/java/files/aes256gcm/enc_file.b64")!
        let encryptedData = Data(base64Encoded: encryptedString)!
        let expectedString = testFileReader!.readFileContent(fileName: "sdks/java/files/plain_file.b64")!
        
        let cipher = try! crypto!.createDecryptionCipher(fileKey: plainFileKey)
        let plainData = try! cipher.processBlock(fileData: encryptedData)
        try! cipher.doFinal()
        let resultedString = plainData.base64EncodedString()

        XCTAssertEqual(expectedString, resultedString)
    }
    
    func testOther_decryptFileKey_withRSA2048() {
        let password = "Qwer1234!"
        let encryptedFileKey = testFileReader?.readEncryptedFileKey(fileName: "sdks/other/enc_file_key.json")
        let userPrivateKey = testFileReader?.readPrivateKey(fileName: "sdks/other/private_key.json")
        
        let plainFileKey = try? crypto!.decryptFileKey(fileKey: encryptedFileKey!, privateKey: userPrivateKey!, password: password)
        
        XCTAssertNotNil(plainFileKey)
    }
    
    func testOther_decryptFileKey_withRSA4096() {
        let password = "Qwer1234!"
        let encryptedFileKey = testFileReader?.readEncryptedFileKey(fileName: "sdks/other/enc_file_key_4096.json")
        let userPrivateKey = testFileReader?.readPrivateKey(fileName: "sdks/other/private_key_4096.json")
        
        let plainFileKey = try? crypto!.decryptFileKey(fileKey: encryptedFileKey!, privateKey: userPrivateKey!, password: password)
        
        XCTAssertNotNil(plainFileKey)
    }
    
    func testOther_decryptFile() {
        let plainFileKey = testFileReader!.readPlainFileKey(fileName: "sdks/other/plain_file_key.json")!
        let encryptedString = testFileReader!.readFileContent(fileName: "sdks/other/files/aes256gcm/enc_file.b64")!
        let encryptedData = Data(base64Encoded: encryptedString)!
        let expectedString = testFileReader!.readFileContent(fileName: "sdks/other/files/plain_file.b64")!
        
        let cipher = try! crypto!.createDecryptionCipher(fileKey: plainFileKey)
        let plainData = try! cipher.processBlock(fileData: encryptedData)
        try! cipher.doFinal()
        let resultedString = plainData.base64EncodedString()

        XCTAssertEqual(expectedString, resultedString)
    }
    
    func testSwift_decryptFileKey_withRSA2048() {
        let password = "Pass1234!"
        let encryptedFileKey = testFileReader?.readEncryptedFileKey(fileName: "sdks/swift/enc_file_key_2048.json")
        let userPrivateKey = testFileReader?.readPrivateKey(fileName: "sdks/swift/private_key_2048.json")
        
        let plainFileKey = try? crypto!.decryptFileKey(fileKey: encryptedFileKey!, privateKey: userPrivateKey!, password: password)
        
        XCTAssertNotNil(plainFileKey)
    }
    
    func testSwift_decryptFileKey_withRSA4096() {
        let password = "ABC123DEFF456"
        let encryptedFileKey = testFileReader?.readEncryptedFileKey(fileName: "sdks/swift/enc_file_key_4096.json")
        let userPrivateKey = testFileReader?.readPrivateKey(fileName: "sdks/swift/private_key_4096.json")
        
        let plainFileKey = try? crypto!.decryptFileKey(fileKey: encryptedFileKey!, privateKey: userPrivateKey!, password: password)
        
        XCTAssertNotNil(plainFileKey)
    }
    
    func testSwift_decryptFile() {
        let plainFileKey = testFileReader!.readPlainFileKey(fileName: "sdks/swift/plain_file_key.json")!
        let encryptedString = testFileReader!.readFileContent(fileName: "sdks/swift/files/aes256gcm/enc_file.b64")!
        let encryptedData = Data(base64Encoded: encryptedString)!
        let expectedString = testFileReader!.readFileContent(fileName: "sdks/swift/files/plain_file.b64")!
        
        let cipher = try! crypto!.createDecryptionCipher(fileKey: plainFileKey)
        let plainData = try! cipher.processBlock(fileData: encryptedData)
        try! cipher.doFinal()
        let resultedString = plainData.base64EncodedString()

        XCTAssertEqual(expectedString, resultedString)
    }
    
    func testWeb_decryptFileKey_withRSA2048() {
        let password = "Qwer1234!"
        let encryptedFileKey = testFileReader?.readEncryptedFileKey(fileName: "sdks/javascript/enc_file_key_2048.json")
        let userPrivateKey = testFileReader?.readPrivateKey(fileName: "sdks/javascript/private_key_2048.json")
        
        let plainFileKey = try? crypto!.decryptFileKey(fileKey: encryptedFileKey!, privateKey: userPrivateKey!, password: password)
        
        XCTAssertNotNil(plainFileKey)
    }
    
    func testWeb_decryptFileKey_withRSA4096() {
        let password = "Qwer1234!"
        let encryptedFileKey = testFileReader?.readEncryptedFileKey(fileName: "sdks/javascript/enc_file_key_4096.json")
        let userPrivateKey = testFileReader?.readPrivateKey(fileName: "sdks/javascript/private_key_4096.json")
        
        let plainFileKey = try? crypto!.decryptFileKey(fileKey: encryptedFileKey!, privateKey: userPrivateKey!, password: password)
        
        XCTAssertNotNil(plainFileKey)
    }
    
    func testWeb_decryptFile() {
        let plainFileKey = testFileReader!.readPlainFileKey(fileName: "sdks/javascript/plain_file_key.json")!
        let encryptedString = testFileReader!.readFileContent(fileName: "sdks/javascript/files/aes256gcm/enc_file.b64")!
        let encryptedData = Data(base64Encoded: encryptedString)!
        let expectedString = testFileReader!.readFileContent(fileName: "sdks/javascript/files/plain_file.b64")!
        
        let cipher = try! crypto!.createDecryptionCipher(fileKey: plainFileKey)
        let plainData = try! cipher.processBlock(fileData: encryptedData)
        try! cipher.doFinal()
        let resultedString = plainData.base64EncodedString()

        XCTAssertEqual(expectedString, resultedString)
    }
}
