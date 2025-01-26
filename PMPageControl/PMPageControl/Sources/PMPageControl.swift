//
//  PMPageControl.swift
//  PMPageControl
//
//  Created by Pyae Phyo Myint Soe on 14/1/25.
//
import UIKit
import SwiftUI
import Combine

// MARK: - Individual progress shape

public struct PMProgressControlColors : Sendable {
    let background: UIColor
    let progress: UIColor

    public init(background: UIColor, progress: UIColor) {
        self.background = background
        self.progress = progress
    }

    public static let defaultColors = PMProgressControlColors(background: .gray, progress: .darkGray)
}

private class PMProgressPageControlItem: CAShapeLayer {
    private weak var progressLayer: CAShapeLayer?
    private var colors: PMProgressControlColors = .defaultColors {
        didSet {
            self.fillColor = colors.background.cgColor
            self.progressLayer?.fillColor = colors.progress.cgColor
        }
    }
    var progress: CGFloat = 0 {
        didSet {
            progressLayer?.path = UIBezierPath(
                roundedRect: CGRect(
                    origin: .zero,
                    size: .init(
                        width: min(1, abs(progress)) * bounds.width,
                        height: bounds.height
                    )
                ),
                cornerRadius: bounds.height / 2
            ).cgPath
        }
    }
    override var bounds: CGRect {
        didSet {
            updateBounds()
        }
    }
    override var frame: CGRect {
        didSet {
            updateBounds()
        }
    }

    init(colors: PMProgressControlColors = .defaultColors) {
        super.init()
        self.colors = colors
        setup()
    }

    override init(layer: Any) {
        super.init(layer: layer)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        self.fillColor = colors.background.cgColor
        let progressLayer = CAShapeLayer()
        progressLayer.fillColor = colors.progress.cgColor
        addSublayer(progressLayer)
        self.progressLayer = progressLayer
        self.masksToBounds = true
    }

    private func updateBounds() {
        self.path = UIBezierPath(roundedRect: bounds, cornerRadius: bounds.height / 2).cgPath
        progressLayer?.frame = bounds
        updateProgress()
    }

    private func updateProgress() {
        var progressRect = bounds
        progressRect.size.width *= progress
        progressLayer?.path = UIBezierPath(
            roundedRect: progressRect,
            cornerRadius: bounds.height / 2
        ).cgPath
    }
}

public class PMProgressPageControl: UIControl {
    private var pagesUI: [PMProgressPageControlItem] = []
    private var progressTimer: Timer?
    private var uiUpdateTimer: Timer?
    private weak var currentPageUI: PMProgressPageControlItem?
    private var tickCount: Int = 0

    public var config: PMProgressPageControlConfig = .init() {
        didSet {
            redrawControl()
        }
    }

    public let progressDone = PassthroughSubject<Int, Never>()
    public let progressStarted = PassthroughSubject<Int, Never>()
    public private(set) var currentPage: Int = 0
    public var numberOfPages: Int = 0 {
        didSet {
            redrawControl()
        }
    }
    private var colors: PMProgressControlColors = .defaultColors

    // init
    convenience public init(
        configuration: PMProgressPageControlConfig,
        colors: PMProgressControlColors = .defaultColors
    ) {
        self.init(frame: .zero)
        self.config = configuration
        self.colors = colors
    }

    var nextPage: Int {
        currentPage + 1 < numberOfPages ? currentPage + 1 : 0
    }

    private var boundingBoxes: [CGRect] {
        guard numberOfPages > 0 else { return [] }
        let boxesArea: CGFloat = bounds.width - (config.spacing * CGFloat(numberOfPages - 1))
        let boxWidth: CGFloat = boxesArea / CGFloat(numberOfPages)
        return (0..<numberOfPages).map {
            CGRect(
                x: CGFloat($0) * (boxWidth + config.spacing),
                y: 0,
                width: boxWidth,
                height: bounds.height
            )
        }
    }

    private func redrawControl() {
        self.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        pagesUI.removeAll()
        boundingBoxes.forEach {
            let pageUI = PMProgressPageControlItem(colors: self.colors)
            pageUI.frame = $0
            pagesUI.append(pageUI)
            self.layer.addSublayer(pageUI)
        }
        if currentPage < numberOfPages {
            currentPageUI = pagesUI[currentPage]
        }
    }

    private func updateBounds() {
        zip(pagesUI, boundingBoxes).forEach { $0.frame = $1 }
    }

    public func startProgress() {
        progressTimer?.invalidate()
        uiUpdateTimer?.invalidate()
        tickCount = 0
        guard currentPage < numberOfPages else { return }
        progressStarted.send(currentPage)
        currentPageUI = pagesUI[currentPage]
        progressTimer = Timer
            .scheduledTimer(
                withTimeInterval: config.progressInterval,
                repeats: false,
                block: { [weak self] _ in
                    Task { @MainActor in
                        self?.progressFinished()
                    }
                }
            )
        uiUpdateTimer = Timer
            .scheduledTimer(
                withTimeInterval: config.uiUpdateInterval,
                repeats: true,
                block: { [weak self] _ in
                    Task { @MainActor in
                        self?.updateProgressUI()
                    }
                }
            )
    }

    public func setCurrent(page: Int, progressImmediately: Bool = true) {
        guard page < numberOfPages, numberOfPages > 0 else { return }
        (0..<numberOfPages).forEach {
            pagesUI[$0].progress = $0 < page ? 1 : 0
        }
        currentPage = page
        currentPageUI = pagesUI[currentPage]
        if progressImmediately {
            startProgress()
        }
    }

    private func updateProgressUI() {
        let curProgress = Double(tickCount) / max(1, config.progressInterval / config.uiUpdateInterval)
        currentPageUI?.progress = curProgress
        tickCount += 1
    }

    private func progressFinished() {
        currentPageUI?.progress = 1
        resetAllTimers()
        progressDone.send(currentPage)
        let gotoPage = nextPage
        switch config.runType {
        case .manual:
            return
        case .toEnd:
            if gotoPage == 0 {
                return
            } else {
                fallthrough
            }
        case .loop:
            if gotoPage == 0 {
                resetAll()
            }
            setCurrent(page: gotoPage)
            startProgress()
        }
    }

    public func resetAll() {
        resetAllTimers()
        pagesUI.forEach { $0.progress = 0 }
        currentPageUI = nil
        tickCount = 0
    }

    private func resetAllTimers() {
        progressTimer?.invalidate()
        uiUpdateTimer?.invalidate()
        progressTimer = nil
        uiUpdateTimer = nil
    }

    public override var bounds: CGRect {
        didSet {
            updateBounds()
        }
    }
    public override var frame: CGRect {
        didSet {
            updateBounds()
        }
    }
}
