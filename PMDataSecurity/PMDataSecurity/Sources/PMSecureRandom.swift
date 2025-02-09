//
//  PMSecureRandom.swift
//  PMDataSecurity
//
//  Created by Pyae Phyo Myint Soe on 31/1/25.
//

public class PMSecureRandom {

    public init() {
        // do nothing
    }

    public func generateData(count: Int) throws -> Data {
        var bytes = [UInt8](repeating: 0, count: count)
        if SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes) == errSecSuccess {
            return Data(bytes)
        }
        throw PMEncryptionError.generateRandomFailed
    }
}
