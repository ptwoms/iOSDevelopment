//
//  PMRSAService.swift
//  PMDataSecurity
//
//  Created by Pyae Phyo Myint Soe on 10/2/25.
//
import Security

public class PMRSAService {
    public init() {
        /* do nothing */
    }

    public enum EncryptionAlgorithm {
        case raw, pkcs1
        case oaep(PMDigest.SHAAlgorithm)
        case oaepAESGCM(PMDigest.SHAAlgorithm)

        var secAlgorithm: SecKeyAlgorithm {
            return switch self {
            case .raw: .rsaEncryptionRaw
            case .pkcs1: .rsaEncryptionPKCS1
            case .oaep(let digest):
                switch digest {
                case .sha1: .rsaEncryptionOAEPSHA1
                case .sha224: .rsaEncryptionOAEPSHA224
                case .sha256: .rsaEncryptionOAEPSHA256
                case .sha384: .rsaEncryptionOAEPSHA384
                case .sha512: .rsaEncryptionOAEPSHA512
                }
            case .oaepAESGCM(let digest):
                switch digest {
                case .sha1: .rsaEncryptionOAEPSHA1AESGCM
                case .sha224: .rsaEncryptionOAEPSHA224AESGCM
                case .sha256: .rsaEncryptionOAEPSHA256AESGCM
                case .sha384: .rsaEncryptionOAEPSHA384AESGCM
                case .sha512: .rsaEncryptionOAEPSHA512AESGCM
                }
            }
        }

        var paddingSize: Int {
            return switch self {
            case .raw: 0
            case .pkcs1: 11
            case .oaep(let length), .oaepAESGCM(let length): (length.digestLength << 1) + 2 // (size in bytes * 2) + 2
            }
        }
    }

    public enum SignAlgorithm: Equatable {
        public enum Message: Equatable {
            case pKCS1v15(PMDigest.SHAAlgorithm)
            case pSS(PMDigest.SHAAlgorithm)

            var secAlgorithm: SecKeyAlgorithm {
                return switch self {
                case .pKCS1v15(let length):
                    switch length {
                    case .sha1: .rsaSignatureMessagePKCS1v15SHA1
                    case .sha224: .rsaSignatureMessagePKCS1v15SHA224
                    case .sha256: .rsaSignatureMessagePKCS1v15SHA256
                    case .sha384: .rsaSignatureMessagePKCS1v15SHA384
                    case .sha512: .rsaSignatureMessagePKCS1v15SHA512
                    }
                case .pSS(let length):
                    switch length {
                    case .sha1: .rsaSignatureMessagePSSSHA1
                    case .sha224: .rsaSignatureMessagePSSSHA224
                    case .sha256: .rsaSignatureMessagePSSSHA256
                    case .sha384: .rsaSignatureMessagePSSSHA384
                    case .sha512: .rsaSignatureMessagePSSSHA512
                    }
                }
            }
        }

        public enum Digest: Equatable {
            case none
            case pKCS1v15(PMDigest.SHAAlgorithm)
            case pSS(PMDigest.SHAAlgorithm)

            static let supportedRawLengths = Set([
                PMDigest.HashFunction.md5.length,
                PMDigest.HashFunction.sha(.sha1).length,
                PMDigest.HashFunction.sha(.sha224).length,
                PMDigest.HashFunction.sha(.sha256).length,
                PMDigest.HashFunction.sha(.sha384).length,
                PMDigest.HashFunction.sha(.sha512).length,
                PMDigest.HashFunction.md5.length + PMDigest.HashFunction.sha(.sha1).length
            ])

            var secAlgorithm: SecKeyAlgorithm {
                return switch self {
                case .none: .rsaSignatureDigestPKCS1v15Raw
                case .pKCS1v15(let length):
                    switch length {
                    case .sha1: .rsaSignatureDigestPKCS1v15SHA1
                    case .sha224: .rsaSignatureDigestPKCS1v15SHA224
                    case .sha256: .rsaSignatureDigestPKCS1v15SHA256
                    case .sha384: .rsaSignatureDigestPKCS1v15SHA384
                    case .sha512: .rsaSignatureDigestPKCS1v15SHA512
                    }
                case .pSS(let length):
                    switch length {
                    case .sha1: .rsaSignatureDigestPSSSHA1
                    case .sha224: .rsaSignatureDigestPSSSHA224
                    case .sha256: .rsaSignatureDigestPSSSHA256
                    case .sha384: .rsaSignatureDigestPSSSHA384
                    case .sha512: .rsaSignatureDigestPSSSHA512
                    }
                }
            }
        }

    }

    @inline(__always) private func maxMessageSize(for key: SecKey, algorithm: EncryptionAlgorithm) -> Int {
        return SecKeyGetBlockSize(key) - algorithm.paddingSize
    }

