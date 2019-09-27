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
    
    // MARK: Generate UserKeyPair
    
    func testGenerateUserKeyPair_withPassword_returnsKeyPairContainers() {
        let password = "ABC123DEFF456"
        let userKeyPair = try! crypto!.generateUserKeyPair(password: password)
        
        XCTAssertNotNil(userKeyPair.publicKeyContainer)
        XCTAssertNotNil(userKeyPair.privateKeyContainer)
        XCTAssert(userKeyPair.publicKeyContainer.publicKey.starts(with: "-----BEGIN PUBLIC KEY-----"))
        XCTAssert(userKeyPair.privateKeyContainer.privateKey.starts(with: "-----BEGIN ENCRYPTED PRIVATE KEY-----"))
    }
    
    func testGenerateUserKeyPair_withSpecialCharacterPassword_returnsKeyPairContainers() {
        let password = "~ABC123§DEF%F456!"
        let userKeyPair = try! crypto!.generateUserKeyPair(password: password)
        
        XCTAssertNotNil(userKeyPair.publicKeyContainer)
        XCTAssertNotNil(userKeyPair.privateKeyContainer)
        XCTAssert(userKeyPair.publicKeyContainer.publicKey.starts(with: "-----BEGIN PUBLIC KEY-----"))
        XCTAssert(userKeyPair.privateKeyContainer.privateKey.starts(with: "-----BEGIN ENCRYPTED PRIVATE KEY-----"))
    }
    
    func testGenerateUserKeyPair_withoutVersion_usesDefaultVersion() {
        let password = "ABC123DEFF456"
        let userKeyPair = try! crypto!.generateUserKeyPair(password: password)
        
        XCTAssertEqual(userKeyPair.publicKeyContainer.version, CryptoConstants.DEFAULT_VERSION)
        XCTAssertEqual(userKeyPair.privateKeyContainer.version, CryptoConstants.DEFAULT_VERSION)
    }
    
    func testGenerateUserKeyPair_withEmptyPassword_throwsError() {
        let expectedError = CryptoError.generate("Password can't be empty")
        
        XCTAssertThrowsError(try crypto!.generateUserKeyPair(password: "")) { (error) -> Void in
            XCTAssertEqual(error as? CryptoError, expectedError)
        }
    }
    
    func testGenerateUserKeyPair_withUnknownVersion_throwsError() {
        let password = "ABC123DEFF456"
        let expectedError = CryptoError.generate("Unknown key pair version")
        
        XCTAssertThrowsError(try crypto!.generateUserKeyPair(password: password, version: "Z")) { (error) -> Void in
            XCTAssertEqual(error as? CryptoError, expectedError)
        }
    }
    
    // MARK: Check PrivateKey
    
    func testCheckUserKeyPair_withCorrectInput_returnsTrue() {
        let password = "98h72z51#L"
        let userKeyPair = try! crypto!.generateUserKeyPair(password: password)
        
        XCTAssertTrue(crypto!.checkUserKeyPair(keyPair: userKeyPair, password: password))
    }
    
    func testCheckUserKeyPair_withUnknownVersion_returnsFalse() {
        let password = "ABC123DEFF456"
        let userKeyPair = try! crypto!.generateUserKeyPair(password: password)
        userKeyPair.privateKeyContainer.version = "Z"
        
        XCTAssertFalse(crypto!.checkUserKeyPair(keyPair: userKeyPair, password: password))
    }
    
    func testCheckUserKeyPair_withInvalidPrivateKey_returnsFalse() {
        let password = "ABC123DEFF456"
        let userKeyPair = try! crypto!.generateUserKeyPair(password: password)
        userKeyPair.privateKeyContainer = UserPrivateKey(privateKey: "ABCDEFABCDEF", version: CryptoConstants.DEFAULT_VERSION)
        
        XCTAssertFalse(crypto!.checkUserKeyPair(keyPair: userKeyPair, password: password))
    }
    
    func testCheckUserKeyPair_withInvalidPassword_returnsFalse() {
        let password = "ABC123DEFF456"
        let userKeyPair = try! crypto!.generateUserKeyPair(password: password)
        
        XCTAssertFalse(crypto!.checkUserKeyPair(keyPair: userKeyPair, password: "0123456789"))
    }
    
    func testKeypair_works() {
        let pw = "98h72z51#L"
        let testKey = "-----BEGIN ENCRYPTED PRIVATE KEY-----\r\n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\r\n-----END ENCRYPTED PRIVATE KEY-----\r\n"
        let publicKey = UserPublicKey(publicKey: "12345", version: "A")
        let privateKey = UserPrivateKey(privateKey: testKey, version: "A")
        let keyPair = UserKeyPair(publicKey: publicKey, privateKey: privateKey)
        
        XCTAssertTrue(crypto!.checkUserKeyPair(keyPair: keyPair, password: pw))
    }
    
    func testKeypair_fail() {
        let pw = "98h72z51#L"
        let testKey = "-----BEGIN ENCRYPTED PRIVATE KEY-----\r\n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\r\n-----END ENCRYPTED PRIVATE KEY-----\r\n"
        let publicKey = UserPublicKey(publicKey: "12345", version: "A")
        let privateKey = UserPrivateKey(privateKey: testKey, version: "A")
        let keyPair = UserKeyPair(publicKey: publicKey, privateKey: privateKey)
        
        XCTAssertTrue(crypto!.checkUserKeyPair(keyPair: keyPair, password: pw))
    }
    
    func testKeypair_fail2() {
        let pw = "Qwer1234"
        let testKey = "-----BEGIN ENCRYPTED PRIVATE KEY-----\r\nMIIFKzBVBgkqhkiG9w0BBQ0wSDAnBgkqhkiG9w0BBQwwGgQUb2wsZ9aq3fI3J2W0\r\nj0iYab3ukbICAicQMB0GCWCGSAFlAwQBKgQQ/u9HJAcrqGdhgs8AZKExRgSCBNBC\r\nQ0DiOvYFcC/QLs3IKsaW+L32tjHplLr93fx3i6HWV8TJP6pC6kGtHPhaiKG0nC4N\r\n0FmWISlr5QS2pxwYRPKvFbBX2MJsP4G1tB8cHFa5wqALOzdeuG3rfkgAJEEBrX/T\r\nGHSTefsRoDNt3KVeyBBcSOJHmG3RlToBuM/bwTU2GamkfsBhTG0fSkB1opYzXvJa\r\nrkfSvVGZO1KBmgcKXWOz1o5wgGqWfQk7fjcg83oQANJeVDD6QYqiE8CBr9veWJH8\r\n+kcuWecDpYv7fCVyyom/8fKayy+kK3ylrO7+ptTDoYh0vS/ZUioBzVh7xeL2L8g2\r\nLerR4qAEL0qg5ldo2zKDyOpKP6XssUnxkNJU7Mo6nRfTZrM1YcROayYKVpdlC6YX\r\nvDFIUCalzQjS2CBJnwz/QvN8uvJFX7gNFVsl6onb8EAzDQ2nTJice6JHt37C39Hw\r\nxpuzCS0J0dcgZWahTh+CnzhBHVlEu/77YDgKtAN8QQeR3YftINAIHbMmMaFb8uIl\r\nBThmMiJMqCxg15o5pZLdTRTZ6pzLA4WnvMK40dYT0FQ+WSG+P3sC8bzcJW8Fq1UX\r\n02dYqeccbxk6+0phWzll+s8v9iUT67H0IUbtoYVAMBc5RwilCkJVk5JGs5SoGppJ\r\nSeFgqJt4VT71rkugxsrurLI6rYBoSi1f77aHxlwngJC+VWzHKdkin+GD/mDUA1Cn\r\nNeYvw8o0haD8kCzZtoEKHsN8u2OJrVpViWIQp7fDg9I2EUaZbfRxfIgthR9Fv0tX\r\nkRlRT6sK7RhkfQ+SDf6XBzTaXvm2VnTt8Aq/14drNBq69XK9kqT/sVomrWYdNAsZ\r\nO0JvwNgQFwYIpdjHv54niJRucPgp/Bqv2EkH2CMBmvZTgmbphZjbihXJeHx6akzi\r\nj5K06PRpYQoyu+LFRAdZdzDfX15+UQZfZ2TaklodhJKFh/8mfhPHQAtALmA0eCiB\r\nf0Hn/EhZTAQjQ/Sfl3Q1LYis0aQCJ1jhBv/+6j7Tes3H84GIX/bDN8H2pAXRmE5n\r\nZkdTLGkmA7m/TH1GUKxRFUXOzvK4Z2HrLrshvBcR1HUwobYx5SlcPK4qC1M7tP8v\r\nghS6VOWJRvm3fcYONF7fxR9ZgEn0CFYvFFeADRNPOQJRa6gnTqneW/bSeBnnkuQa\r\n0Uz467gnBpxEt1p8KrUvw+oyhwWIBSiZ8KQIBDbQtKtyYDjwqyZeWqZPJfCB5Wn7\r\nxK2QfFVx2IZMme00D6w6DMn2/9dTrF5S2lDCLnphhomrED82Efbw7ynSe4tfvWJw\r\nxkvBoHU33VyCZxuv1OgsXoa08j/yOR5vsXsfPq/k5/bXWCED/7R2O1G5l7sS+4cf\r\nEOAbK2bzfJ2UHzqSA0yPmqECi3zHYBw32zpEDfJVILDuWZa+2gWuqFowW61yXCb/\r\nNe08S+4TOM1ueChoo0LHaaoaUMAr7a7csjeWtj/Hvy5+F5dVnVmP8SY+L+//J0m/\r\n7YOh1kPXwso2wmSRS23oKFLhd5txm7BU1L51Gm3cLjKD4jdLl6T65l4ik3PKeS8z\r\n2BuYJ35TpFGT6SqDbRPvoO2GKDwATVfGZUYW53mcfF5eXmguPEjuHVFvvfLMxvXe\r\ngtFmqNAtoJVUAQZsGcp134uGNSx1slsWLkP+mFtjBQ==\r\n-----END ENCRYPTED PRIVATE KEY-----\r\n"
        let publicKey = UserPublicKey(publicKey: "12345", version: "A")
        let privateKey = UserPrivateKey(privateKey: testKey, version: "A")
        let keyPair = UserKeyPair(publicKey: publicKey, privateKey: privateKey)
        
        XCTAssertTrue(crypto!.checkUserKeyPair(keyPair: keyPair, password: pw))
    }
    
    func testKeypair_fail3() {
        let pw = "Qwer1234!"
        let testKey = "-----BEGIN ENCRYPTED PRIVATE KEY-----\r\n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\r\n-----END ENCRYPTED PRIVATE KEY-----\r\n"
        let publicKey = UserPublicKey(publicKey: "12345", version: "A")
        let privateKey = UserPrivateKey(privateKey: testKey, version: "A")
        let keyPair = UserKeyPair(publicKey: publicKey, privateKey: privateKey)
        
        XCTAssertTrue(crypto!.checkUserKeyPair(keyPair: keyPair, password: pw))
    }
    
    func testKeypair2() {
        let pw = "98h72z51#L"
        let testKey = "-----BEGIN ENCRYPTED PRIVATE KEY-----\nMIIFKzBVBgkqhkiG9w0BBQ0wSDAnBgkqhkiG9w0BBQwwGgQUMpR7aVKVLdBFIVHQ\n+EB1RXZsII0CAicQMB0GCWCGSAFlAwQBKgQQtzvliFu3vXl/PE+8AjPargSCBNBR\nSvkGabK7hMtv2LYpbozaxW5j0DMocoVRPw4T1sSsAJuGKG81WNeLi6ORxY9m/lEF\n532odUAKPkFVJ8jfViiQ09oV9QAUzJtBxIb/JrxCdIG5xAUrwXsXrelf88W9hfHk\nE+gom68QOuQBfeB4ag5V9Zl8cv0Frzrozqmei1hBd1qKutUwwWS0bNWksKHLPS2k\naRNfV9wrOpEmNxiZwWPIzg5xaF9NFNzj8h1rlXwThbXLvuVV6FcH4hLs7uqmrHF3\nmxUVEtS3zDHUdkqH5GDp3RIqs+7w2pcCqTiD5ulrDkNHbUcVwBfXhmN372wIDgxs\nlrMO1s7H3AADI5y9gH1Nq7qZUiV3iRFURhlsQHKnX0+Au216lOC3wfZUivt3v9Vq\n7s6td9wViJegWk6kLCqXPWRapflKaDzbH8JP7cZtrRIOug5NJBMY8BGWSR/RpAja\nrHppcT+g5NbptirY/IJXJxwmYVWSCMQk5fBU/ckuK43wAk1f0dhVrpjYlRK4MR3u\njgmFM37VNjcr7W3jhol3RHS5AJUqhl/Mc1JDXq0xANOs6crbp55ub5cC23xAbcrh\nh1eoeU1WZy0JXCG7W14vrT3DurNJYtolHbhnYQvSM2LIzuHQnndqoJpAvRgIRT9W\nVPTsy9Fk00jUG61zj2dAxEc3DL034DKubTELWksJHHICMPoWcR8vJPLZzoXvvxJ4\nPb4WZKbvIDjMn/06BsgwKiPSGpMEkINbQC2tYRVtXH2971JOjW41ARxObADL0JYi\nNoEsDgUtEXYB2juMMkhPR12QHOASiEynQKLsniwyMzWNT6i/XMjFySNyaA+qO8T6\n2YEr4ynWyE7z9G0gkn6SM56slQ7wH5kaxfNEVw7+PwAHO0PKYUntw2LI4ICyyr1A\nYKYOKvWalgRHX/YRE5KSwjEvlcPKWjS9BDgmL9Cj2lzl/9TOGbjl4gChkH5bEcGz\nIPYtDw+O1qLQQUKB6dKLy32R2i70B2WJ0ILgVitPYdeW6BwikzxIJYSd/Bh+7yqJ\n53SNQdYIdY24SwHN7Z3RM86QapMq2p0PUBhggNnTqwqKrz8xOItWAEv5EQKDd/gD\nZ+xGaoNvv780i0ndUWCuD5B49TbhF3iEblOfh6/C4hp4ZMy7MsgMWlVGw4kpSIcQ\n0XAc2VcDzWcDSb20+L/GChk8/RfnWLioOfIT2G8Rs55LW4lOmSzAFiswZON3UNHc\nSwqBr4geHr8w1ePdYZUmU6sX+eyj+4SCRiSM0y46WdJG1KY50/8XNiHP3vnJmPna\nRHNrMcYV9KTtmIvH3NQ5HmTCOGlv7fjhsxSGV2mx1VT27a7Sb+o9cMRTGWsqXZ4W\ns0rEd2T0Nx3JQ1183XiOBGWudtUMKHH5gbKFshwKORsdAksj88TTEkonTm3zVmAM\nnHur4w/lkpkqEbvuQWXRb2LJbGwCVDnEurBlrTt3wqNdUtxC9vnTnQzUEr0o3tbl\nRsrGFUvTRFks+/+4nNvr25M0bWMEuhwrZgHDmkK11OFmRBui22V1dRiCefrCMSrt\n5A8iRHRbXg4R2TEWplurC6JC6uJVRsCOLX4ZnjZ1aqcyobWiSXKXQq0AVMBoHTTc\nNcqziCv5MEhBmm8uYJL3nT0x7mFsvUEB3oJTajGCog==\n-----END ENCRYPTED PRIVATE KEY-----\n"
        let publicKey = UserPublicKey(publicKey: "12345", version: "A")
        let privateKey = UserPrivateKey(privateKey: testKey, version: "A")
        let keyPair = UserKeyPair(publicKey: publicKey, privateKey: privateKey)
        
        XCTAssertTrue(crypto!.checkUserKeyPair(keyPair: keyPair, password: pw))
    }
    
    func testKeypair3() {
        let pw = "98h72z51#L"
        let testKey = "-----BEGIN ENCRYPTED PRIVATE KEY-----\nMIIFKzBVBgkqhkiG9w0BBQ0wSDAnBgkqhkiG9w0BBQwwGgQU6IyO/cuhof4aXNNi\nMDlNvaW6HJMCAicQMB0GCWCGSAFlAwQBKgQQfYbezIuXH3HZTXSTYqLqsQSCBNCw\nJCkmA2r0s+JobI/wJuuF0sJxO9++PV/RTqlkFFRxhNFuZzRIoJVrC0VPbYyx9lmm\nRyJm/ShHwTZqlkrNhci0UAWyqoIi55TX6p2UmlS5vHseWX9uiC2WnT9zIJfIeobo\nGHgZUrzJxUhgNGNacEolu/NFTtfVR0Wh9l8ExDS8WkZAcryp9G6AiF0D2+GmvzVo\nF/rboq23RjZwY1tQa2MeY59K/jH8rLisM9Sls3S6+gpPoG79jaSrY0j6dt/b0iex\nNjhhR46JGrq/aWvomjvb7oVXle3/ydBqwo/shPXujYy11rCU07lxw4gev6cRxv3C\nuavvTqiVJ/gy5KiIxWePeCq7aKC/KOdafaOF0r2jlYoSuZs/9wsjwNHfllTSHX4Y\nBH6NpzLyREhlmJYQyS7qmtWlalgPUGM0VfcrxAqlgb9tYQ2ygpoPDM7ZvK9Vx0Zc\nm0YZUFHXNsEhvaKdWDhA8yt+2d//AqNvYZAY4LiV0jEF5cpb1h0sTuW55twkoXWu\nvsJChwtMVAUEcaU7v9rOH9RjfcuJEWjgswBv0AGQOa21QzAD2wVAyHLxDbA2aDSQ\nELLBokOA+gTT2sRr/pZuRC6QNntWU0mq/YP+jMAIWQRCtK0IDrGtHf4tNok3JhzH\nz+1qarj563t6uY81DfC0Mwl8gMiMIBuD9dZi31UZ5SHNHMqVsZqml4tmwaA13G9Z\nEt6gHL+iX9IwYBbxeMi+ZS4+fWLRsU46gRBiTLzr+SgOGxFLVSPZ65CPTempbPbb\nDgX+u6NmmDVU0Q+t8anXMXDAOiu1U02/UjXSPmbLbbDU6/nnX2TBM6CXnAubOI1A\nb+asA3zBMz1UNDPDSXrfNJ43HQ9C/CEx7GcdCmpNvm5G9FEWuTfBMMYPf8WR3USC\nKAwz2ePFBzcdts0/A4yxX1A/OQlhg4XR5MVNHqQKJkoJuQ0q8HWX0KnD5hOByDUo\nVRsmG6iAsX1QqPo3GHa8HfmC+Ps6QbmILsnL40Xy7PbJtdvUA40jVedKPLW7wMMa\ny2ofHhvsFMlrSWqyrinEE49ygJ4POUjXX1+W4e/ZVam3i2EcSuwjLvs2lPfPmn2E\n94aAsF6ubzLjdFiSp9aL6ekMkYS16k+WaGQRPJPVyISz7pZlQ8uPxgl1Jd4GKctY\ntLn7PLfoEeExwvLYziQdWDRcDd0JY/CHzcLEgSwE9h0PnXqEqGrmZQZm2QlcvZyw\nmDmLBISshmpkh2QfmbCV0AapLN4MMuL4LJGGnpm4gJYyPLB5lnH244HX67AVc76W\n7JABlNXUi+9e39UO+1g2V0QA39TjGtEBKrps/ayW6IgdsXlqGse7khOZFK7FNQQh\nTFgRoN0GNHDR0p7LJuudnBaWrivHl0Cb8/MIHhYTRRmmziWPKcEHmqk+9bhhmi8G\n+aUdxE5fuaq+057J3TRMbekpGFyHGENz49WuqahPi+wUgn/borLiMXluASB8RFPc\ni6d4PBF1tJvT0qawF+mvCsKz4SUk8oLXLsKlanK7Pb0Jet8N1G56ut17JBIVK2B5\nBK6GwgCJSDYDrALZ8aRLtuOuHiOHZtxAuFatoFb1SaYeLJ0JGxSZhkPH2bnvR4+h\nosCTMS/sUU41BGbOT+SCDTUU4Jxgh/f4gajF6omM4w==\n-----END ENCRYPTED PRIVATE KEY-----\n"
        let publicKey = UserPublicKey(publicKey: "12345", version: "A")
        let privateKey = UserPrivateKey(privateKey: testKey, version: "A")
        let keyPair = UserKeyPair(publicKey: publicKey, privateKey: privateKey)
        
        XCTAssertTrue(crypto!.checkUserKeyPair(keyPair: keyPair, password: pw))
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
    
    func testDecryptFileKey_withCorrectPassword_returnsPlainFileKey() {
        let password = "Pass1234!"
        let encryptedFileKey = testFileReader?.readEncryptedFileKey(fileName: "data/enc_file_key.json")
        let userPrivateKey = testFileReader?.readPrivateKey(fileName: "data/private_key.json")
        
        let plainFileKey = try? crypto!.decryptFileKey(fileKey: encryptedFileKey!, privateKey: userPrivateKey!, password: password)
        
        XCTAssertNotNil(plainFileKey)
        XCTAssertEqual(plainFileKey!.iv, encryptedFileKey!.iv)
        XCTAssertEqual(plainFileKey!.tag, encryptedFileKey!.tag)
        XCTAssertEqual(plainFileKey!.version, encryptedFileKey!.version)
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
    
    func testEncryptFileKey_canDecryptEncryptedKey() {
        let password = "Pass1234!"
        let plainFileKey = testFileReader?.readPlainFileKey(fileName: "data/plain_file_key.json")
        let userPublicKey = testFileReader?.readPublicKey(fileName: "data/public_key.json")
        let userPrivateKey = testFileReader?.readPrivateKey(fileName: "data/private_key.json")
        
        let encryptedKey = try? crypto!.encryptFileKey(fileKey: plainFileKey!, publicKey: userPublicKey!)
        
        let decryptedKey = try? crypto!.decryptFileKey(fileKey: encryptedKey!, privateKey: userPrivateKey!, password: password)
        
        XCTAssertNotNil(decryptedKey)
        XCTAssertEqual(decryptedKey!.key, plainFileKey!.key)
    }
    
    // MARK: Generate FileKey
    
    func testGenerateFileKey_withUnknownVersion_throwsError() {
        let expectedError = CryptoError.generate("Unknown key pair version")
        
        XCTAssertThrowsError(try crypto!.generateFileKey(version: "Z")) { (error) -> Void in
            XCTAssertEqual(error as? CryptoError, expectedError)
        }
    }
    
    func testGenerateFileKey_returnsPlainFileKey() {
        let base64EncodedAES256KeyCharacterCount = 44
        
        let plainFileKey = try? crypto!.generateFileKey()
        
        XCTAssertNotNil(plainFileKey)
        XCTAssertNotNil(plainFileKey!.key)
        XCTAssert(plainFileKey!.key.count == base64EncodedAES256KeyCharacterCount)
        XCTAssertEqual(plainFileKey!.version, CryptoConstants.DEFAULT_VERSION)
        XCTAssertNil(plainFileKey!.iv)
        XCTAssertNil(plainFileKey!.tag)
    }
}
