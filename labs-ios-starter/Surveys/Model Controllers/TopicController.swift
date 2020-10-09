//
//  TopicController.swift
//  labs-ios-starter
//
//  Created by Kenny on 9/12/20.
//  Copyright © 2020 Lambda, Inc. All rights reserved.
//
import Foundation
import CoreData

// MARK: - Codable Types -
/// Used to get Topic Details and establish CoreData Relationships
struct TopicDetails: Codable {

    enum CodingKeys: String, CodingKey {
        case details = "0"
        case contextQuestionIds = "contextquestions"
        case requestQuestionIds = "requestquestions"
    }

    var details: TopicDetailObject
    var contextQuestionIds: [ContextQuestionObject]
    var requestQuestionIds: [RequestQuestionObject]
}


struct ContextQuestionObject: Codable {
    enum CodingKeys: String, CodingKey {
        case contextQuestionId = "contextquestionid"
    }
    let contextQuestionId: Int
}

struct RequestQuestionObject: Codable {
    enum CodingKeys: String, CodingKey {
        case requestQuestionId = "requestquestionid"
    }
    let requestQuestionId: Int
}

struct TopicDetailObject: Codable {

    enum CodingKeys: String, CodingKey {
        case joinCode = "joincode"
        case id
        case contextId = "contextid"
        case leaderId = "leaderid"
        case topicName = "topicname"

    }
    let joinCode: String
    let id: Int
    let contextId: Int
    let leaderId: String
    let topicName: String
}

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
    /// Download context and request questions for a Topic
    // TODO: Split Questions into 2 types
    func getLinkedQuestions(with contextIds: [Int64], requestIds: [Int64], for topic: Topic, context: NSManagedObjectContext = CoreDataManager.shared.backgroundContext, completion: @escaping CompleteWithNetworkError) {

        var contextQuestions: [Question] = []
        var contextIndex = 0
        for contextId in contextIds {

            guard let request = self.createRequest(pathFromBaseURL: "/contextquestion/\(contextId)")
                    >< "Invalid Request for contextQuestions"
            else { continue }
            // get questions
            self.networkService.loadData(using: request) { result in
                contextIndex += 1

                switch result {
                case let .success(data):
                    if let question = self.networkService.decode(to: Question.self, data: data, moc: context),
                       contextIds.count > 0 {
                        contextQuestions.append(question)
                        // attach context questions to Topic
                        if contextIndex >= contextQuestions.count {
                            for contextQuestion in contextQuestions {
                                topic.addToQuestions(contextQuestion)
                            }
                            completion(.success(Void()))
                        }
                    } else {
                        print("couldn't decode context question for topic: \(topic.id) with \(topic.questions?.count) questions")
                        completion(.failure(.badDecode))
                    }
                case let .failure(error):
                    completion(.failure(error))
                }
            }

        }


        //        // Download request questions
        //        var requestQuestions: [Question] = []
        //        // attach request questions to Topic
        //        for requestQuestion in requestQuestions {
        //            topic.addToQuestions(requestQuestion)
        //        }
    }

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
            // TODO: POST Questions

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
                let context = CoreDataManager.shared.backgroundContext
                guard let topicShells = self.networkService.decode(to: [Topic].self,
                                                                   data: data,
                                                                   moc: context) else {
                    print("Error decoding topics")
                    completion(.failure(.badDecode))
                    return
                }

                var topics: [Topic] = [] //Holds topics with relationships
                // Make request to topicDetail endpoint for each topic]
                var i = 0
                for topic in topicShells {
                    guard let topicId = topic.id
                            >< "failure unwrapping topic.id"
                    else { return }

                    guard let request = self.createRequest(pathFromBaseURL: "topic/\(topicId)/details")
                            >< "failed to create topic detail request \(topicId)"
                    else { continue }
                    print("sending request to topic/\(topicId)/details")
                    self.networkService.loadData(using: request) { detailResult in
                        switch detailResult {
                        case let .success(data):
                            if let topicDetails = self.networkService.decode(to: TopicDetails.self, data: data, moc: context) {
                                print("receiving response from topic/\(topicDetails)/details")
                                let contextIds: [Int64] = topicDetails.contextQuestionIds.map { Int64($0.contextQuestionId) }
                                let requestIds: [Int64] = topicDetails.requestQuestionIds.map { Int64($0.requestQuestionId) }
                                let thisTopic = topicShells.filter { $0.id ?? 1 == topicDetails.details.id }[0]

                                i+=1
                                topics.append(thisTopic)

                                if !contextIds.isEmpty {
                                    // get contextQuestions and responseQuestions and save to topics in CoreData
                                    self.getLinkedQuestions(with: contextIds, requestIds: requestIds, for: thisTopic, context: context) { result in
                                        //TODO: switch result
                                        if i >= topicShells.count {
                                            // sync topics
                                            let serverTopicIDs = topics.compactMap { $0.id }
                                            guard let topicsNotOnServer = FetchController().fetchTopicsNotOnServer(serverTopicIDs, context: context) else {
                                                print("no topics to delete")
                                                completion(.success(Void()))
                                                return
                                            }
                                            self.deleteTopicsFromCoreData(topics: topicsNotOnServer, context: context)
                                            completion(.success(Void()))
                                            return
                                        }
                                    }
                                }

                            } else {
                                print("Failed to decode topic details")
                                // not sure what we should do here.
                                // If we don't get the topic details,
                                // we probably shouldn't display the topic
                                // should we alert the user?
                                // we can't return because there may be more topics to decode
                                // we can't continue because we're async (can only continue in loop error)
                            }

                        case let .failure(error):
                            print(error) // same as with decode failure above
                        }
                    }

                }

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
        guard let request = createRequest(pathFromBaseURL: "contextquestion") else {
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

                do {
                    try CoreDataManager.shared.saveContext()
                    completion(.success(Void()))
                } catch let saveQuestionsError {
                    print("error saving questions: \(saveQuestionsError)")
                    completion(.failure(.resourceNotAcceptable)) // add error?
                }

                
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

    func deleteTopicsFromCoreData(topics: [Topic], context: NSManagedObjectContext = CoreDataManager.shared.backgroundContext) {
        for topic in topics {
            context.delete(topic)
        }
        try? CoreDataManager.shared.saveContext(context, async: true)
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