    // MARK: Key Generation
    public func generateKeyPair(size keySize: Int) throws -> (privateKey: SecKey, publicKey: SecKey) {
        let attributes: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            kSecAttrKeySizeInBits as String: keySize,
            kSecPrivateKeyAttrs as String: [
                kSecAttrIsPermanent as String: false
            ]
        ]
        var error: Unmanaged<CFError>?
        guard let privateKey = SecKeyCreateRandomKey(attributes as CFDictionary, &error) else {
            throw PMEncryptionError.keyGeneration(error?.takeUnretainedValue().pmCFError)
        }
        guard let publicKey = SecKeyCopyPublicKey(privateKey) else {
            throw PMEncryptionError.copyPublicKeyFailed
        }
        return (privateKey, publicKey)
    }

    // MARK: Encrypt/Decrypt
    public func encrypt(data: Data, with pubicKey: SecKey, algorithm: EncryptionAlgorithm) throws -> Data {
        guard data.count <= maxMessageSize(for: pubicKey, algorithm: algorithm) else {
            throw PMEncryptionError.invalidDataLength
        }
        var error: Unmanaged<CFError>?
        guard let encryptedData = SecKeyCreateEncryptedData(pubicKey, algorithm.secAlgorithm, data as CFData, &error) else {
            throw PMEncryptionError.encryptionFailed(error?.takeRetainedValue().pmCFError)
        }
        return encryptedData as Data
    }

    public func decrypt(data: Data, with privateKey: SecKey, algorithm: EncryptionAlgorithm) throws -> Data {
        var error: Unmanaged<CFError>?
        guard let decryptedData = SecKeyCreateDecryptedData(privateKey, algorithm.secAlgorithm, data as CFData, &error) else {
            throw PMEncryptionError.decryptionFailed(error?.takeRetainedValue().pmCFError)
        }
        return decryptedData as Data
    }

    // MARK: - Sign
    public func sign(raw rawData: Data, with privateKey: SecKey) throws -> Data {
        try validateAndSign(
            data: rawData,
            with: privateKey,
            algorithm: .rsaSignatureRaw) { data in
                guard data.count == SecKeyGetBlockSize(privateKey) else {
                    throw PMEncryptionError.invalidDataLength
                }
            }
    }

    public func sign(message: Data, with privateKey: SecKey, algorithm: SignAlgorithm.Message) throws -> Data {
        try validateAndSign(
            data: message,
            with: privateKey,
            algorithm: algorithm.secAlgorithm) { _ in
                /* no validation */
            }
    }

    public func sign(digest: Data, with privateKey: SecKey, algorithm: SignAlgorithm.Digest) throws -> Data {
        try validateAndSign(
            data: digest,
            with: privateKey,
            algorithm: algorithm.secAlgorithm) { data in
                switch algorithm {
                case .none:
                    if !SignAlgorithm.Digest.supportedRawLengths.contains(data.count) {
                        throw PMEncryptionError.invalidDataLength
                    }
                case .pKCS1v15(let length), .pSS(let length):
                    if length.digestLength != data.count {
                        throw PMEncryptionError.invalidDataLength
                    }
                }
            }
    }

    private func validateAndSign(data: Data, with privateKey: SecKey, algorithm: SecKeyAlgorithm, validation: (Data) throws -> Void) throws -> Data {
        guard SecKeyIsAlgorithmSupported(privateKey, .sign, algorithm) else {
            throw PMEncryptionError.algorithmNotSupported
        }
        try validation(data)
        var error: Unmanaged<CFError>?
        guard let signature = SecKeyCreateSignature(privateKey, algorithm, data as CFData, &error) else {
            throw PMEncryptionError.signFailed(error?.takeRetainedValue().pmCFError)
        }
        return signature as Data
    }

    // MARK: - Verify
    public func verify(raw data: Data, signature signedData: Data, with publicKey: SecKey) throws -> Bool {
        try validateAndVerify(
            data: data,
            signature: signedData,
            with: publicKey,
            algorithm: .rsaSignatureRaw) { data in
                guard data.count == SecKeyGetBlockSize(publicKey) else {
                    throw PMEncryptionError.invalidDataLength
                }
            }
    }

    public func verify(message: Data, signature signedData: Data, with publicKey: SecKey, algorithm: SignAlgorithm.Message) throws -> Bool {
        try validateAndVerify(
            data: message,
            signature: signedData,
            with: publicKey,
            algorithm: algorithm.secAlgorithm,
            validation: { _ in /* no validation */ }
        )
    }

    public func verify(digest: Data, signature signedData: Data, with publicKey: SecKey, algorithm: SignAlgorithm.Digest) throws -> Bool {
        try validateAndVerify(
            data: digest,
            signature: signedData,
            with: publicKey,
            algorithm: algorithm.secAlgorithm) { data in
                switch algorithm {
                case .none:
                    if !SignAlgorithm.Digest.supportedRawLengths.contains(data.count) {
                        throw PMEncryptionError.invalidDataLength
                    }
                case .pKCS1v15(let length), .pSS(let length):
                    if length.digestLength != data.count {
                        throw PMEncryptionError.invalidDataLength
                    }
                }
            }
    }

    private func validateAndVerify(data: Data, signature signedData: Data, with publicKey: SecKey, algorithm: SecKeyAlgorithm, validation: (Data) throws -> Void) throws -> Bool {
        guard SecKeyIsAlgorithmSupported(publicKey, .verify, algorithm) else {
            throw PMEncryptionError.algorithmNotSupported
        }
        try validation(data)
        var error: Unmanaged<CFError>?
        let isValid = SecKeyVerifySignature(publicKey, algorithm, data as CFData, signedData as CFData, &error)
        if let error {
            throw PMEncryptionError.verifyFailed(error.takeRetainedValue().pmCFError)
        }
        return isValid
    }
}
