//
//  CryptoTests.swift
//  crypto-sdk
//
//  Copyright © 2018 Dracoon. All rights reserved.
//

import XCTest
@testable import crypto_sdk

class CryptoTests: XCTestCase {
    
    var crypto: Crypto?
    var testFileReader: TestFileReader?
    
    override func setUp() {
        super.setUp()
        crypto = Crypto()
        testFileReader = TestFileReader()
    }
    
    // MARK: Crypto Versions
    
    func testUserKeyPairVersion_returnsExpectedRawValue() {
        XCTAssert(UserKeyPairVersion.RSA2048.rawValue == "A")
        XCTAssert(UserKeyPairVersion.RSA4096.rawValue == "RSA-4096")
    }
    
    func testUserKeyPairVersion_returnsExpectedRSAKeyLength() {
        XCTAssert(UserKeyPairVersion.RSA2048.getKeyLength().intValue == 2048)
        XCTAssert(UserKeyPairVersion.RSA4096.getKeyLength().intValue == 4096)
    }
    
    func testPlainFileKeyVersion_returnsExpectedRawValue() {
        XCTAssert(PlainFileKeyVersion.AES256GCM.rawValue == "A")
    }
    
    func testEncryptedFileKeyVersion_returnsExpectedRawValue() {
        XCTAssert(EncryptedFileKeyVersion.RSA2048_AES256GCM.rawValue == "A")
        XCTAssert(EncryptedFileKeyVersion.RSA4096_AES256GCM.rawValue == "RSA-4096/AES-256-GCM")
    }
    
    // MARK: Generate UserKeyPair
    
    func testGenerateUserKeyPair_withPassword_returnsKeyPairContainers() {
        let password = "ABC123DEFF456"
        let version = UserKeyPairVersion.RSA2048
        let userKeyPair = try! crypto!.generateUserKeyPair(password: password, version: version)
        
        XCTAssertNotNil(userKeyPair.publicKeyContainer)
        XCTAssertNotNil(userKeyPair.privateKeyContainer)
        XCTAssert(userKeyPair.publicKeyContainer.publicKey.starts(with: "-----BEGIN PUBLIC KEY-----"))
        XCTAssert(userKeyPair.privateKeyContainer.privateKey.starts(with: "-----BEGIN ENCRYPTED PRIVATE KEY-----"))
        XCTAssert(userKeyPair.publicKeyContainer.version.rawValue == version.rawValue)
        XCTAssert(userKeyPair.privateKeyContainer.version.rawValue == version.rawValue)
    }
    
    func testGenerateUserKeyPair_with4096BitLength_returnsKeyPairContainers() {
        let password = "ABC123DEFF456"
        let version = UserKeyPairVersion.RSA4096
        let userKeyPair = try! crypto!.generateUserKeyPair(password: password, version: version)
        
        XCTAssertNotNil(userKeyPair.publicKeyContainer)
        XCTAssertNotNil(userKeyPair.privateKeyContainer)
        XCTAssert(userKeyPair.publicKeyContainer.publicKey.starts(with: "-----BEGIN PUBLIC KEY-----"))
        XCTAssert(userKeyPair.privateKeyContainer.privateKey.starts(with: "-----BEGIN ENCRYPTED PRIVATE KEY-----"))
        XCTAssert(userKeyPair.publicKeyContainer.version.rawValue == version.rawValue)
        XCTAssert(userKeyPair.privateKeyContainer.version.rawValue == version.rawValue)
    }
    
    func testGenerateUserKeyPair_withSpecialCharacterPassword_returnsKeyPairContainers() {
        let password = "~ABC123§DEF%F456!"
        let userKeyPair = try! crypto!.generateUserKeyPair(password: password, version: UserKeyPairVersion.RSA2048)
        
        XCTAssertNotNil(userKeyPair.publicKeyContainer)
        XCTAssertNotNil(userKeyPair.privateKeyContainer)
        XCTAssert(userKeyPair.publicKeyContainer.publicKey.starts(with: "-----BEGIN PUBLIC KEY-----"))
        XCTAssert(userKeyPair.privateKeyContainer.privateKey.starts(with: "-----BEGIN ENCRYPTED PRIVATE KEY-----"))
    }
    
