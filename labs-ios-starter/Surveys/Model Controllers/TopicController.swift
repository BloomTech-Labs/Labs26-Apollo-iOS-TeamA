//
//  TopicController.swift
//  labs-ios-starter
//
//  Created by Kenny on 9/12/20.
//  Copyright © 2020 Lambda, Inc. All rights reserved.
//

import CoreData
import Foundation

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

/// Represent's a contextQuestion's id
struct ContextQuestionObject: Codable {
    enum CodingKeys: String, CodingKey {
        case contextQuestionId = "contextquestionid"
    }

    let contextQuestionId: Int
}

/// Represent's a requestQuestion's id
struct RequestQuestionObject: Codable {
    enum CodingKeys: String, CodingKey {
        case requestQuestionId = "requestquestionid"
    }

    let requestQuestionId: Int
}

enum QuestionType {
    case context
    case request
}

/// Used to get related context and resquest questions
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

    // MARK: - Properties -
    let networkService = NetworkService.shared
    let profileController = ProfileController.shared
    lazy var baseURL = profileController.baseURL
    let group = DispatchGroup()

    // MARK: - Create -
    // TODO: Responses
    /// Post a topic to the web back end with the currently signed in user as the leader
    /// - Parameters:
    ///   - name: The name of the topic
    ///   - contextId: the context question's ID
    ///   - questions: the questions chosen
    ///   - complete: completes with the topic's join code
    func postTopic(with name: String, contextId: Int, contextQuestions: [ContextQuestion], requestQuestions: [RequestQuestion], complete: @escaping CompleteWithString) {
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
                // get id from data and save to CoreData
                guard let id = self.getTopicID(from: data) else {
                    complete(.failure(.badDecode))
                    return
                }
                topic.id = id
                try? CoreDataManager.shared.saveContext(CoreDataManager.shared.backgroundContext, async: true)
                //link questions to topic and send to server
                self.addQuestions(contextQuestions: contextQuestions, requestQuestions: requestQuestions, to: topic) { (result) in
                    switch result {
                    case .success:
                        complete(.success(joinCode))
                    case let .failure(error):
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
    ///   - context: new backgroundContext by default. this will propagate to all child methods
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
                            topic.addToContextQuestions(contextQuestion)
                        } else {
                            print("didn't receive context question")
                        }
                        self.group.leave()
                    }
                }

                debugPrint("Request Ids: \(requestIds.count)")
                for requestId in requestIds {
                    self.group.enter()
                    self.getRequestQuestion(context: context, requestId: requestId) { requestQuestion in
                        if let requestQuestion = requestQuestion {
                            topic.addToRequestQuestions(requestQuestion)
                        }
                        self.group.leave()
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

    func getDefaultContexts(context: NSManagedObjectContext = CoreDataManager.shared.backgroundContext, complete: @escaping CompleteWithNetworkError) {
        guard let request = createRequest(pathFromBaseURL: "context") else {
            print("couldn't create context request")
            return
        }

        self.networkService.loadData(using: request) { result in
            switch result {
            case let .success(data):
                guard let _ = self.networkService.decode(
                        to: [ContextObject].self,
                        data: data,
                        moc: context) else {
                    print("couldn't decode contexts")
                    complete(.failure(.badDecode))
                    return
                }

                try? CoreDataManager.shared.saveContext(context)

                complete(.success(Void()))
            case let .failure(error):
                complete(.failure(error))
            }
        }
    }

    /// get default (template == true) ContextQuestions
    func getDefaultContextQuestions(context: NSManagedObjectContext = CoreDataManager.shared.backgroundContext, complete: @escaping CompleteWithNetworkError) {
        guard let request = createRequest(pathFromBaseURL: "contextQuestion") else {
            print("couldn't create request")
            complete(.failure(.badRequest))
            return
        }
        networkService.loadData(using: request) { result in
            switch result {
            case let .success(data):
                guard let _ = self.networkService.decode(
                        to: [ContextQuestion].self,
                        data: data,
                        moc: context) else {
                    complete(.failure(.badDecode))
                    return
                }
                try? CoreDataManager.shared.saveContext(context)
                complete(.success(Void()))
                
            case let .failure(error):
                print("Error getting Default Contexts: \(error)")
                complete(.failure(.unknown))
            }
        }


    }

    func getAllTopicDetails(context: NSManagedObjectContext, complete: @escaping ([Topic]?, [TopicDetails]?) -> Void) {
        guard let request = createRequest(pathFromBaseURL: "topic") else {
            print("couldn't create request")
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
    func getContextQuestion(context: NSManagedObjectContext, contextId: Int64, complete: @escaping ((ContextQuestion?) -> Void)) {
        guard let request = self.createRequest(pathFromBaseURL: "/contextquestion/\(contextId)")
                >< "Invalid Request for contextQuestions"
        else { return }
        self.networkService.loadData(using: request) { result in
            switch result {
            case let .success(data):
                let question = self.networkService.decode(to: ContextQuestion.self, data: data, moc: context)
                complete(question)
            case let .failure(error):
                print(error)
            }
        }
    }
    /// get a single request question
    func getRequestQuestion(context: NSManagedObjectContext, requestId: Int64, complete: @escaping ((RequestQuestion?) -> Void)) {
        guard let request = self.createRequest(pathFromBaseURL: "/requestQuestion/\(requestId)")
                >< "Invalid Request for requestQuestions"
        else { return }
        self.networkService.loadData(using: request) { result in
            switch result {
            case let .success(data):
                let question = self.networkService.decode(to: RequestQuestion.self, data: data, moc: context)
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
    
    // MARK: - Update -

    // this method currently doesn't check to see if all questions
    // were posted before moving on, so this could cause a discrepancy
    // on the next run when CoreData syncs with the API as questions
    // that weren't received by the API will be deleted on sync
    /// Assign an array of questions to a Topic (creates relationship in CoreData and on Server)
    func addQuestions(contextQuestions: [ContextQuestion], requestQuestions: [RequestQuestion], to topic: Topic, completion: @escaping CompleteWithNetworkError) {
        let contextQuestionSet = NSSet(array: contextQuestions)
        let requestQuestionSet = NSSet(array: requestQuestions)

        topic.addToContextQuestions(contextQuestionSet)
        topic.addToRequestQuestions(requestQuestionSet)

        for contextQuestion in contextQuestions {
            self.group.enter()
            let topicQuestion = TopicQuestion(topicId: Int(topic.id ?? 0), questionId: Int(contextQuestion.id))

            guard var request = createRequest(pathFromBaseURL: "topicquestion", method: .post) else {
                print("Couldn't create request")
                completion(.failure(.badRequest))
                return
            }

            request.encode(from: topicQuestion)

            networkService.loadData(using: request) { result in
                self.group.leave()

                switch result {
                case let .success(data):
                    print(data)
                case .failure(let error):
                    print(error)
                    // should we complete here or post what we can?
                }
            }
        }

        for requestQuestion in requestQuestions {
            self.group.enter()
            let topicQuestion = TopicQuestion(topicId: Int(topic.id ?? 0), questionId: Int(requestQuestion.id))

            guard var request = createRequest(pathFromBaseURL: "topicquestion", method: .post) else {
                print("Couldn't create request")
                completion(.failure(.badRequest))
                return
            }

            request.encode(from: topicQuestion)

            networkService.loadData(using: request) { result in
                self.group.leave()
                switch result {
                case .success(let data):
                    print(data)
                case .failure(let error):
                    print(error)
                    // should we complete here or post what we can?
                }
            }
        }

        self.group.notify(queue: .main) {
            do {
                try CoreDataManager.shared.saveContext()
                completion(.success(Void()))
            } catch let saveError {
                print("Error saving to coredata: \(saveError)")
                completion(.failure(.unknown))
            }
        }
    }

    func updateTopic(topic: Topic, completion: @escaping CompleteWithNetworkError) {
        // send topic to server using PUT request. save in CoreData
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
        do {
            try CoreDataManager.shared.saveContext(context, async: true)
        } catch {
            print("delete topics save error: \(error)")
        }
    }

    // MARK: - Helper Methods -

    private func getTopicID(from data: Data) -> Int64? {
        guard let topicID = networkService.decode(to: TopicID.self, data: data)?.topic.id else {
            print("Couldn't get ID from newly created topic")
            return nil
        }
        return Int64(topicID)
    }
}
