//
//  PMPageControlConfig.swift
//  PMPageControl
//
//  Created by Pyae Phyo Myint Soe on 19/1/25.
//

// MARK: - Progress Page Control Configuration
public struct PMProgressPageControlConfig {
    public enum ProgressType {
        case manual, toEnd, loop
    }
    public var spacing: CGFloat
    public var progressInterval: TimeInterval
    public var runType: ProgressType
    public var uiUpdateInterval: TimeInterval {
        didSet {
            assert(uiUpdateInterval > 0)
        }
    }

    public init(
        spacing: CGFloat = 8,
        progressInterval: TimeInterval = 8,
        progressType: ProgressType = .toEnd,
        uiUpdateInterval: TimeInterval = 0.2
    ) {
        self.spacing = spacing
        self.progressInterval = progressInterval
        self.runType = progressType
        self.uiUpdateInterval = uiUpdateInterval
    }
}
