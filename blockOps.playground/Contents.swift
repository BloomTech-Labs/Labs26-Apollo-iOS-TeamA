import Foundation
import PlaygroundSupport

func operationQueue(with ops: [BlockOperation], executeOnMainThread: Bool = false, wait: Bool = true, queue: OperationQueue = OperationQueue()) -> OperationQueue {
    var queue = queue

    if executeOnMainThread {
        queue = OperationQueue.main
    }

    queue.addOperations(ops, waitUntilFinished: wait)
    return queue
}

var queue = OperationQueue()

let op1 = BlockOperation() {
    print("op1 finished")
    let op2 = BlockOperation() {
        print("op2 finished")
    }
    let op3 = BlockOperation() {
        print("op3 finished")
    }
    queue.addOperation(op2)
    queue.addOperation(op3)
}

// queue = operationQueue(with: [op1], wait: true, queue: queue)

var googleOp = BlockOperation()

var block: ((Bool) -> ())

let request = URLRequest(url: URL(string: "https://www.google.com")!)
let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
    googleOp.completionBlock = block
    queue.addOperation(googleOp)
}




PlaygroundPage.current.needsIndefiniteExecution = true
