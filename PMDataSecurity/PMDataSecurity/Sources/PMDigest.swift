//
//  PMDigest.swift
//  PMDataSecurity
//
//  Created by Pyae Phyo Myint Soe on 2/2/25.
//
import CryptoKit
import CommonCrypto

public final class PMDigest {
    public enum SHAAlgorithm: Equatable {
        case sha1, sha224, sha256, sha384, sha512

        var digestLength: Int {
            return switch self {
            case .sha1: 20
            case .sha224: 28
            case .sha256: 32
            case .sha384: 48
            case .sha512: 64
            }
        }
    }

    public enum HashFunction: Equatable {
        case md5
        case sha(SHAAlgorithm)

        var length: Int {
            return switch self {
            case .md5: 16
            case .sha(let digest): digest.digestLength
            }
        }
    }

    public enum Algorithm {
        // md5 and sha1 are not secure and use more secure functions like SHA256 and above unless you really need it for backward compatibility reasons
        case md5
        case sha1

        case sha2_224
        case sha2_256
        case sha2_384
        case sha2_512

        case sha3_224
        case sha3_256
        case sha3_384
        case sha3_512

        case shake_128(length: Int = 16)
        case shake_256(length: Int = 32)
    }

    public static func computeHash(algorithm: Algorithm, data: Data) -> Data {
        switch algorithm {
        case .md5:
            return Insecure.MD5.hash(data: data).withUnsafeBytes { Data($0) }
        case .sha1:
            return Insecure.SHA1.hash(data: data).withUnsafeBytes { Data($0) }
        case .sha2_224:
            var hash = [UInt8](repeating: 0, count: Int(CC_SHA224_DIGEST_LENGTH))
            data.withUnsafeBytes {
                _ = CC_SHA224($0.baseAddress, CC_LONG(data.count), &hash)
            }
            return Data(hash)
        case .sha2_256:
            return SHA256.hash(data: data).withUnsafeBytes { Data($0) }
        case .sha2_384:
            return SHA384.hash(data: data).withUnsafeBytes { Data($0) }
        case .sha2_512:
            return SHA512.hash(data: data).withUnsafeBytes { Data($0) }
        case .sha3_224:
            return PMSHAKE.hash(data: data, digest: .sha(.sha224))
        case .sha3_256:
            return PMSHAKE.hash(data: data, digest: .sha(.sha256))
        case .sha3_384:
            return PMSHAKE.hash(data: data, digest: .sha(.sha384))
        case .sha3_512:
            return PMSHAKE.hash(data: data, digest: .sha(.sha512))
        case .shake_128(length: let length):
            return PMSHAKE.shake(data: data, digest: ._128(outputByteLength: length))
        case .shake_256(length: let length):
            return PMSHAKE.shake(data: data, digest: ._256(outputByteLength: length))
        }
    }
}

// MARK: - Hash extensions
public extension Data {
    func pm_digest(algorithm: PMDigest.Algorithm) -> Data {
        PMDigest.computeHash(algorithm: algorithm, data: self)
    }
}

public extension String {
    func pm_digest(algorithm: PMDigest.Algorithm, format: PMCryptoStringFormat = .hex) -> String {
        guard let strData = self.data(using: .utf8) else {
            return ""
        }
        return strData.pm_digest(algorithm: algorithm).format(outFormat: format)
    }
}
