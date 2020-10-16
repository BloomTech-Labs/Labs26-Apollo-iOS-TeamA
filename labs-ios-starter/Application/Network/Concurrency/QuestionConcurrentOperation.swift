//
//  QuestionConcurrentOperation.swift
//  labs-ios-starter
//
//  Created by Kenny on 10/15/20.
//  Copyright © 2020 Lambda, Inc. All rights reserved.
//

import Foundation

class QuestionFetchOperation: ConcurrentOperation {
    //=======================
    // MARK: - Properties
    private var questionId: Int64
    private var context = CoreDataManager.shared.backgroundContext
    var imageData: Data?
    private var dataTask: URLSessionDataTask?

    init(id: Int64, session: URLSession = .shared) {
        self.questionId = id
        super.init()
    }

    override func start() {
        state = .isExecuting
        fetchQuestion()
        dataTask?.resume()
    }

    override func cancel() {
        state = .isFinished
        dataTask?.cancel()
    }

    func fetchQuestion() {
        guard let url =
        dataTask = URLSession.shared.dataTask(with: url) { (data, _, error) in
            defer {
                self.state = .isFinished
            }
            if let error = error {
                print(error)
                return
            }
            guard let data = data else {
                print("No data")
                return
            }
            self.imageData = data
        }
    }
}


