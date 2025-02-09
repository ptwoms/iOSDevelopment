//
//  PMDataSecurityViewModel.swift
//  Examples
//
//  Created by Pyae Phyo Myint Soe on 6/2/25.
//

import Foundation
import PMDataSecurity

final class PMDataSecurityViewModel {

    func generateRandom() -> Data {
        return (try? PMSecureRandom().generateData(count: 10)) ?? Data()
    }

    func generateHash() {
        let dataToHash = "Hello World"
        _ = dataToHash.pm_digest(algorithm: .md5)
        _ = dataToHash.pm_digest(algorithm: .sha1)
        _ = dataToHash.pm_digest(algorithm: .sha2_256)
        _ = dataToHash.pm_digest(algorithm: .sha2_384)
        _ = dataToHash.pm_digest(algorithm: .sha2_384)
        _ = dataToHash.pm_digest(algorithm: .sha2_512)
        _ = dataToHash.pm_digest(algorithm: .sha3_224)
        _ = dataToHash.pm_digest(algorithm: .sha3_256)
        _ = dataToHash.pm_digest(algorithm: .sha3_384)
        _ = dataToHash.pm_digest(algorithm: .sha3_512)
    }

    func aesEncryption() {
        
    }
}
