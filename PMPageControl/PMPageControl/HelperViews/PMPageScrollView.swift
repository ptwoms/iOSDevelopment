//
//  PMPageScrollView.swift
//  PMPageControl
//
//  Created by Pyae Phyo Myint Soe on 23/1/25.
//

import Foundation
import UIKit
import PMUIKitCommon

// MARK: - Lightweight view to make scrollable pages with views instead of using UIPageViewController
public class PMPageScrollView: UIScrollView {
    private var notifToken: PMNotificationToken?
    private(set) var currentPage: Int = 0
    private var allPages: [UIView] = []

    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.isPagingEnabled = true
        setupNotifications()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.isPagingEnabled = true
        setupNotifications()
    }

    private func setupNotifications() {
        notifToken = NotificationCenter.default
            .observe(name: UIDevice.orientationDidChangeNotification,
                     object: nil,
                     using: { [weak self] notif in
                self?.adjustAfterRotation()
            })
    }

    private func adjustAfterRotation() {
        Task { [weak self] in
            try? await Task.sleep(nanoseconds: 299_000) // wait until rotation animation finished
            Task { @MainActor in
                guard let curPage = self?.currentPage else { return }
                self?.adjustScrollViewContentOffset(forPage: curPage, animated: false, forceSet: true)
            }
        }
    }

    public override var bounds: CGRect {
        didSet {
            if bounds.size != oldValue.size {
                adjustScrollViewContentOffset(forPage: currentPage, animated: false)
            }
        }
    }

    public override var frame: CGRect {
        didSet {
            adjustScrollViewContentOffset(forPage: currentPage, animated: false)
        }
    }

    private func adjustScrollViewContentOffset(forPage page: Int, animated: Bool, forceSet: Bool = false) {
        let newOffset = CGPoint(x: CGFloat(page) * self.bounds.width, y: 0)
        if newOffset != self.contentOffset || forceSet {
            setContentOffset(newOffset, animated: animated)
        }
    }

    public func set(pages: [UIView]) {
        var prePage: UIView?
        removeSubviews()
        pages.forEach { pageView in
            pageView.makeAutoLayout()
            add(view: pageView, insets: .viewMargin(top: 0, bottom: 0))
            if let prePage {
                pageView.leftAnchor
                    .constraint(equalTo: prePage.rightAnchor).activate()
            } else {
                pageView.leftAnchor
                    .constraint(equalTo: self.leftAnchor)
                    .activate()
            }
            pageView.equalSize(to: self)
            prePage = pageView
        }
        prePage?.rightAnchor
            .constraint(equalTo: self.rightAnchor)
            .activate()
        self.allPages = pages
    }

    public func set(currentPage page: Int, animated: Bool) {
        self.currentPage = page
        adjustScrollViewContentOffset(forPage: page, animated: animated)
    }

}
