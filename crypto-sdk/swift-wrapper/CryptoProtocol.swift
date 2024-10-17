//
//  CryptoProtocol.swift
//  crypto-sdk
//
//  Copyright © 2018 Dracoon. All rights reserved.
//

public protocol CryptoProtocol: Sendable {
    func generateUserKeyPair(password: String, version: UserKeyPairVersion) throws -> UserKeyPair
    func checkUserKeyPair(keyPair: UserKeyPair, password: String) -> Bool
    func encryptFileKey(fileKey: PlainFileKey, publicKey: UserPublicKey) throws -> EncryptedFileKey
    func decryptFileKey(fileKey: EncryptedFileKey, privateKey: UserPrivateKey, password: String) throws -> PlainFileKey
    func generateFileKey(version: PlainFileKeyVersion) throws -> PlainFileKey
    func createEncryptionCipher(fileKey: PlainFileKey) throws -> EncryptionCipher
    func createDecryptionCipher(fileKey: PlainFileKey) throws -> DecryptionCipher
}
