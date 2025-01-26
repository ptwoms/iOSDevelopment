//
//  PMTimer.swift
//  PMPageControl
//
//  Created by Pyae Phyo Myint Soe on 19/1/25.
//

class PMTimer: ObservableObject, @unchecked Sendable {
    @Published var timerCount: Int = 0
    private var timer = Timer()

    func start(interval: TimeInterval) {
        stop()
        timerCount = 0
        timer = Timer
            .scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
                self?.timerCount += 1
        }
    }

    func stop() {
        timer.invalidate()
    }
}
