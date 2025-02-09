//
//  PMCommonExt.swift
//  PMDataSecurity
//
//  Created by Pyae Phyo Myint Soe on 2/2/25.
//

extension Data {
    var hex: String {
        return map { String(format: "%02hhx", $0) }.joined()
    }

    var base64: String {
        return self.base64EncodedString()
    }

    func format(outFormat: PMCryptoStringFormat) -> String {
        switch outFormat {
        case .hex:
            return self.hex
        case .base64:
            return self.base64
        }
    }
}
