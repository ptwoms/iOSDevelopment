//
//  PMUIGeometryCommon.swift
//  PMUIKitCommon
//
//  Created by Pyae Phyo Myint Soe on 14/1/25.
//
import UIKit

struct PMHorizontalAlignViews {
    weak var left: UIView?
    weak var right: UIView?

    init(left: UIView? = nil, right: UIView? = nil) {
        self.left = left
        self.right = right
    }
}

struct PMVerticalAlignViews {
    weak var top: UIView?
    weak var bottom: UIView?

    init(top: UIView? = nil, bottom: UIView? = nil) {
        self.top = top
        self.bottom = bottom
    }
}

public struct PMViewSpacingRef {
    weak var view: UIView?
    let spacing: CGFloat

    init(view: UIView?, spacing: CGFloat = 0) {
        self.view = view
        self.spacing = spacing
    }
}

public extension CGFloat {
    var pmValidPadding: CGFloat {
        self > -CGFloat.greatestFiniteMagnitude ? self : 0
    }
}

extension UIEdgeInsets {
    public static func viewMargin(
        top: CGFloat = -CGFloat.greatestFiniteMagnitude,
        left: CGFloat = -CGFloat.greatestFiniteMagnitude,
        bottom: CGFloat = -CGFloat.greatestFiniteMagnitude,
        right: CGFloat = -CGFloat.greatestFiniteMagnitude
    ) -> Self {
        UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
    }
}
