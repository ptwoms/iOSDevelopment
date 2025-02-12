//
//  PMRSAServiceTests.swift
//  PMDataSecurityTests
//
//  Created by Pyae Phyo Myint Soe on 11/2/25.
//

import Testing
@testable import PMDataSecurity

struct PMRSAServiceSimpleTests {
    private var rsaService = PMRSAService()
    private var publicKey: SecKey!
    private var privateKey: SecKey!

    init() async throws {
        (privateKey, publicKey) = try rsaService.generateKeyPair(size: 2048)
    }

    @Test("Test RSA Encryption Decryption")
    func testEncryptDecrypt() {
        let message = "Hello, World!".data(using: .utf8)!
        do {
            // Encrypt with public key
            let encrypted = try rsaService.encrypt(data: message, with: publicKey, algorithm: .oaepAESGCM(.sha512))
            #expect(encrypted.count > 0)
            let decrypted = try rsaService.decrypt(data: encrypted, with: privateKey, algorithm: .oaepAESGCM(.sha512))
            #expect(decrypted == message)
        } catch {
            Issue.record(error)
        }
    }

    @Test("Test RSA Signing and Verification")
    func testSignAndVerify() {
        let message = "Sign this message".data(using: .utf8)!
        do {
            let signed = try rsaService.sign(message: message, with: privateKey, algorithm: .pSS(.sha512))
            #expect(!signed.isEmpty)
            let isValid = try rsaService.verify(
                message: message,
                signature: signed,
                with: publicKey,
                algorithm: .pSS(.sha512)
            )
            #expect(isValid)
        } catch {
            Issue.record(error)
        }
    }
}
