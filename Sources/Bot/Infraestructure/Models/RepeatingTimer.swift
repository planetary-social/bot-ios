//
//  RepeatingTimer.swift
//  
//
//  Created by Martin Dutra on 9/1/22.
//

import Foundation

class RepeatingTimer {

    let interval: TimeInterval
    private var completion: (() -> Void)
    private var timer: Timer?

    var isRunning: Bool {
        return self.timer != nil
    }

    init(interval: TimeInterval = 10, completion: @escaping (() -> Void)) {
        self.interval = interval
        self.completion = completion
    }

    func start(fireImmediately: Bool = false) {
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) {
            timer in
            self.completion()
        }
        if fireImmediately { self.completion() }
    }

    func stop() {
        self.timer?.invalidate()
        self.timer = nil
    }
}
