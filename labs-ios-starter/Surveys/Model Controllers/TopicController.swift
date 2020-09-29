//
//  TopicController.swift
//  labs-ios-starter
//
//  Created by Kenny on 9/12/20.
//  Copyright © 2020 Lambda, Inc. All rights reserved.
//
import Foundation

// MARK: - Codable Types -
/// Used to get topic ID after sending to backend
struct TopicID: Codable {
    let topic: DecodeTopic
}
/// Member of TopicID
struct DecodeTopic: Codable {
    let id: Int
}

/// Used to encode topic and question id in order to establish their relationship in the backend
struct TopicQuestion: Codable {
    enum CodingKeys: String, CodingKey {
        case topicId = "topicid"
        case questionId = "questionid"
    }
    var topicId: Int
    var questionId: Int
}

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
        do {
            try CoreDataManager.shared.saveContext(CoreDataManager.shared.backgroundContext, async: true)
        } catch let saveError {
            // The user doesn't need to be notified about this (maybe they could be through a label, but wouldn't reccommend anything that interrupts them like an alert)
            NSLog("Error saving Topic: \(name) to CoreData: \(saveError)")
        }
        request.encode(from: topic)

        networkService.loadData(using: request) { result in
            switch result {
            case let .success(data):
                //get id from data and save to CoreData
                guard let id = self.getTopicID(from: data) else {
                    complete(.failure(.badDecode))
                    return
                }
                topic.id = id
                try? CoreDataManager.shared.saveContext(CoreDataManager.shared.backgroundContext, async: true)
                //link questions to topic and send to server
                self.addQuestions(questions, to: topic) { (result) in
                    switch result {
                    case .success:
                        complete(.success(joinCode))
                    case .failure(let error):
                        complete(.failure(error))
                    }
                }

            case let .failure(error):
                NSLog("Error POSTing topic with statusCode: \(error.rawValue)")
                complete(.failure(error))
            }
        }
    }

    // MARK: - Read -
    /// Fetch all topics from server and save them to CoreData.
    /// - Parameters:
    ///   - completion: Completes with `[Topic]`. Topics are also stored in the controller...
    func fetchTopicsFromServer(completion: @escaping CompleteWithNetworkError) {
        guard let request = createRequest(pathFromBaseURL: "topic") else {
            print("🛑! User isn't logged in!")
            completion(.failure(.unauthorized))
            return
        }

        networkService.loadData(using: request) { result in
            switch result {
            case let .success(data):
                guard self.networkService.decode(to: [Topic].self,
                                                 data: data,
                                                 moc: CoreDataManager.shared.mainContext) != nil else {
                    print("Error decoding topics")
                    completion(.failure(.badDecode))
                    return
                }

                try? CoreDataManager.shared.saveContext()

                completion(.success(Void()))

            case let .failure(error):
                completion(.failure(error)) // bubble error to caller
            }
        }
    }

    /// Get all contexts
    func getAllContexts(complete: @escaping CompleteWithNetworkError) {
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

    func getQuestions(completion: @escaping CompleteWithNetworkError) {
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
                guard let _ = self.networkService.decode(to: [Question].self,
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

    func getAllQuestionsAndContexts(completion: @escaping CompleteWithNetworkError) {
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

    // MARK: - Update -
    /// Assign an array of questions to a Topic (creates relationship in CoreData and on Server)
    func addQuestions(_ questions: [Question], to topic: Topic, completion: @escaping CompleteWithNetworkError) {

        for question in questions {
            let topicQuestion = TopicQuestion(topicId: Int(topic.id ?? 0), questionId: Int(question.id))

            topic.questions = topic.questions!.adding(question) as NSSet

            guard var request = createRequest(pathFromBaseURL: "topicquestion", method: .post) else {
                print("Couldn't create request")
                completion(.failure(.badRequest))
                return
            }

            request.encode(from: topicQuestion)

            networkService.loadData(using: request) { result in
                switch result {
                case .success(let data):
                    print(data)
                    completion(.success(Void()))
                case .failure(let error):
                    completion(.failure(error))
                    print(error)
                }
            }
        }
        try? CoreDataManager.shared.saveContext()

    }

    func updateTopic(topic: Topic, completion: @escaping CompleteWithNetworkError) {
        // send topic to server. save in CoreData
    }

    // MARK: - Delete
    /// Deletes a topic from the server
    /// - Warning: This method should `ONLY` be called by the leader of a topic for their own survey
    func deleteTopic(topic: Topic, completion: @escaping CompleteWithNetworkError) {
        guard
            let id = topic.id,
            let deleteRequest = createRequest(pathFromBaseURL: "topic/\(id)", method: .delete)
        else {
            completion(.failure(.badRequest))
            return
        }

        networkService.loadData(using: deleteRequest) { result in
            switch result {
            case .success:
                completion(.success(Void()))
            case let .failure(error):
                completion(.failure(error))
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

    private func getTopicID(from data: Data) -> Int64? {
        guard let topicID = self.networkService.decode(to: TopicID.self, data: data)?.topic.id else {
            print("Couldn't get ID from newly created topic")
            return nil
        }
        return Int64(topicID)
    }
}
