//
//  Crypto.swift
//  crypto-sdk
//
//  Copyright © 2018 Dracoon. All rights reserved.
//

import Foundation

public typealias Cipher = NSValue

public class Crypto : CryptoProtocol {
    
    private let crypto: CryptoFramework
    
    public init() {
        crypto = OpenSslCrypto()
    }
    
    // MARK: --- KEY MANAGEMENT ---
    
    public func generateUserKeyPair(password: String, version: UserKeyPairVersion) throws -> UserKeyPair {
        
        guard !password.isEmpty else {
            throw CryptoError.generate("Password can't be empty")
        }
        
        guard let keyDictionary = crypto.createUserKeyPair(password, keyLength: version.getKeyLength()),
            let publicKey = keyDictionary["public"] as? String,
            let privateKey = keyDictionary["private"] as? String else {
                throw CryptoError.generate("Error creating key pair")
        }
        
        guard crypto.canDecryptPrivateKey(privateKey, withPassword: password) else {
            throw CryptoError.generate("Error checking key pair")
        }
        
        let userPublicKey = UserPublicKey(publicKey: publicKey, version: version)
        let userPrivateKey = UserPrivateKey(privateKey: privateKey, version: version)
        let userKeyPair = UserKeyPair(publicKey: userPublicKey,
                                      privateKey: userPrivateKey)
        
        return userKeyPair
    }
    
    public func checkUserKeyPair(keyPair: UserKeyPair, password: String) -> Bool {
        
        guard keyPair.privateKeyContainer.version.rawValue == keyPair.publicKeyContainer.version.rawValue
            else {
                return false
        }
        
        return crypto.canDecryptPrivateKey(keyPair.privateKeyContainer.privateKey, withPassword: password)
    }
    
    // MARK: --- ASYMMETRIC ENCRYPTION AND DECRYPTION ---
    
    public func encryptFileKey(fileKey: PlainFileKey, publicKey: UserPublicKey) throws -> EncryptedFileKey {
        
        guard let iv = fileKey.iv, let tag = fileKey.tag else {
            throw CryptoError.encrypt("Incomplete FileKey")
        }
        
        guard let encryptedFileKey = crypto.encryptFileKey(fileKey.key, publicKey: publicKey.publicKey) else {
            throw CryptoError.encrypt("Error encrypting FileKey")
        }
        let encryptedFileKeyContainer = EncryptedFileKey(key: encryptedFileKey,
                                                         version: self.getEncryptedFileKeyVersion(keyPairVersion: publicKey.version, fileKeyVersion: fileKey.version),
                                                         iv: iv,
                                                         tag: tag)
        return encryptedFileKeyContainer
    }
    
    public func decryptFileKey(fileKey: EncryptedFileKey, privateKey: UserPrivateKey, password: String) throws -> PlainFileKey {
        
        guard let decryptedFileKey = crypto.decryptFileKey(fileKey.key, privateKey: privateKey.privateKey, password: password) else {
            throw CryptoError.decrypt("Error decrypting FileKey")
        }
        let plainFileKeyContainer = PlainFileKey(key: decryptedFileKey, version: fileKey.getFileKeyVersion())
        plainFileKeyContainer.iv = fileKey.iv
        plainFileKeyContainer.tag = fileKey.tag
        return plainFileKeyContainer
    }
    
    private func getEncryptedFileKeyVersion(keyPairVersion: UserKeyPairVersion, fileKeyVersion: PlainFileKeyVersion) -> EncryptedFileKeyVersion {
        switch keyPairVersion {
        case .RSA2048:
            switch fileKeyVersion {
            case .AES256GCM:
                return .RSA2048_AES256GCM
            }
        case .RSA4096:
            switch fileKeyVersion {
            case .AES256GCM:
                return .RSA4096_AES256GCM
            }
        }
    }
    
    // MARK: --- SYMMETRIC ENCRYPTION AND DECRYPTION ---
    
    public func generateFileKey(version: PlainFileKeyVersion) throws -> PlainFileKey {
        
        guard let key = crypto.createFileKey() else {
            throw CryptoError.generate("Error creating file key")
        }
        let fileKey = PlainFileKey(key: key, version: version)
        return fileKey
    }
    
    public func createEncryptionCipher(fileKey: PlainFileKey) throws -> EncryptionCipher {
        
        guard let vector = crypto.createInitializationVector() else {
            throw CryptoError.generate("Error creating IV")
        }
        fileKey.iv = vector
        
        guard let cipher = crypto.initializeEncryptionCipher(fileKey.key, vector: vector) else {
            throw CryptoError.generate("Error creating encryption cipher")
        }
        
        return FileEncryptionCipher(crypto: self.crypto, cipher: cipher, fileKey: fileKey)
    }
    
    public func createDecryptionCipher(fileKey: PlainFileKey) throws -> DecryptionCipher {
        
        guard let iv = fileKey.iv else {
            throw CryptoError.generate("FileKey has no IV")
        }
        
        guard let tag = fileKey.tag else {
            throw CryptoError.generate("FileKey has no authentication tag")
        }
        
        guard let cipher = crypto.initializeDecryptionCipher(fileKey.key, tag: tag, vector: iv) else {
            throw CryptoError.generate("Error creating decryption cipher")
        }
        
        return FileDecryptionCipher(crypto: self.crypto, cipher: cipher, fileKey: fileKey)
    }
    
}
