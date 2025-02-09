//
//  PMDigest.swift
//  PMDataSecurity
//
//  Created by Pyae Phyo Myint Soe on 2/2/25.
//
import CryptoKit

public final class PMDigest {
    public enum Algorithm {
        // md5 and sha1 are not secure and use more secure functions like SHA256 and above unless you really need it for backward compatibility reasons
        case md5
        case sha1

        case sha2_256
        case sha2_384
        case sha2_512

        case sha3_224
        case sha3_256
        case sha3_384
        case sha3_512

        case shake_128(length: Int = 128)
        case shake_256(length: Int = 256)
    }

    public static func calcuateHash(algorithm: Algorithm, data: Data) -> Data {
        switch algorithm {
        case .md5:
            return Insecure.MD5.hash(data: data).withUnsafeBytes { Data($0) }
        case .sha1:
            return Insecure.SHA1.hash(data: data).withUnsafeBytes { Data($0) }
        case .sha2_256:
            return SHA256.hash(data: data).withUnsafeBytes { Data($0) }
        case .sha2_384:
            return SHA384.hash(data: data).withUnsafeBytes { Data($0) }
        case .sha2_512:
            return SHA512.hash(data: data).withUnsafeBytes { Data($0) }
        case .sha3_224:
            return PMSHAKE.hash(data: data, digest: ._224)
        case .sha3_256:
            return PMSHAKE.hash(data: data, digest: ._256)
        case .sha3_384:
            return PMSHAKE.hash(data: data, digest: ._384)
        case .sha3_512:
            return PMSHAKE.hash(data: data, digest: ._512)
        case .shake_128(length: let length):
            return PMSHAKE.shake(data: data, digest: ._128(outLength: length))
        case .shake_256(length: let length):
            return PMSHAKE.shake(data: data, digest: ._256(outLength: length))
        }
    }
}

// MARK: - Hash extensions
public extension Data {
    func pm_digest(algorithm: PMDigest.Algorithm) -> Data {
        PMDigest.calcuateHash(algorithm: algorithm, data: self)
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
