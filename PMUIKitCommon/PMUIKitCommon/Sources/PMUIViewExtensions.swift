//
//  PMUIViewExtensions.swift
//  PMUIKitCommon
//
//  Created by Pyae Phyo Myint Soe on 14/1/25.
//
import UIKit

// MARK: - View creation
public extension UIView {
    static func autoLayoutView() -> Self {
        let view = Self.init(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    @discardableResult func makeAutoLayout() -> Self {
        translatesAutoresizingMaskIntoConstraints = false
        return self
    }

    func add(
        view: UIView,
        top topView: UIView? = nil,
        bottom: UIView? = nil,
        insets: UIEdgeInsets = .viewMargin(),
        parentSafeArea: Bool = false
    ) {
        self.addSubview(view)
        if let topView {
            view.topAnchor
                .constraint(
                    equalTo: topView.bottomAnchor,
                    constant: insets.top.pmValidPadding)
                .activate()
        } else if insets.top > -CGFloat.greatestFiniteMagnitude {
            view.topAnchor.constraint(
                equalTo: (parentSafeArea ? self.safeAreaLayoutGuide.topAnchor : self.topAnchor),
                constant: insets.top
            ).activate()
        }
        if let bottom {
            bottom.topAnchor
                .constraint(equalTo: view.bottomAnchor, constant: insets.bottom.pmValidPadding)
                .activate()
        } else if insets.bottom > -CGFloat.greatestFiniteMagnitude {
            (parentSafeArea ? self.safeAreaLayoutGuide.bottomAnchor : self.bottomAnchor).constraint(
                equalTo: view.bottomAnchor,
                constant: insets.bottom
            ).activate()
        }
        if insets.left > -CGFloat.greatestFiniteMagnitude {
            (parentSafeArea ? self.safeAreaLayoutGuide.leftAnchor : self.leftAnchor).constraint(
                equalTo: view.leftAnchor,
                constant: -insets.left
            ).activate()
        }
        if insets.right > -CGFloat.greatestFiniteMagnitude {
            (parentSafeArea ? self.safeAreaLayoutGuide.rightAnchor : self.rightAnchor).constraint(
                equalTo: view.rightAnchor,
                constant: insets.right
            ).activate()
        }
    }

    func align(
        left: PMViewSpacingRef? = nil,
        right: PMViewSpacingRef? = nil
    ) {
        if let left, let leftView = left.view {
            leftAnchor
                .constraint(
                    equalTo: leftView.leftAnchor,
                    constant: left.spacing
                ).activate()
        }

        if let right, let rightView = right.view {
            rightAnchor
                .constraint(
                    equalTo: rightView.rightAnchor,
                    constant: right.spacing
                ).activate()
        }
    }

    func equalSize(to view: UIView) {
        self.widthAnchor.constraint(equalTo: view.widthAnchor).activate()
        self.heightAnchor.constraint(equalTo: view.heightAnchor).activate()
    }
}

// MARK: - Common methods
public extension UIView {
    func removeSubviews() {
        subviews.forEach { $0.removeFromSuperview() }
    }
}
