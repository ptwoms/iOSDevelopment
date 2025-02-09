//
//  PMEncryptionCommon.swift
//  PMDataSecurity
//
//  Created by Pyae Phyo Myint Soe on 31/1/25.
//
import Foundation
import CryptoKit
import CommonCrypto

// MARK: - Encryption Common errors
public enum PMEncryptionError: Error {
    case noError
    case invalidKey
    case invalidKeyLength
    case invalidIVLength
    case invalidData
    case generateRandomFailed
    case parameterError
    case memoryFailure
    case wrongPadding
    case general
}

// MARK: - Sym Encryption common
protocol PMSymmetricEncryptionProtocol {
    func encrypt(key: Data, data: Data, iv: Data?) throws -> PMEncryptedData
    func decrypt(key: Data, data: PMEncryptedData) throws -> Data
}

// MARK: - Encrypted data
struct PMEncryptedData {
    let cipherText: Data
    let iv: Data
    let tag: Data?

    var combined: Data {
        iv + cipherText + (tag ?? Data())
    }
}

// MARK: - CCryptoStatus extension
public extension CCCryptorStatus {
    var error: PMEncryptionError {
        switch Int(self) {
        case kCCParamError:
            return .parameterError
        case kCCMemoryFailure:
            return .memoryFailure
        case kCCInvalidKey:
            return .invalidKey
        case kCCKeySizeError:
            return .invalidKeyLength
        case kCCAlignmentError:
            return .wrongPadding
        case kCCSuccess:
            return .noError
        default:
            return .general
        }
    }
}

// MARK: - Crypto operation out format
public enum PMCryptoStringFormat {
    case hex
    case base64
}