    func testGenerateUserKeyPair_withEmptyPassword_throwsError() {
        let expectedError = CryptoError.generate("Password can't be empty")
        
        XCTAssertThrowsError(try crypto!.generateUserKeyPair(password: "", version: UserKeyPairVersion.RSA2048)) { (error) -> Void in
            XCTAssertEqual(error as? CryptoError, expectedError)
        }
    }
    
    // MARK: Check PrivateKey
    
    func testCheckUserKeyPair_withInvalidPrivateKey_returnsFalse() {
        let password = "ABC123DEFF456"
        let userKeyPair = try! crypto!.generateUserKeyPair(password: password, version: UserKeyPairVersion.RSA2048)
        userKeyPair.privateKeyContainer = UserPrivateKey(privateKey: "ABCDEFABCDEF", version: UserKeyPairVersion.RSA2048)

        XCTAssertFalse(crypto!.checkUserKeyPair(keyPair: userKeyPair, password: password))
    }
    
    func testCheckUserKeyPair_withInvalidPassword_returnsFalse() {
        let password = "ABC123DEFF456"
        let userKeyPair = try! crypto!.generateUserKeyPair(password: password, version: UserKeyPairVersion.RSA2048)
        
        XCTAssertFalse(crypto!.checkUserKeyPair(keyPair: userKeyPair, password: "0123456789"))
    }
    
    func testCheckUserKeyPair_withRSA2048_returnsTrue() {
        let password = "ABC123DEFF456"
        let userKeyPair = try! crypto!.generateUserKeyPair(password: password, version: UserKeyPairVersion.RSA2048)
        
        XCTAssertTrue(crypto!.checkUserKeyPair(keyPair: userKeyPair, password: password))
    }
    
    func testCheckUserKeyPair_withRSA4096_returnsTrue() {
        let password = "ABC123DEFF456"
        let userKeyPair = try! crypto!.generateUserKeyPair(password: password, version: UserKeyPairVersion.RSA4096)
        
        XCTAssertTrue(crypto!.checkUserKeyPair(keyPair: userKeyPair, password: password))
    }
    
    // MARK: FileKey decryption and encryption
    
    func testDecryptFileKey_withWrongPassword_throwsError() {
        let password = "wrongPassword"
        let encryptedFileKey = testFileReader?.readEncryptedFileKey(fileName: "data/enc_file_key.json")
        let userPrivateKey = testFileReader?.readPrivateKey(fileName: "data/private_key.json")
        let expectedError = CryptoError.decrypt("Error decrypting FileKey")
        
        XCTAssertThrowsError(try crypto!.decryptFileKey(fileKey: encryptedFileKey!, privateKey: userPrivateKey!, password: password)) { (error) -> Void in
            XCTAssertEqual(error as? CryptoError, expectedError)
        }
    }
    
    func testDecryptFileKey_withKeyPairVersionA_returnsPlainFileKey() {
        let password = "Pass1234!"
        let encryptedFileKey = testFileReader?.readEncryptedFileKey(fileName: "data/enc_file_key.json")
        let userPrivateKey = testFileReader?.readPrivateKey(fileName: "data/private_key.json")
        
        let plainFileKey = try? crypto!.decryptFileKey(fileKey: encryptedFileKey!, privateKey: userPrivateKey!, password: password)
        
        XCTAssertNotNil(plainFileKey)
        XCTAssertEqual(plainFileKey!.iv, encryptedFileKey!.iv)
        XCTAssertEqual(plainFileKey!.tag, encryptedFileKey!.tag)
        XCTAssertEqual(encryptedFileKey!.version, EncryptedFileKeyVersion.RSA2048_AES256GCM)
    }
    
    func testDecryptFileKey_withKeyPairVersionRSA4096_returnsExpectedVersion() {
        let password = "ABC123DEFF456"
        let encryptedFileKey = testFileReader?.readEncryptedFileKey(fileName: "data/enc_file_key_4096.json")
        let userPrivateKey = testFileReader?.readPrivateKey(fileName: "data/private_key_4096.json")

        let plainFileKey = try? crypto!.decryptFileKey(fileKey: encryptedFileKey!, privateKey: userPrivateKey!, password: password)

        XCTAssertNotNil(plainFileKey)
        XCTAssertEqual(plainFileKey!.iv, encryptedFileKey!.iv)
        XCTAssertEqual(plainFileKey!.tag, encryptedFileKey!.tag)
        XCTAssertEqual(encryptedFileKey!.version, EncryptedFileKeyVersion.RSA4096_AES256GCM)
    }
    
