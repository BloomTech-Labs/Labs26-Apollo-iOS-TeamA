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



//var queue = OperationQueue()
//
//let op1 = BlockOperation() {
//    for i in 0...1_000_000 {
//        print(i)
//    }
//    var op2 = BlockOperation() {
//        for i in 0...100_000 {
//
//        }
//        print("op2 finished")
//    }
//    var op3 = BlockOperation() {
//        for i in 0...100_500 {
//
//        }
//        print("op3 finished")
//    }
//    queue.addOperation(op2)
//    queue.addOperation(op3)
//}
//func foo() {
//    queue = NetworkService().operationQueue(with: [op1], wait: true, queue: queue)
//}
//
//foo()
