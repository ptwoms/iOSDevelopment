//
//  ViewController.swift
//  ExamplesUIKIt
//
//  Created by Pyae Phyo Myint Soe on 16/1/25.
//

import UIKit
import PMUIKitCommon
import PMPageControl
import Combine

class ViewController: UIViewController {
    private weak var pageControl: PMProgressPageControl?

    private weak var scrollView: PMPageScrollView?
    private var allPages: [UIView] = []
    private let noOfPages: Int = 3
    private var pageCtrlDoneCancellable: AnyCancellable?
    private var pageStartedCancellable: AnyCancellable?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI(in: self.view)
    }

    private func setupUI(in inView: UIView) {
        let scrollView = PMPageScrollView.autoLayoutView()
        scrollView.delegate = self
        inView.add(view: scrollView, insets: .viewMargin(left: 0, bottom: 0, right: 0))
        self.scrollView = scrollView
        scrollView.topAnchor
            .constraint(equalTo: inView.safeAreaLayoutGuide.topAnchor)
            .activate()
        setupPageControl(in: inView)
        scrollView.set(pages: createPages(count: self.noOfPages))
    }

    private func setupPageControl(in inView: UIView) {
        let pageControl = PMProgressPageControl(
            configuration: PMProgressPageControlConfig(
                progressType: .loop
            ),
            colors: PMProgressControlColors(
                background: .blue,
                progress: .purple
            )
        )
        pageControl.backgroundColor = .clear
        pageControl.makeAutoLayout()
        inView
            .add(
                view: pageControl,
                insets: .viewMargin(top: 40, left: 16, right: 16),
                parentSafeArea: true
            )
        pageControl.heightAnchor.constraint(equalToConstant: 8).activate()
        //        pageControl.config = PMProgressPageControlConfig(progressType: .loop)
        pageControl.numberOfPages = self.noOfPages
        pageControl.setCurrent(page: 0)
//        pageCtrlDoneCancellable = pageControl.progressDone
//            .sink { page in
//                Swift.print("Progress Done \(page)")
//            }
        pageStartedCancellable = pageControl.progressStarted
            .sink(receiveValue: { [weak self] page in
                self?.scrollView?.set(currentPage: page, animated: true)
            })
        self.pageControl = pageControl
    }

    private func createPages(count: Int) -> [UIView] {
        (0..<count).map { index in
            let pageView = UIView.autoLayoutView()
            pageView.backgroundColor = .systemBackground
            let label = UILabel.autoLayoutView()
            pageView.add(view: label, insets: .viewMargin(left: 24, right: 24))
            pageView.centerYAnchor
                .constraint(equalTo: label.centerYAnchor)
                .activate()
            label.font = .systemFont(ofSize: 36, weight: .bold)
            label.textColor = .label
            label.textAlignment = .center
            label.text = "\(index)"
            return pageView
        }
    }

    override func viewWillTransition(
        to size: CGSize,
        with coordinator: any UIViewControllerTransitionCoordinator
    ) {
        super.viewWillTransition(to: size, with: coordinator)
//        guard let currentPage = pageControl?.currentPage else {
//            return
//        }
//        coordinator.animate(alongsideTransition: { [weak self] _ in
//            self?.adjustScrollView(for: size, page: currentPage, animated: false)
//        })
    }
}


extension ViewController: UIScrollViewDelegate {
    func scrollViewDidEndDragging(
        _ scrollView: UIScrollView,
        willDecelerate decelerate: Bool
    ) {
        if !decelerate {
            updatePageControl()
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updatePageControl()
    }

    fileprivate func updatePageControl() {
        guard let scrollView else { return }
        let newPage = Int(round(scrollView.contentOffset.x / scrollView.bounds.width))
        if newPage != pageControl?.currentPage {
            pageControl?.setCurrent(page: newPage)
        }
    }
}
