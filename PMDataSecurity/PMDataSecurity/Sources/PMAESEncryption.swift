//
//  PMAESEncryption.swift
//  PMDataSecurity
//
//  Created by Pyae Phyo Myint Soe on 31/1/25.
//
import CryptoKit
import CommonCrypto

class PMAESEncryption: PMSymmetricEncryptionProtocol {
    enum Padding: Int {
        case pkcs7, none

        var ccPadding: CCPadding {
            switch self {
            case .pkcs7:
                return CCPadding(ccPKCS7Padding)
            case .none:
                return CCPadding(ccNoPadding)
            }
        }
    }
    enum Mode {
        case cbc(Padding), gcm
    }

    private let opMode: Mode
    public init(mode: Mode = .gcm) throws {
        self.opMode = mode
    }

    func encrypt(key: Data, data: Data, iv nonce: Data? = nil) throws -> PMEncryptedData {
        let ivData: Data
        if let nonce {
            ivData = nonce
        } else {
            ivData = try PMSecureRandom().generateData(count: key.count)
        }
        return try encrypt(mode: self.opMode, key: key, data: data, iv: ivData)
    }

    func decrypt(key: Data, data: PMEncryptedData) throws -> Data {
        return try decrypt(mode: self.opMode, key: key, data: data)
    }

    private func encrypt(mode: Mode, key: Data, data: Data, iv ivData: Data) throws -> PMEncryptedData {
        switch mode {
        case .cbc(let padding):
            let encrypted = try aesCBCOperation(
                operation: CCOperation(kCCEncrypt), option: padding.ccPadding, data: data, key: key, iv: ivData)
            return PMEncryptedData(cipherText: encrypted, iv: ivData, tag: nil)
        case .gcm:
            let symKey = SymmetricKey(data: key)
            let encrypted = try AES.GCM.seal(data, using: symKey, nonce: .init(data: ivData))
            return PMEncryptedData(cipherText: encrypted.ciphertext, iv: Data(encrypted.nonce), tag: encrypted.tag)
        }
    }

    private func decrypt(mode: Mode, key: Data, data: PMEncryptedData) throws -> Data {
        switch mode {
        case .cbc(let padding):
            return try aesCBCOperation(operation: CCOperation(kCCDecrypt), option: padding.ccPadding, data: data.cipherText, key: key, iv: data.iv)
        case .gcm:
            guard let tag = data.tag else {
                throw PMEncryptionError.invalidData
            }
            let symKey = SymmetricKey(data: key)
            let sealedBox = try AES.GCM.SealedBox(nonce: AES.GCM.Nonce(data: data.iv), ciphertext: data.cipherText, tag: tag)
            return try AES.GCM.open(sealedBox, using: symKey)
        }
    }

    private func aesCBCOperation(operation: CCOperation, option: CCOptions, data: Data, key: Data, iv ivData: Data) throws -> Data {
        let keyArr = [UInt8](key)
        let inDataArr = [UInt8](data)
        let ivArr = [UInt8](ivData)
        let outLength = data.count + kCCBlockSizeAES128
        var outDataArr = Data(count: outLength)
        var bytesProcessed: Int = 0
        let status = outDataArr.withUnsafeMutableBytes { outBytes in
            CCCrypt(operation, CCAlgorithm(kCCAlgorithmAES), option,
                    keyArr, keyArr.count,
                    ivArr,
                    inDataArr, inDataArr.count,
                    outBytes.baseAddress, outLength,
                    &bytesProcessed)
        }

        if status == kCCSuccess {
            return outDataArr.prefix(bytesProcessed)
        }
        throw status.error
    }
}
