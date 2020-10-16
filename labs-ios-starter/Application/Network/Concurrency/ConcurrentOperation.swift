//
//  ConcurrentOperation.swift
//  labs-ios-starter
//
//  Created by Kenny on 10/15/20.
//  Copyright © 2020 Lambda, Inc. All rights reserved.
//

import Foundation

class ConcurrentOperation: Operation {

    // MARK: Types

    enum State: String {
        case isReady, isExecuting, isFinished
    }

    // MARK: Properties

    private var _state = State.isReady

    private let stateQueue = DispatchQueue(label: "com.labs-ios-starter.concurrency_Queue")
    var state: State {
        get {
            var result: State?
            let queue = self.stateQueue
            queue.sync {
                result = _state
            }
            return result!
        }

        set {
            let oldValue = state
            willChangeValue(forKey: newValue.rawValue)
            willChangeValue(forKey: oldValue.rawValue)

            stateQueue.sync { self._state = newValue }

            didChangeValue(forKey: oldValue.rawValue)
            didChangeValue(forKey: newValue.rawValue)
        }
    }

    // MARK: NSOperation

    override dynamic var isReady: Bool {
        return super.isReady && state == .isReady
    }

    override dynamic var isExecuting: Bool {
        return state == .isExecuting
    }

    override dynamic var isFinished: Bool {
        return state == .isFinished
    }

    override var isAsynchronous: Bool {
        return true
    }

}
