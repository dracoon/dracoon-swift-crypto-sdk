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
        crypto = Crypto()
        testFileReader = TestFileReader()
        super.setUp()
    }
    
    // MARK: Crypto Versions
    
    func testUserKeyPairVersion_returnsExpectedRawValue() {
        XCTAssert(UserKeyPairVersion.A.rawValue == "A")
        XCTAssert(UserKeyPairVersion.RSA4096.rawValue == "RSA-4096")
    }
    
    func testUserKeyPairVersion_returnsExpectedRSAKeyLength() {
        XCTAssert(UserKeyPairVersion.A.getKeyLength().intValue == 2048)
        XCTAssert(UserKeyPairVersion.RSA4096.getKeyLength().intValue == 4096)
    }
    
    func testPlainFileKeyVersion_returnsExpectedRawValue() {
        XCTAssert(PlainFileKeyVersion.A.rawValue == "A")
    }
    
    func testEncryptedFileKeyVersion_returnsExpectedRawValue() {
        XCTAssert(EncryptedFileKeyVersion.A.rawValue == "A")
        XCTAssert(EncryptedFileKeyVersion.RSA4096_AES256GCM.rawValue == "RSA-4096/AES-256-GCM")
    }
    
    // MARK: Generate UserKeyPair
    
    func testGenerateUserKeyPair_withPassword_returnsKeyPairContainers() {
        let password = "ABC123DEFF456"
        let version = UserKeyPairVersion.A.rawValue
        let userKeyPair = try! crypto!.generateUserKeyPair(password: password, version: version)
        
        XCTAssertNotNil(userKeyPair.publicKeyContainer)
        XCTAssertNotNil(userKeyPair.privateKeyContainer)
        XCTAssert(userKeyPair.publicKeyContainer.publicKey.starts(with: "-----BEGIN PUBLIC KEY-----"))
        XCTAssert(userKeyPair.privateKeyContainer.privateKey.starts(with: "-----BEGIN ENCRYPTED PRIVATE KEY-----"))
        XCTAssert(userKeyPair.publicKeyContainer.version == version)
        XCTAssert(userKeyPair.privateKeyContainer.version == version)
    }
    
    func testGenerateUserKeyPair_with4096BitLength_returnsKeyPairContainers() {
        let password = "ABC123DEFF456"
        let version = UserKeyPairVersion.RSA4096.rawValue
        let userKeyPair = try! crypto!.generateUserKeyPair(password: password, version: version)
        
        XCTAssertNotNil(userKeyPair.publicKeyContainer)
        XCTAssertNotNil(userKeyPair.privateKeyContainer)
        XCTAssert(userKeyPair.publicKeyContainer.publicKey.starts(with: "-----BEGIN PUBLIC KEY-----"))
        XCTAssert(userKeyPair.privateKeyContainer.privateKey.starts(with: "-----BEGIN ENCRYPTED PRIVATE KEY-----"))
        XCTAssert(userKeyPair.publicKeyContainer.version == version)
        XCTAssert(userKeyPair.privateKeyContainer.version == version)
    }
    
    func testGenerateUserKeyPair_withSpecialCharacterPassword_returnsKeyPairContainers() {
        let password = "~ABC123§DEF%F456!"
        let userKeyPair = try! crypto!.generateUserKeyPair(password: password, version: UserKeyPairVersion.A.rawValue)
        
        XCTAssertNotNil(userKeyPair.publicKeyContainer)
        XCTAssertNotNil(userKeyPair.privateKeyContainer)
        XCTAssert(userKeyPair.publicKeyContainer.publicKey.starts(with: "-----BEGIN PUBLIC KEY-----"))
        XCTAssert(userKeyPair.privateKeyContainer.privateKey.starts(with: "-----BEGIN ENCRYPTED PRIVATE KEY-----"))
    }
    
    func testGenerateUserKeyPair_withEmptyPassword_throwsError() {
        let expectedError = CryptoError.generate("Password can't be empty")
        
        XCTAssertThrowsError(try crypto!.generateUserKeyPair(password: "", version: UserKeyPairVersion.A.rawValue)) { (error) -> Void in
            XCTAssertEqual(error as? CryptoError, expectedError)
        }
    }
    
    func testGenerateUserKeyPair_withUnknownVersion_throwsError() {
        let password = "ABC123DEFF456"
        let expectedError = CryptoError.generate("Unknown key pair version: Z")
        
        XCTAssertThrowsError(try crypto!.generateUserKeyPair(password: password, version: "Z")) { (error) -> Void in
            XCTAssertEqual(error as? CryptoError, expectedError)
        }
    }
    
    // MARK: Check PrivateKey
    
    func testCheckUserKeyPair_withCorrectInput_returnsTrue() {
        let password = "98h72z51#L"
        let userKeyPair = try! crypto!.generateUserKeyPair(password: password, version: UserKeyPairVersion.A.rawValue)
        
        XCTAssertTrue(crypto!.checkUserKeyPair(keyPair: userKeyPair, password: password))
    }
    
    func testCheckUserKeyPair_withUnknownVersion_returnsFalse() {
        let userKeyPair = UserKeyPair(publicKey: UserPublicKey(publicKey: "testKey", version: UserKeyPairVersion.A.rawValue),
                                      privateKey: UserPrivateKey(privateKey: "testKey", version: "Z"))

        XCTAssertFalse(crypto!.checkUserKeyPair(keyPair: userKeyPair, password: "password"))
    }
    
    func testCheckUserKeyPair_withInvalidPrivateKey_returnsFalse() {
        let password = "ABC123DEFF456"
        let userKeyPair = try! crypto!.generateUserKeyPair(password: password, version: UserKeyPairVersion.A.rawValue)
        userKeyPair.privateKeyContainer = UserPrivateKey(privateKey: "ABCDEFABCDEF", version: UserKeyPairVersion.A.rawValue)

        XCTAssertFalse(crypto!.checkUserKeyPair(keyPair: userKeyPair, password: password))
    }
    
    func testCheckUserKeyPair_withInvalidPassword_returnsFalse() {
        let password = "ABC123DEFF456"
        let userKeyPair = try! crypto!.generateUserKeyPair(password: password, version: UserKeyPairVersion.A.rawValue)
        
        XCTAssertFalse(crypto!.checkUserKeyPair(keyPair: userKeyPair, password: "0123456789"))
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
        XCTAssertEqual(encryptedFileKey!.version, EncryptedFileKeyVersion.A.rawValue)
    }
    
    func testDecryptFileKey_withKeyPairVersionRSA4096_returnsExpectedVersion() {
        let password = "ABC123DEFF456"
        let encryptedFileKey = testFileReader?.readEncryptedFileKey(fileName: "data/enc_file_key_4096.json")
        let userPrivateKey = testFileReader?.readPrivateKey(fileName: "data/private_key_4096.json")

        let plainFileKey = try? crypto!.decryptFileKey(fileKey: encryptedFileKey!, privateKey: userPrivateKey!, password: password)

        XCTAssertNotNil(plainFileKey)
        XCTAssertEqual(plainFileKey!.iv, encryptedFileKey!.iv)
        XCTAssertEqual(plainFileKey!.tag, encryptedFileKey!.tag)
        XCTAssertEqual(encryptedFileKey!.version, EncryptedFileKeyVersion.RSA4096_AES256GCM.rawValue)
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
        XCTAssert(encryptedKey!.version == EncryptedFileKeyVersion.A.rawValue)
        XCTAssert(decryptedKey!.version == PlainFileKeyVersion.A.rawValue)
    }
    
    func testEncryptFileKey__canDecryptEncryptedKey_withKeyPairVersionRSA4096() {
        let password = "ABC123DEFF456"
        let plainFileKey = testFileReader?.readPlainFileKey(fileName: "data/plain_file_key.json")
        let userPublicKey = testFileReader?.readPublicKey(fileName: "data/public_key_4096.json")
        let userPrivateKey = testFileReader?.readPrivateKey(fileName: "data/private_key_4096.json")
        
        let encryptedKey = try? crypto!.encryptFileKey(fileKey: plainFileKey!, publicKey: userPublicKey!)
        
        let decryptedKey = try? crypto!.decryptFileKey(fileKey: encryptedKey!, privateKey: userPrivateKey!, password: password)
        
        XCTAssertNotNil(decryptedKey)
        XCTAssertEqual(decryptedKey!.key, plainFileKey!.key)
        XCTAssert(encryptedKey!.version == EncryptedFileKeyVersion.RSA4096_AES256GCM.rawValue)
        XCTAssert(decryptedKey!.version == PlainFileKeyVersion.A.rawValue)
    }
    
    // MARK: Generate FileKey
    
    func testGenerateFileKey_withUnknownVersion_throwsError() {
        let expectedError = CryptoError.generate("Unknown key pair version: Z")
        
        XCTAssertThrowsError(try crypto!.generateFileKey(version: "Z")) { (error) -> Void in
            XCTAssertEqual(error as? CryptoError, expectedError)
        }
    }
    
    func testGenerateFileKey_returnsPlainFileKey() {
        let base64EncodedAES256KeyCharacterCount = 44
        
        let plainFileKey = try? crypto!.generateFileKey(version: PlainFileKeyVersion.A.rawValue)
        
        XCTAssertNotNil(plainFileKey)
        XCTAssertNotNil(plainFileKey!.key)
        XCTAssert(plainFileKey!.key.count == base64EncodedAES256KeyCharacterCount)
        XCTAssertEqual(plainFileKey!.version, PlainFileKeyVersion.A.rawValue)
        XCTAssertNil(plainFileKey!.iv)
        XCTAssertNil(plainFileKey!.tag)
    }
}
