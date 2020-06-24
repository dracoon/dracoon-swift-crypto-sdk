//
//  Crypto.swift
//  crypto-sdk
//
//  Copyright © 2018 Dracoon. All rights reserved.
//

public typealias Cipher = NSValue

public class Crypto : CryptoProtocol {
    
    private let crypto: CryptoFramework
    
    public init() {
        crypto = OpenSslCrypto()
    }
    
    // MARK: --- KEY MANAGEMENT ---
    
    public func generateUserKeyPair(password: String, version: String) throws -> UserKeyPair {
        
        guard !password.isEmpty else {
            throw CryptoError.generate("Password can't be empty")
        }
        
        guard let cryptoVersion = UserKeyPairVersion(rawValue: version) else {
            throw CryptoError.generate("Unknown key pair version: \(version)")
        }
        
        guard let keyDictionary = crypto.createUserKeyPair(password, keyLength: cryptoVersion.getKeyLength()),
            let publicKey = keyDictionary["public"] as? String,
            let privateKey = keyDictionary["private"] as? String else {
                throw CryptoError.generate("Error creating key pair")
        }
        
        guard crypto.canDecryptPrivateKey(privateKey, withPassword: password) else {
            throw CryptoError.generate("Error checking key pair")
        }
        
        let userPublicKey = UserPublicKey(publicKey: publicKey,
                                          version: cryptoVersion.rawValue)
        
        let userPrivateKey = UserPrivateKey(privateKey: privateKey,
                                            version: cryptoVersion.rawValue)
        
        let userKeyPair = UserKeyPair(publicKey: userPublicKey,
                                      privateKey: userPrivateKey)
        
        return userKeyPair
    }
    
    public func checkUserKeyPair(keyPair: UserKeyPair, password: String) -> Bool {
        
        guard let privateKeyVersion = UserKeyPairVersion(rawValue: keyPair.privateKeyContainer.version),
            let publicKeyVersion = UserKeyPairVersion(rawValue: keyPair.publicKeyContainer.version),
            privateKeyVersion == publicKeyVersion
            else {
                return false
        }
        
        return crypto.canDecryptPrivateKey(keyPair.privateKeyContainer.privateKey, withPassword: password)
    }
    
    // MARK: --- ASYMMETRIC ENCRYPTION AND DECRYPTION ---
    
    public func encryptFileKey(fileKey: PlainFileKey, publicKey: UserPublicKey) throws -> EncryptedFileKey {
        
        guard let keyPairVersion = UserKeyPairVersion(rawValue: publicKey.version) else {
            throw CryptoError.encrypt("Unknown key pair version: \(publicKey.version)")
        }
        
        guard let fileKeyVersion = PlainFileKeyVersion(rawValue: fileKey.version) else {
            throw CryptoError.generate("Unknown file key version: \(fileKey.version)")
        }
        
        guard let iv = fileKey.iv, let tag = fileKey.tag else {
            throw CryptoError.encrypt("Incomplete FileKey")
        }
        
        guard let encryptedFileKey = crypto.encryptFileKey(fileKey.key, publicKey: publicKey.publicKey) else {
            throw CryptoError.encrypt("Error encrypting FileKey")
        }
        let encryptedFileKeyContainer = EncryptedFileKey(key: encryptedFileKey,
                                                         version: self.getEncryptedFileKeyVersion(keyPairVersion: keyPairVersion, fileKeyVersion: fileKeyVersion).rawValue,
                                                         iv: iv,
                                                         tag: tag)
        return encryptedFileKeyContainer
    }
    
    private func getEncryptedFileKeyVersion(keyPairVersion: UserKeyPairVersion, fileKeyVersion: PlainFileKeyVersion) -> EncryptedFileKeyVersion {
        switch keyPairVersion {
        case .A:
            switch fileKeyVersion {
            case .A:
                return .A
            }
        case .RSA4096:
            switch fileKeyVersion {
            case .A:
                return .RSA4096_AES256GCM
            }
        }
    }
    
    public func decryptFileKey(fileKey: EncryptedFileKey, privateKey: UserPrivateKey, password: String) throws -> PlainFileKey {
        
        guard UserKeyPairVersion(rawValue: privateKey.version) != nil else {
            throw CryptoError.encrypt("Unknown key pair version: \(privateKey.version)")
        }
        
        guard EncryptedFileKeyVersion(rawValue: fileKey.version) != nil else {
            throw CryptoError.generate("Unknown file key version: \(fileKey.version)")
        }
        
        guard let decryptedFileKey = crypto.decryptFileKey(fileKey.key, privateKey: privateKey.privateKey, password: password) else {
            throw CryptoError.decrypt("Error decrypting FileKey")
        }
        let plainFileKeyContainer = PlainFileKey(key: decryptedFileKey, version: fileKey.version)
        plainFileKeyContainer.iv = fileKey.iv
        plainFileKeyContainer.tag = fileKey.tag
        return plainFileKeyContainer
    }
    
    // MARK: --- SYMMETRIC ENCRYPTION AND DECRYPTION ---
    
    public func generateFileKey(version: String) throws -> PlainFileKey {
        
        guard let fileKeyVersion = PlainFileKeyVersion(rawValue: version) else {
            throw CryptoError.generate("Unknown file key version: \(version)")
        }
        
        guard let key = crypto.createFileKey() else {
            throw CryptoError.generate("Error creating file key")
        }
        let fileKey = PlainFileKey(key: key, version: fileKeyVersion.rawValue)
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
