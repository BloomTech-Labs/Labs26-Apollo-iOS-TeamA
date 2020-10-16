//
//  TempTopicController.swift
//  labs-ios-starter
//
//  Created by Kenny on 10/16/20.
//  Copyright © 2020 Lambda, Inc. All rights reserved.
//

import Foundation

class TempTopicController {
    private var contextSemaphore: DispatchSemaphore?
    private var requestSemaphore: DispatchSemaphore?

    func getTopics(complete: @escaping ([Topic], [TopicDetails]) -> Void) {

    }

    func getContextQuestion(contextId: Int64, complete: @escaping ((Question) -> Void)) {

    }

    func getRequestQuestion(requestId: Int64, complete: @escaping ((Question) -> Void)) {

    }

    func getContextAndRequestQuestions(complete: @escaping () -> Void) {
        getTopics { topics, topicDetails in
            for (topicIndex, topicDetail) in topicDetails.enumerated() {
                let topic = topics[topicIndex]
                // create arrays of question IDs
                let contextIds = topicDetail.contextQuestionIds.map { Int64($0.contextQuestionId) }
                let requestIds = topicDetail.requestQuestionIds.map { Int64($0.requestQuestionId) }
                // create semaphores with count equal array count
                self.contextSemaphore = DispatchSemaphore(value: contextIds.count)
                self.requestSemaphore = DispatchSemaphore(value: requestIds.count)

                for contextId in contextIds {
                    //block thread, decrement count
                    self.contextSemaphore?.wait()

                    self.getContextQuestion(contextId: contextId) { contextQuestion in
                        topic.addToQuestions(contextQuestion)
                        // increment count
                        self.contextSemaphore?.signal()
                    }
                }

                for requestId in requestIds {
                    // block thread
                    self.requestSemaphore?.wait()

                    self.getRequestQuestion(requestId: requestId) { requestQuestion in
                        topic.addToQuestions(requestQuestion)
                        // increment count
                        self.requestSemaphore?.signal()
                    }
                }
            }
        }
    }
}
