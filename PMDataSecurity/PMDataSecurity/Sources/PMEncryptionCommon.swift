//
//  PMEncryptionCommon.swift
//  PMDataSecurity
//
//  Created by Pyae Phyo Myint Soe on 31/1/25.
//
import Foundation
import CryptoKit
import CommonCrypto

// MARK: Generic Error
public struct PMCFError: Equatable, CustomStringConvertible {
    let domain: String
    let code: Int
    let errDescription: String

    public init(domain: String, code: Int, description: String) {
        self.domain = domain
        self.code = code
        self.errDescription = description
    }

    public var description: String {
        "\(domain) - (\(code)): \(errDescription)"
    }
}

extension CFError {
    var pmCFError: PMCFError? {
        let domain = CFErrorGetDomain(self) as String? ?? "-"
        let code = CFErrorGetCode(self) as Int
        let localizedDescription = CFErrorCopyDescription(self) as String? ?? "-"
        return PMCFError(domain: domain, code: code, description: localizedDescription)
    }
}

// MARK: - Encryption Common errors
public enum PMEncryptionError: Error, Equatable {
    case noError
    case invalidKey
    case invalidKeyLength
    case invalidIVLength
    case invalidData
    case invalidDataLength
    case generateRandomFailed
    case parameterError
    case memoryFailure
    case wrongPadding
    case copyPublicKeyFailed
    case keyGeneration(PMCFError?)
    case encryptionFailed(PMCFError?)
    case decryptionFailed(PMCFError?)
    case signFailed(PMCFError?)
    case algorithmNotSupported
    case verifyFailed(PMCFError?)
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
