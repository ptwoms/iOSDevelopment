//
//  PMEncryptionTests.swift
//  PMDataSecurityTests
//
//  Created by Pyae Phyo Myint Soe on 31/1/25.
//

import Testing
@testable import PMDataSecurity

struct PMEncryptionTests {
    @Test("Generate Random")
    func genRandom() async throws {
        let secureRandom = PMSecureRandom()
        for count in 0...100 {
            let gen1 = try secureRandom.generateData(count: count)
            #expect(gen1.count == count)
        }
        let gen1 = try secureRandom.generateData(count: 100_000_000)
        #expect(gen1.count == 100_000_000)
    }

    @Test("Testing AES GCM Encryption - 256 bits")
    func aesGCM256() async throws {
        let encWrapper = try PMAESEncryption(mode: .gcm)
        let dataToEnc = "Hello World".data(using: .utf8)
        #expect(dataToEnc != nil)
        let symKey = try PMSecureRandom().generateData(count: 32) // 256-bit key
        let encData = try encWrapper.encrypt(key: symKey, data: dataToEnc!)
        #expect(encData.cipherText.count > 0)
        #expect(encData.tag?.count ?? 0 > 0)
        #expect(encData.iv.count > 0)

        let decrypted = try encWrapper.decrypt(key: symKey, data: encData)
        #expect(
            String(data: decrypted, encoding: .utf8) == String(data: dataToEnc!, encoding: .utf8)
        )
    }

    @Test("Testing AES GCM Encryption - 256 bits - IV (nonce) provided")
    func aesGCM256Nonce() async throws {
        let encWrapper = try PMAESEncryption(mode: .gcm)
        let dataToEnc = "Hello World".data(using: .utf8)
        #expect(dataToEnc != nil)
        let symKey = try PMSecureRandom().generateData(count: 32) // 256-bit key
        let customIV = try PMSecureRandom().generateData(count: 32)
        let encData = try encWrapper.encrypt(key: symKey, data: dataToEnc!, iv: customIV)
        #expect(encData.cipherText.count > 0)
        #expect(encData.tag?.count ?? 0 > 0)
        #expect(encData.iv.count > 0)
        #expect(encData.iv == customIV)

        let decrypted = try encWrapper.decrypt(key: symKey, data: encData)
        #expect(
            String(data: decrypted, encoding: .utf8) == String(data: dataToEnc!, encoding: .utf8)
        )
    }

    @Test("Testing AES GCM Encryption - 128 bits")
    func aesGCM128() async throws {
        let encWrapper = try PMAESEncryption(mode: .gcm)
        let dataToEnc = "Hello World".data(using: .utf8)
        #expect(dataToEnc != nil)
        let symKey = try PMSecureRandom().generateData(count: 16) // 128-bit key
        let encData = try encWrapper.encrypt(key: symKey, data: dataToEnc!)
        #expect(encData.cipherText.count > 0)
        #expect(encData.tag?.count ?? 0 > 0)
        #expect(encData.iv.count > 0)

        let decrypted = try encWrapper.decrypt(key: symKey, data: encData)
        #expect(
            String(data: decrypted, encoding: .utf8) == String(data: dataToEnc!, encoding: .utf8)
        )
    }

    @Test("Testing AES CBC Encryption - 256 bits (PKCS7 padding)")
    func aesCBC256() async throws {
        let encWrapper = try PMAESEncryption(mode: .cbc(.pkcs7))
        let dataToEnc = "Hello World".data(using: .utf8)
        #expect(dataToEnc != nil)
        let symKey = try PMSecureRandom().generateData(count: 32) 
        let encData = try encWrapper.encrypt(key: symKey, data: dataToEnc!)
        #expect(encData.cipherText.count > 0)
        #expect(encData.tag?.count ?? 0 == 0)
        #expect(encData.iv.count > 0)

        let decrypted = try encWrapper.decrypt(key: symKey, data: encData)
        #expect(
            String(data: decrypted, encoding: .utf8) == String(data: dataToEnc!, encoding: .utf8)
        )
    }

    @Test("Testing AES CBC Encryption - 128 bits (PKCS7 padding)")
    func aesCBC128() async throws {
        let encWrapper = try PMAESEncryption(mode: .cbc(.pkcs7))
        let dataToEnc = "Hello World".data(using: .utf8)
        #expect(dataToEnc != nil)
        let symKey = try PMSecureRandom().generateData(count: 16)
        let encData = try encWrapper.encrypt(key: symKey, data: dataToEnc!)
        #expect(encData.cipherText.count > 0)
        #expect(encData.tag?.count ?? 0 == 0)
        #expect(encData.iv.count > 0)

        let decrypted = try encWrapper.decrypt(key: symKey, data: encData)
        #expect(
            String(data: decrypted, encoding: .utf8) == String(data: dataToEnc!, encoding: .utf8)
        )
    }

    @Test("Testing AES CBC Encryption - 256 bits (No Padding)")
    func aesCBCNonePadding() async throws {
        let encWrapper = try PMAESEncryption(mode: .cbc(.none))
        let dataToEnc = "Hello World".data(using: .utf8)
        #expect(dataToEnc != nil)
        let symKey = try PMSecureRandom().generateData(count: 32)
        do {
            _ = try encWrapper.encrypt(key: symKey, data: dataToEnc!)
        } catch {
            #expect(error as! PMEncryptionError == PMEncryptionError.wrongPadding)
        }

        let dataToEncAligned = "Hello World. This is 32 char len".data(using: .utf8)
        let encDataAligned = try encWrapper.encrypt(key: symKey, data: dataToEncAligned!)
        #expect(encDataAligned.cipherText.count > 0)
        #expect(encDataAligned.tag?.count ?? 0 == 0)
        #expect(encDataAligned.iv.count > 0)

        let decrypted = try encWrapper.decrypt(key: symKey, data: encDataAligned)
        #expect(
            String(data: decrypted, encoding: .utf8) == String(data: dataToEncAligned!, encoding: .utf8)
        )
    }

}
