//
//  PMLayoutConstraints.swift
//  PMUIKitCommon
//
//  Created by Pyae Phyo Myint Soe on 14/1/25.
//
import UIKit

public extension NSLayoutConstraint {
    @discardableResult func activate() -> Self {
        isActive = true
        return self
    }
}