    func testEncryptFileKey_withMissingIV_throwsError() {
        let plainFileKey = testFileReader?.readPlainFileKey(fileName: "data/plain_file_key.json")
        plainFileKey?.iv = nil
        let userPublicKey = testFileReader?.readPublicKey(fileName: "data/public_key.json")
        let expectedError = CryptoError.encrypt("Incomplete FileKey")
        
        XCTAssertThrowsError(try crypto!.encryptFileKey(fileKey: plainFileKey!, publicKey: userPublicKey!)) { (error) -> Void in
            XCTAssertEqual(error as? CryptoError, expectedError)
        }
    }
    
    func testEncryptFileKey_withMissingTag_throwsError() {
        let plainFileKey = testFileReader?.readPlainFileKey(fileName: "data/plain_file_key.json")
        plainFileKey?.tag = nil
        let userPublicKey = testFileReader?.readPublicKey(fileName: "data/public_key.json")
        let expectedError = CryptoError.encrypt("Incomplete FileKey")
        
        XCTAssertThrowsError(try crypto!.encryptFileKey(fileKey: plainFileKey!, publicKey: userPublicKey!)) { (error) -> Void in
            XCTAssertEqual(error as? CryptoError, expectedError)
        }
    }
    
    func testEncryptFileKey_canDecryptEncryptedKey_withKeyPairVersionA() {
        let password = "Pass1234!"
        let plainFileKey = testFileReader?.readPlainFileKey(fileName: "data/plain_file_key.json")
        let userPublicKey = testFileReader?.readPublicKey(fileName: "data/public_key.json")
        let userPrivateKey = testFileReader?.readPrivateKey(fileName: "data/private_key.json")
        
        let encryptedKey = try? crypto!.encryptFileKey(fileKey: plainFileKey!, publicKey: userPublicKey!)
        
        let decryptedKey = try? crypto!.decryptFileKey(fileKey: encryptedKey!, privateKey: userPrivateKey!, password: password)
        
        XCTAssertNotNil(decryptedKey)
        XCTAssertEqual(decryptedKey!.key, plainFileKey!.key)
        XCTAssert(encryptedKey!.version.rawValue == EncryptedFileKeyVersion.RSA2048_AES256GCM.rawValue)
        XCTAssert(decryptedKey!.version.rawValue == PlainFileKeyVersion.AES256GCM.rawValue)
    }
    
    func testEncryptFileKey_canDecryptEncryptedKey_withKeyPairVersionRSA4096() {
        let password = "ABC123DEFF456"
        let plainFileKey = testFileReader?.readPlainFileKey(fileName: "data/plain_file_key.json")
        let userPublicKey = testFileReader?.readPublicKey(fileName: "data/public_key_4096.json")
        let userPrivateKey = testFileReader?.readPrivateKey(fileName: "data/private_key_4096.json")
        
        let encryptedKey = try? crypto!.encryptFileKey(fileKey: plainFileKey!, publicKey: userPublicKey!)
        
        let decryptedKey = try? crypto!.decryptFileKey(fileKey: encryptedKey!, privateKey: userPrivateKey!, password: password)
        
        XCTAssertNotNil(decryptedKey)
        XCTAssertEqual(decryptedKey!.key, plainFileKey!.key)
        XCTAssert(encryptedKey!.version.rawValue == EncryptedFileKeyVersion.RSA4096_AES256GCM.rawValue)
        XCTAssert(decryptedKey!.version.rawValue == PlainFileKeyVersion.AES256GCM.rawValue)
    }
    
    // MARK: Generate FileKey
    
    func testGenerateFileKey_returnsPlainFileKey() {
        let base64EncodedAES256KeyCharacterCount = 44
        
        let plainFileKey = try? crypto!.generateFileKey(version: PlainFileKeyVersion.AES256GCM)
        
        XCTAssertNotNil(plainFileKey)
        XCTAssertNotNil(plainFileKey!.key)
        XCTAssert(plainFileKey!.key.count == base64EncodedAES256KeyCharacterCount)
        XCTAssertEqual(plainFileKey!.version.rawValue, PlainFileKeyVersion.AES256GCM.rawValue)
        XCTAssertNil(plainFileKey!.iv)
        XCTAssertNil(plainFileKey!.tag)
    }
}
