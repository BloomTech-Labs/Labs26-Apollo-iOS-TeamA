//
//  NetworkService + BlockOperations.swift
//  labs-ios-starter
//
//  Created by Kenny on 10/15/20.
//  Copyright © 2020 Lambda, Inc. All rights reserved.
//

import Foundation

extension NetworkService {

    /// Add operations to a new or existing `OperationQueue`
    /// - Parameters:
    ///   - ops: An array of `BlockOperation` to be added to a queue
    ///   - wait: wait for all operations to finish before unblocking this thread
    ///   - queue: pass in an existing queue, or leave off for a new `OperationQueue()`
    ///     - note: if this is on main, the passed in queue will be ignored in exchange for OperationQueue.main
    /// - Returns: The OperationQueue with BlockOperations added
    func operationQueue(with ops: [BlockOperation], executeOnMainThread: Bool = false, wait: Bool = true, queue: OperationQueue = OperationQueue()) -> OperationQueue {
        var queue = queue

        if executeOnMainThread {
            queue = OperationQueue.main
        }

        queue.addOperations(ops, waitUntilFinished: wait)
        return queue
    }

}
