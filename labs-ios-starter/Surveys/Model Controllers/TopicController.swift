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
    let baseURL = ProfileController.shared.baseURL

    ///public getter for CONTEXTS
    var contexts: [ String: [Question] ]  {
        CONTEXTS
    }

    ///private setter for contexts
    private var CONTEXTS: [ String:[Question] ] = [:]

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

    typealias CompleteWithContextTitles = (Result<[ContextObject], ErrorHandler.NetworkError>) -> Void
    ///Get all contexts
    func getAllContexts(complete: @escaping CompleteWithContextTitles) {
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
                complete(.success(contexts))
            //bubble error to caller
            case .failure(let error):
                complete(.failure(error))
            }
        }
    }

    typealias CompleteWithQuestions = (Result<[Question], ErrorHandler.NetworkError>) -> Void

    func getQuestions(with contextID: String, completion: @escaping CompleteWithQuestions) {
        //attempt to get questions from cache and return
        if let cachedQuestions = CONTEXTS[contextID] {
            completion(.success(cachedQuestions))
            return
        }
        // create request to /questions/contextID
        guard let request = self.createRequest(pathFromBaseURL: "question/\(contextID)") else {
            completion(.failure(.badRequest))
            return
        }

        // get questions from endpoint
        self.networkService.loadData(using: request) { [weak self] result in
            //self is nil here???
            switch result {
            // decode questions
            case .success(let data):
                guard let questions = self?.networkService.decode(to: [Question].self, data: data) else {
                    completion(.failure(.badDecode))
                    return
                }
                // set cache
                self?.CONTEXTS[contextID] = questions
                completion(.success(questions))

            // bubble error to caller
            case .failure(let error):
                completion(.failure(error))
            }
        }


    }
    //TODO
    func postTopic() {
        guard var request = createRequest(pathFromBaseURL: "topic", method: .post) else {
            return
        }

        //TODO: Dynamic topic
        let json = """
                   {
                    "topicname":"Test"
                    }
                   """.data(using: .utf8)!
        request.addJSONData(json)

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
