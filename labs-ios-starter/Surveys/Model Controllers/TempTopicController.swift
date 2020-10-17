//
//  TempTopicController.swift
//  labs-ios-starter
//
//  Created by Kenny on 10/16/20.
//  Copyright © 2020 Lambda, Inc. All rights reserved.
//

import Foundation
import CoreData

class TempTopicController {
    private let group = DispatchGroup()
    // TODO: not sure if we need queues, test
    private let contextQuestionQueue = DispatchQueue.global()
    private let requestQuestionQueue = DispatchQueue.global()

    private let networkService = NetworkService.shared
    let profileController = ProfileController.shared
    lazy var baseURL = profileController.baseURL

    // Start Here
    /// get all topics all related questions, and save to CoreData.
    /// Starts with a new backgroundContext by default
    func getTopics(context: NSManagedObjectContext = CoreDataManager.shared.backgroundContext, complete: @escaping CompleteWithNetworkError) {
        getAllTopicDetails(context: context) { topics, topicDetails in
            guard let topics = topics,
                  let topicDetails = topicDetails else {
                print("Didn't have required Topic information to fetch Questions")
                return
            }
            for (topicIndex, topicDetail) in topicDetails.enumerated() {
                let topic = topics[topicIndex]
                // create arrays of question IDs
                let contextIds = topicDetail.contextQuestionIds.map { Int64($0.contextQuestionId) }
                let requestIds = topicDetail.requestQuestionIds.map { Int64($0.requestQuestionId) }

                debugPrint("Context Ids: \(contextIds.count)")
                for contextId in contextIds {
                    self.group.enter()
                    self.getContextQuestion(context: context, contextId: contextId) { contextQuestion in
                        if let contextQuestion = contextQuestion {
                            topic.addToQuestions(contextQuestion)
                        } else {
                            print("didn't receive context question")
                        }
                        self.group.leave()
                    }
                }

                debugPrint("Request Ids: \(requestIds.count)")
                for requestId in requestIds {
                    self.group.enter()
                    debugPrint("entered")
                    self.getRequestQuestion(context: context, requestId: requestId) { requestQuestion in
                        if let requestQuestion = requestQuestion {
                            topic.addToQuestions(requestQuestion)
                        }
                        self.group.leave()
                        debugPrint("left")
                    }
                }

                self.group.notify(queue: .main) {
                    do {
                        try CoreDataManager.shared.saveContext(context, async: true)
                    } catch {
                        print("Error saving context: \(error)")
                        complete(.failure(.resourceNotAcceptable))
                    }
                    complete(.success(Void()))
                }
            }
        }
    }

    func getAllTopicDetails(context: NSManagedObjectContext, complete: @escaping ([Topic]?, [TopicDetails]?) -> Void) {
        guard let request = createRequest(pathFromBaseURL: "topic") else {
            print("🛑! User isn't logged in!")
            complete(nil, nil)
            return
        }
        networkService.loadData(using: request) { result in
            switch result {
            case let .success(data):
                guard let topicShells = self.networkService.decode(to: [Topic].self,
                                                                   data:data,
                                                                   moc: context) else {
                    print("Error decoding topics")
                    complete(nil, nil)
                    return
                }
                let topicIds = topicShells.map { Int64($0.id ?? 999_999_999) }

                self.getTopicDetails(context: context, topicIds: topicIds) { (topicDetails) in
                    complete(topicShells, topicDetails)
                }

            case let .failure(error):
                print(error)
                complete(nil, nil)
            }
        }
    }
    /// get details for all topics, uses DispatchGroup
    func getTopicDetails(context: NSManagedObjectContext, topicIds: [Int64], complete: @escaping ([TopicDetails]) -> ()) {
        var topicDetails: [TopicDetails] = []

        for topicId in topicIds {
            self.group.enter()
            //make request to topicId endpoint
            guard let topicDetailRequest = self.createRequest(pathFromBaseURL: "topic/\(topicId)/details")
                    >< "failed to create topic detail request \(topicId)"
            else {
                self.group.leave()
                continue
            }
            networkService.loadData(using: topicDetailRequest) { (result) in
                switch result {
                case let .success(data):
                    if let topicDetail = self.networkService.decode(to: TopicDetails.self, data: data) {
                        topicDetails.append(topicDetail)
                    } else {
                        print("⚠️couldn't decode topic details!⚠️")
                    }
                    self.group.leave()
                case let .failure(error):
                    print(error)
                    self.group.leave()
                }
            }
        }
        // group is done with all blocks
        self.group.notify(queue: .main) {
            complete(topicDetails)
        }
    }
    /// GET a single context question
    func getContextQuestion(context: NSManagedObjectContext, contextId: Int64, complete: @escaping ((Question?) -> Void)) {
        guard let request = self.createRequest(pathFromBaseURL: "/contextquestion/\(contextId)")
                >< "Invalid Request for contextQuestions"
        else { return }
        self.networkService.loadData(using: request) { result in
            switch result {
            case let .success(data):
                let question = self.networkService.decode(to: Question.self, data: data, moc: context)
                complete(question)
            case let .failure(error):
                print(error)
            }
        }
    }

    func getRequestQuestion(context: NSManagedObjectContext, requestId: Int64, complete: @escaping ((Question?) -> Void)) {
        guard let request = self.createRequest(pathFromBaseURL: "/requestQuestion/\(requestId)")
                >< "Invalid Request for requestQuestions"
        else { return }
        self.networkService.loadData(using: request) { result in
            switch result {
            case let .success(data):
                let question = self.networkService.decode(to: Question.self, data: data, moc: context)
                complete(question)
            case let .failure(error):
                print(error)
            }
        }
    }
    // MARK: - Helper Methods -
    private func createRequest(auth: Bool = true,
                               pathFromBaseURL: String,
                               method: NetworkService.HttpMethod = .get) -> URLRequest? {
        let targetURL = baseURL.appendingPathComponent(pathFromBaseURL)

        guard var request = networkService.createRequest(url: targetURL, method: method, headerType: .contentType, headerValue: .json) else {
            print("unable to create request for \(targetURL)")
            return nil
        }

        if auth {
            // add bearer to request
            request.addAuthIfAvailable()
        }

        return request
    }
}
