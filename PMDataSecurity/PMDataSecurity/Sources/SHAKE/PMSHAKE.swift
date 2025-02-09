//
//  PMSHAKE.swift
//  PMDataSecurity
//
//  Created by Pyae Phyo Myint Soe on 2/2/25.
//
import Foundation
import PMDataSecurityCLibrary

protocol PMSHAKEOutputLength {
    var length: Int { get }
    var outputLength: Int { get }
}

public struct PMSHAKE {
    private struct SHAKEContext {
        var intenalStateArray: [UInt64]
        let digestLength: Int
        let outputLength: Int
        let rateSize: Int
        var curPosition: Int
        let suffix: UInt64

        init(digestLength: Int, outputLength: Int, suffix: UInt64) {
            self.intenalStateArray = [UInt64](repeating: 0, count: 25)
            let lengthInBytes = digestLength >> 3
            self.digestLength = lengthInBytes
            self.rateSize = 200 - (lengthInBytes << 1)
            self.curPosition = 0
            self.outputLength = outputLength >> 3
            self.suffix = suffix
        }
    }

    private enum PMContext {
        case sha3, shake
    }

    public enum DigestLength: PMSHAKEOutputLength {
        case _224, _256, _384, _512

        var length: Int {
            switch self {
            case ._224:
                return 224
            case ._256:
                return 256
            case ._384:
                return 384
            case ._512:
                return 512
            }
        }

        var outputLength: Int {
            length
        }
    }

    public enum ShakeDigestLength: PMSHAKEOutputLength {
        case _128(outLength: Int = 128), _256(outLength: Int = 256)

        var length: Int {
            switch self {
            case ._128:
                return 128
            case ._256:
                return 256

            }
        }

        var outputLength: Int {
            switch self {
            case ._128(let outLength):
                return outLength
            case ._256(let outLength):
                return outLength
            }
        }
    }

    private var stateContext: SHAKEContext
    private let generationContext: PMContext

    public init(sha3: DigestLength) {
        self.generationContext = .sha3
        self.stateContext = SHAKEContext(digestLength: sha3.length, outputLength: sha3.outputLength, suffix: UInt64(0x06))
    }

    public init(shake: ShakeDigestLength) {
        self.generationContext = .shake
        self.stateContext = SHAKEContext(digestLength: shake.length, outputLength: shake.outputLength, suffix: UInt64(0x1F))
    }

    private let KECCAKF_ROUNDS = 24

    mutating func update(data: Data) {
        data.withUnsafeBytes {
            let newPos = pm_update_data(
                $0.baseAddress,
                Int32(data.count),
                &stateContext.intenalStateArray,
                Int32(KECCAKF_ROUNDS),
                Int32(stateContext.curPosition),
                Int32(stateContext.rateSize)
             )
             stateContext.curPosition = Int(newPos)
        }
//       // C codes are faster than Swift and moved to C
//        var curPos = stateContext.curPosition
//        data.forEach {
//            stateContext.intenalStateArray[curPos >> 3] ^= UInt64($0) << ((curPos & 0b111) << 3)
//            curPos += 1
//            if curPos >= stateContext.rateSize {
//                keccakf(&stateContext.intenalStateArray, Int32(KECCAKF_ROUNDS))
//                curPos = 0
//            }
//        }
//        stateContext.curPosition = curPos
    }

    mutating func finalize() -> Data {
        stateContext
            .intenalStateArray[stateContext.curPosition >> 3] ^= stateContext.suffix << ((stateContext.curPosition & 0b111) << 3)
        stateContext.intenalStateArray[(stateContext.rateSize - 1) >> 3] ^= UInt64(0x80) << (((stateContext.rateSize - 1) & 0b111) << 3)
        pm_keccakf(&stateContext.intenalStateArray, Int32(KECCAKF_ROUNDS))
        var finalDigest = [UInt8](repeating: 0, count: stateContext.outputLength)
        if stateContext.outputLength < stateContext.rateSize {
            (0..<stateContext.outputLength).forEach { index in
                finalDigest[index] = UInt8((stateContext.intenalStateArray[index >> 3] >> ((index & 0b111) << 3)) & 0xFF)
            }
        } else {
            var j = 0
            for i in 0..<stateContext.outputLength {
                if j >= stateContext.rateSize {
                    pm_keccakf(&stateContext.intenalStateArray, Int32(KECCAKF_ROUNDS))
                    j = 0
                }
                finalDigest[i] = UInt8((stateContext.intenalStateArray[j >> 3] >> ((j & 0b111) << 3)) & 0xFF)
                j += 1
            }
        }
        return Data(finalDigest)
    }

    static func hash(data: Data, digest: DigestLength) -> Data {
        var sha3 = Self.init(sha3: digest)
        sha3.update(data: data)
        return sha3.finalize()
    }

    static func shake(data: Data, digest: ShakeDigestLength) -> Data {
        var shakeObj = Self.init(shake: digest)
        shakeObj.update(data: data)
        return shakeObj.finalize()
    }
}
