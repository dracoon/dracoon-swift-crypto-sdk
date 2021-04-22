# DRACOON Swift Crypto SDK

A library which implements the client-side encryption of DRACOON.

# Introduction

A detailed description of client-side encryption of DRACOON can be found here:

https://support.dracoon.com/hc/en-us/articles/360000986345

# Setup

#### Minimum Requirements

Xcode 12

#### Build boringSSL

`./build-boringssl.sh`

#### Carthage

Add the SDK to your Cartfile:

`github "dracoon/dracoon-swift-crypto-sdk.git" ~> 2.0.0`

Then run

`carthage update --use-xcframeworks --platform iOS`

To add the xcframework to your project, open it in Xcode, select the "Build phases" tab in targets settings and add it to "Link Binary With Libraries". Then select "General" and choose "Embed and Sign" in the "Frameworks, Libraries, and Embedded Content" section.

#### CocoaPods

Add to your Podfile:
```
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '11.4'
use_frameworks!

target '<Your Target Name>' do
pod 'DRACOON-Crypto-SDK', '~> v2.0.0'
end
```
Then run

`pod install`

#### Build examples

There is an example app in `build_examples`.

Run `sh setupCarthage.sh` and `sh setupCocoaPods.sh`.
The run `sh regenerateProjects` to generate both the example projects.

To run the Carthage project open `CryptoSDKCarthageExample.xcodeproj`
To run the CocoaPods project open `CryptoSDKCocoaPodsExample.xcworkspace`

# Example

An example playground can be found here: `Example/CryptoSDK.playground`

The example shows the complete encryption workflow, i.e. generate user keypair, validate user
keypair, generate file key, encrypt file key, and finally encrypt and decrypt a file.

```swift
    // --- INITIALIZATION ---
    let crypto = Crypto()
    // Generate key pair
    let userKeyPair = try crypto.generateUserKeyPair(password: USER_PASSWORD)
    // Check key pair
    if !crypto.checkUserKeyPair(keyPair: userKeyPair, password: USER_PASSWORD) {
        ...
    }

    let plainData = plainText.data(using: .utf8)

    ...

    // --- ENCRYPTION ---
    // Generate plain file key
    let plainFileKey = try crypto.generateFileKey()
    // Encrypt blocks
    let encryptionCipher = try crypto.createEncryptionCipher(fileKey: fileKey)
    let encData = try encryptionCipher.processBlock(fileData: plainData)
    try encryptionCipher.doFinal()
    // Encrypt file key
    let encryptedKey = try crypto.encryptFileKey(fileKey: plainFileKey, publicKey: userKeyPair.publicKeyContainer)

    ...

    // --- DECRYPTION ---
    // Decrypt file key
    let decryptedKey = try crypto.decryptFileKey(fileKey: encryptedKey, privateKey: userKeyPair.privateKeyContainer,
      USER_PASSWORD)
    // Decrypt blocks
    let decryptionCipher = try crypto.createDecryptionCipher(fileKey: fileKey)
    let decData = try decryptionCipher.processBlock(fileData: encData)
    try decryptionCipher.doFinal()

    ...
```

# Copyright and License

See [LICENSE](LICENSE)
