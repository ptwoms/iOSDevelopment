//
//  PMSHAKE.swift
//  PMDataSecurity
//
//  Created by Pyae Phyo Myint Soe on 2/2/25.
//
import Foundation
import PMDataSecurityCLibrary

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
            self.digestLength = digestLength
            self.rateSize = 200 - (digestLength << 1)
            self.curPosition = 0
            self.outputLength = outputLength
            self.suffix = suffix
        }
    }

    private enum PMContext {
        case sha3, shake
    }

    public enum ShakeDigestLength {
        case _128(outputByteLength: Int = 16), _256(outputByteLength: Int = 32)

        var length: Int {
            switch self {
            case ._128:
                return 16
            case ._256:
                return 32

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

    public init(sha3: PMDigest.HashFunction) {
        self.generationContext = .sha3
        self.stateContext = SHAKEContext(digestLength: sha3.length, outputLength: sha3.length, suffix: UInt64(0x06))
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

    static func hash(data: Data, digest: PMDigest.HashFunction) -> Data {
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
