//
//  TopicController.swift
//  labs-ios-starter
//
//  Created by Kenny on 9/12/20.
//  Copyright © 2020 Lambda, Inc. All rights reserved.
//

import Foundation
// MARK: - FOO -
/// Controller for Topic, ContextObject, and Question model
class TopicController {
    let networkService = NetworkService.shared
    let profileController = ProfileController.shared
    lazy var baseURL = profileController.baseURL

    // MARK: - Create -

    // TODO: Responses

    /// Post a topic to the web back end with the currently signed in user as the leader
    /// - Parameters:
    ///   - name: The name of the topic
    ///   - contextId: the context question's ID
    ///   - questions: the questions chosen
    ///   - complete: completes with the topic's join code
    func postTopic(with name: String, contextId: Int, questions: [Question], complete: @escaping CompleteWithString) {
        // We know this request is good, but we can still guard unwrap it rather than
        // force unwrapping and assume if something fails it was the user not being logged in
        guard var request = createRequest(pathFromBaseURL: "topic", method: .post),
            let token = try? profileController.oktaAuth.credentialsIfAvailable().userID else {
            print("user isn't logged in")
            return
        }
        // Create topic and add to request
        let joinCode = UUID().uuidString
        let topic = Topic(joinCode: joinCode,
                          leaderId: token,
                          topicName: name,
                          contextId: Int64(contextId))
        // let questionsToSend = questions.map { $0.id }

        do {
            // TODO: Save on background context?
            try CoreDataManager.shared.saveContext(CoreDataManager.shared.mainContext, async: true)
        } catch let saveError {
            // The user doesn't need to be notified about this (maybe they could be through a label, but wouldn't reccommend anything that interrupts them like an alert)
            NSLog("Error saving Topic: \(name) to CoreData: \(saveError)")
        }
        request.encode(from: topic)

        networkService.loadData(using: request) { result in
            switch result {
            case .success:
                complete(.success(joinCode))
            case let .failure(error):
                NSLog("Error POSTing topic with statusCode: \(error.rawValue)")
                complete(.failure(error))
            }
        }
    }

    // MARK: - Read -

    /// fetch all topics, or topics for the currently logged in user
    /// - Parameters:
    ///   - all: fetch topics for all users (`true`) or just the currently logged in user (`false`)
    ///   - completion: Completes with `[Topic]`. Topics are also stored in the controller...
    func fetchTopic(all: Bool = false, completion: @escaping CompleteWithTopics) {
        guard let request = createRequest(pathFromBaseURL: "topic") else {
            print("🛑! User isn't logged in!")
            completion(.failure(.unauthorized))
            return
        }

        networkService.loadData(using: request) { result in
            switch result {
            case let .success(data):
                guard let topics = self.networkService.decode(to: [Topic].self,
                                                              data: data,
                                                              moc: CoreDataManager.shared.mainContext) else {
                    print("Error decoding topics")
                    completion(.failure(.badDecode))
                    return
                }
                var userTopics: [Topic] = []
                if !all {
                    guard let user = ProfileController.shared.authenticatedUserProfile else {
                        print("🛑! User isn't logged in!")
                        completion(.failure(.unauthorized))
                        return
                    }
                    // This is going to be quite the expensive check if there are a lot of topics with a lot of members
                    for topic in topics {
                        if topic.leaderId == user.id { // member is leader
                            userTopics.append(topic)
                        } else if let members = topic.members { // member is user
                            if members.contains(user) {
                                userTopics.append(topic)
                            }
                        }
                    }
                }
                completion(.success(userTopics))

            case let .failure(error):
                // bubble error to caller
                completion(.failure(error))
            }
        }
    }

    /// Get all contexts
    func getAllContexts(complete: @escaping CompleteWithNeworkError) {
        guard let request = createRequest(pathFromBaseURL: "context") else {
            print("couldn't get context, invalid request")
            return
        }
        networkService.loadData(using: request) { result in
            switch result {
            case let .success(data):
                // fetch contexts and save to CoreData
                guard self.networkService.decode(to: [ContextObject].self,
                                                 data: data,
                                                 moc: CoreDataManager.shared.mainContext) != nil else {
                    print("error decoding contexts from valid data. see surrounding lines for more information from NetworkService")
                    complete(.failure(.notFound))
                    return
                }
                do {
                    try CoreDataManager.shared.saveContext()
                } catch let saveContextError {
                    print("Error saving context: \(saveContextError)")
                }

                complete(.success(Void()))
            // bubble error to caller
            case let .failure(error):
                complete(.failure(error))
            }
        }
    }

    func getQuestions(completion: @escaping CompleteWithNeworkError) {
        // create request to /question
        guard let request = createRequest(pathFromBaseURL: "question") else {
            completion(.failure(.badRequest))
            return
        }

        // get questions from endpoint
        networkService.loadData(using: request) { result in
            // self is nil here???
            switch result {
            // decode questions
            case let .success(data):
                guard let questions = self.networkService.decode(to: [Question].self,
                                                                 data: data,
                                                                 moc: CoreDataManager.shared.mainContext) else {
                    completion(.failure(.badDecode))
                    return
                }
                try? CoreDataManager.shared.saveContext()
                completion(.success(Void()))

            // bubble error to caller
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    func getAllQuestionsAndContexts(completion: @escaping CompleteWithNeworkError) {
        getAllContexts { contextResult in
            switch contextResult {
            case .success:
                self.getQuestions { result in
                    completion(result)
                }
            case .failure:
                completion(contextResult)
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
