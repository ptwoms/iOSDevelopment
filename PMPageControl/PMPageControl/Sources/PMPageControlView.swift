//
//  PMPageControlView.swift
//  PMPageControl
//
//  Created by Pyae Phyo Myint Soe on 18/1/25.
//

import SwiftUI
import Combine

struct PMProgressPageControlItemSwiftUI: View, Identifiable {
    var id: String = UUID().uuidString

    struct Colors {
        let background: SwiftUI.Color
        let progress: SwiftUI.Color
    }

    @State var progress: CGFloat
    @State var colors: Colors = Colors(
        background: .gray,
        progress: .black
    )
    var body: some View {
        GeometryReader { bounds in
            let cornerRadius: CGFloat = min(bounds.size.height, bounds.size.width) / 2
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerSize: .init(width: cornerRadius, height: cornerRadius))
                    .foregroundColor(colors.background)
                RoundedRectangle(cornerSize: .init(width: cornerRadius, height: cornerRadius))
                    .foregroundColor(colors.progress)
                    .frame(width: progress * bounds.size.width)
            }
        }
    }
}

public struct PMPageControlView: View {
    @State public var numberOfPages: Int
    @State public var currentPage: Int
    @State public var config: PMProgressPageControlConfig
    @Binding public var startProgress: Bool
    @StateObject private var uiUpdate = PMTimer()
    @StateObject private var progressUpdate = PMTimer()

    public init(
        numberOfPages: Int,
        currentPage: Int,
        config: PMProgressPageControlConfig = PMProgressPageControlConfig(),
        startProgress: Binding<Bool>
    ) {
        self.numberOfPages = numberOfPages
        self.currentPage = currentPage
        self.config = config
        self._startProgress = startProgress
    }

    private func startUiUpdate() {
        uiUpdate.start(interval: config.uiUpdateInterval)
        progressUpdate.start(interval: config.progressInterval)
    }

    private func stopUiUpdate() {
        uiUpdate.stop()
        progressUpdate.stop()
    }

    private func progressFor(index: Int) -> CGFloat {
        if index < currentPage {
            return 1
        } else if index == currentPage {
            let newProgress = min(1, Double(uiUpdate.timerCount) / max(
                1,
                config.progressInterval / config.uiUpdateInterval
            ))
            return newProgress
        }
        return 0
    }

    public var body: some View {
        let allPages = (0..<numberOfPages).map { index in
            PMProgressPageControlItemSwiftUI(
                progress: progressFor(index: index)
            )
        }
        HStack(spacing: config.spacing) {
            ForEach(allPages) {
                $0
            }
        }
        .onReceive(uiUpdate.$timerCount) { curCount in
            allPages[currentPage].progress = progressFor(index: currentPage)
        }
        .onReceive(progressUpdate.$timerCount) { curCount in
            guard curCount > 0 else { return }
            stopUiUpdate()
            if config.runType == .manual {
                startProgress = false
            } else {
                let nextPage = currentPage + 1 < numberOfPages ? currentPage + 1 : 0
                if config.runType == .toEnd, nextPage == 0 {
                    startProgress = false
                    return
                }
                currentPage = nextPage < numberOfPages ? nextPage : 0
                startUiUpdate()
            }
        }.onChange(of: startProgress) { newValue in
            if newValue {
                startUiUpdate()
            } else {
                stopUiUpdate()
            }
        }
    }
}


@available(iOS 17.0, *)
#Preview
{
    @Previewable @State var startProgress: Bool = false
    let progressCtrl = PMPageControlView(
        numberOfPages: 3,
        currentPage: 0,
        config: PMProgressPageControlConfig(progressType: .loop),
        startProgress: $startProgress)
        .frame(height: 10)
        .background(Color.clear)
        .padding(
            EdgeInsets(top: 0, leading: 24, bottom: 0, trailing: 24)
        )
        .onAppear {
            startProgress = true
        }
    progressCtrl
}
