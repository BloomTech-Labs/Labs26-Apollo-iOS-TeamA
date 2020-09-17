    //
//  TopicController.swift
//  labs-ios-starter
//
//  Created by Kenny on 9/12/20.
//  Copyright © 2020 Lambda, Inc. All rights reserved.
//

import Foundation

/// Controller for Topic, ContextObject, and Question model
class TopicController {
    let networkService = NetworkService.shared
    let profileController = ProfileController.shared
    lazy var baseURL = profileController.baseURL

    ///public getter for CONTEXTS
    var contexts: [ContextObject]  {
        CONTEXTS
    }

    ///private setter for contexts
    private var CONTEXTS: [ContextObject] = []

    var questions: [Question] {
        QUESTIONS
    }

    private var QUESTIONS: [Question] = []

    typealias CompleteWithNeworkError = (Result<Void, ErrorHandler.NetworkError>) -> Void

    private func createRequest(auth: Bool = true,
                               pathFromBaseURL: String,
                               method: NetworkService.HttpMethod = .get) -> URLRequest? {

        let targetURL = baseURL.appendingPathComponent(pathFromBaseURL)

        guard var request = networkService.createRequest(url: targetURL, method: method) else {
            print("unable to create request for \(targetURL)")
            return nil
        }

        if auth {
            //add bearer to request
            request.addAuthIfAvailable()
        }

        return request
    }

    typealias CompleteWithTopics = (Result<[Topic], ErrorHandler.NetworkError>) -> Void

    ///fetch all topics, or topics for the logged in user
    func fetchTopic(all: Bool = true, completion: @escaping CompleteWithTopics) {
        var appendToURL = "topic"
        if !all {
            // Doesn't look like this will work - topic by id is topic id
            // TODO: coordinate with BE team to see if we can get a topic by userId endpoint
            appendToURL = "\(ProfileController.shared.authenticatedUserProfile!.id!)"
        }
        guard let request = createRequest(pathFromBaseURL: appendToURL) else {
            return
        }
        
        networkService.loadData(using: request) { result in
            switch result {
            case .success(let data):
                guard let topics = self.networkService.decode(to: [Topic].self, data: data) else {
                    print("Error decoding topics")
                    completion(.failure(.badDecode))
                    return
                }
                completion(.success(topics))
            case .failure(let error):
                // bubble error to caller
                completion(.failure(error))
            }
        }
    }


    ///Get all contexts
    func getAllContexts(complete: @escaping CompleteWithNeworkError) {
        guard let request = createRequest(pathFromBaseURL: "context") else {
            print("couldn't get context, invalid request")
            return
        }
        networkService.loadData(using: request) { result in
            switch result {
            case .success(let data):
                guard let contexts = self.networkService.decode(to: [ContextObject].self, data: data) else {
                    print("error decoding contexts from valid data")
                    complete(.failure(.notFound))
                    return
                }
                self.CONTEXTS = contexts
                complete(.success(Void()))
            //bubble error to caller
            case .failure(let error):
                complete(.failure(error))
            }
        }
    }

    func getQuestions(completion: @escaping CompleteWithNeworkError) {
        // create request to /question
        guard let request = self.createRequest(pathFromBaseURL: "question") else {
            completion(.failure(.badRequest))
            return
        }

        // get questions from endpoint
        self.networkService.loadData(using: request) { result in
            //self is nil here???
            switch result {
            // decode questions
            case .success(let data):
                guard let questions = self.networkService.decode(to: [Question].self, data: data) else {
                    completion(.failure(.badDecode))
                    return
                }
                self.QUESTIONS = questions
                completion(.success(Void()))

            // bubble error to caller
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    //TODO
    func getAllQuestionsAndContexts(completion: @escaping CompleteWithNeworkError) {
        getAllContexts { contextResult in
            switch contextResult {
            case .success:
                self.getQuestions() { result in
                    completion(result)
                }
            case.failure:
                completion(contextResult)
            }

        }
    }
    func postTopic(with name: String, contextId: Int, questions: [Question]) {

        // We know this request is good, but we can still guard unwrap it rather than
        // force unwrapping and assume if something fails it was the user not being logged in
        guard var request = createRequest(pathFromBaseURL: "topic", method: .post),
            let token = try? profileController.oktaAuth.credentialsIfAvailable().userID else {
                print("user isn't logged in")
                return
        }
        //TODO: Responses
        // Create topic and add to request
        let topic = Topic(joinCode: UUID().uuidString,
                          leaderId: token,
                          topicName: name,
                          contextId: contextId)
        //let questionsToSend = questions.map { $0.id }

        // TODO: Save to CoreData
        request.encode(from: topic)

        networkService.loadData(using: request) { result in
            switch result {
            case .success(let data):
                print(data)
            case .failure(let error):
                print(error)
            }
        }
    }
}
